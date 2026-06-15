import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, regularizers
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

NPZ_FILE = r"C:\Users\yasmin\Downloads\Ai_FlexEra\features_resnet50.npz"

BATCH_SIZE = 16
LR = 0.0005 
EPOCHS = 70
HIDDEN_SIZE = 256
DROPOUT = 0.4        # زيادة الـ Dropout قليلاً
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15
PATIENCE = 12
MAX_LEN_TRIM = 400 

# --- دالة المودل الهجين (Hybrid Conv1D + BiLSTM) ---
def hybrid_model(input_dim, num_classes, hidden_size=HIDDEN_SIZE, dropout=DROPOUT):
    inputs = layers.Input(shape=(None, input_dim))
    
    # 1. Noise Injection (Anti-Overfitting)
    x = layers.GaussianNoise(0.05)(inputs)
    x = layers.Masking(mask_value=0.0)(x)
    
    # 2. Local Feature Extraction (Conv1D)
    # استخراج أنماط الحركة المحلية وتقليل الطول الزمني قليلاً لتركيز المعلومات
    x = layers.Conv1D(filters=hidden_size, kernel_size=3, padding="same", activation="relu")(x)
    x = layers.BatchNormalization()(x)
    x = layers.MaxPooling1D(pool_size=2)(x) # تقليل حجم السيكونس للنصف (أسرع وأدق)
    
    # 3. Spatial Dropout (Stronger Regularization)
    x = layers.SpatialDropout1D(0.3)(x)
    
    # 4. Deep Bidirectional LSTM
    # إضافة L2 Regularizer داخل الـ LSTM نفسها
    x = layers.Bidirectional(layers.LSTM(
        hidden_size, 
        return_sequences=True, 
        dropout=dropout,
        kernel_regularizer=regularizers.l2(0.0001) # منع الأوزان من التضخم
    ))(x)
    x = layers.BatchNormalization()(x)
    
    # طبقة ثانية لاستيعاب التعقيد
    x = layers.Bidirectional(layers.LSTM(
        hidden_size // 2, 
        return_sequences=True, 
        dropout=dropout
    ))(x)
    x = layers.BatchNormalization()(x)
    
    # 5. Global Attention Mechanism (Optional but good)
    # تركيز الانتباه بعد معالجة الـ LSTM
    attention = layers.MultiHeadAttention(num_heads=4, key_dim=hidden_size//2)(x, x)
    x = layers.Add()([x, attention])
    x = layers.LayerNormalization()(x)

    # 6. Global Pooling
    avg_pool = layers.GlobalAveragePooling1D()(x)
    max_pool = layers.GlobalMaxPooling1D()(x)
    x = layers.Concatenate()([avg_pool, max_pool])
    
    # 7. Classification Head
    x = layers.Dense(128, activation='relu', kernel_regularizer=regularizers.l2(0.001))(x)
    x = layers.Dropout(0.5)(x) # دروب أوت عالي في النهاية
    
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    
    model = models.Model(inputs=inputs, outputs=outputs, name="Hybrid_Conv_BiLSTM_Model")
    return model

# --- باقي الدوال كما هي ---

def load_data(npz_file=NPZ_FILE):
    if not os.path.exists(npz_file):
        raise FileNotFoundError(f"NPZ file not found: {npz_file}")
    
    data = np.load(npz_file, allow_pickle=True)
    features = data['features']
    labels = data['labels']
    
    seq_lengths = [f.shape[0] for f in features]
    print(f"Total videos: {len(features)}")
    print(f"Exercises: {len(np.unique(labels))}")
    
    return features, labels

def remove_lr(labels):
    merged_labels = []
    for label in labels:
        label_str = str(label)
        if label_str.endswith(' L') or label_str.endswith(' R'):
            merged_labels.append(label_str[:-2].strip())
        else:
            merged_labels.append(label_str)
    return np.array(merged_labels)

def split_data(features, labels):
    le = LabelEncoder()
    labels_numeric = le.fit_transform(labels)
    
    X_temp, X_test, y_temp, y_test = train_test_split(
        features, labels_numeric,
        test_size=TEST_RATIO,
        random_state=42,
        stratify=labels_numeric
    )
    
    val_split = VAL_RATIO / (TRAIN_RATIO + VAL_RATIO)
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp,
        test_size=val_split,
        random_state=42,
        stratify=y_temp
    )
    
    print(f"Train: {len(X_train)}, Val: {len(X_val)}, Test: {len(X_test)}")
    return (X_train, y_train), (X_val, y_val), (X_test, y_test), le

def generator(features, labels, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM, shuffle=True):
    num_samples = len(features)
    indices = np.arange(num_samples)
    
    while True:
        if shuffle:
            np.random.shuffle(indices)
        
        for start in range(0, num_samples, batch_size):
            end = start + batch_size
            batch_idx = indices[start:end]
            
            batch_features = []
            batch_labels = []
            
            for i in batch_idx:
                feat = features[i]
                label = labels[i]
                feat = feat[:max_len]
                batch_features.append(feat)
                batch_labels.append(label)
            
            batch_max_len = max(f.shape[0] for f in batch_features)
            batch_padded = []
            for f in batch_features:
                if f.shape[0] < batch_max_len:
                    batch_padded.append(np.pad(f, ((0, batch_max_len - f.shape[0]), (0,0))))
                else:
                    batch_padded.append(f)
            
            yield np.array(batch_padded, dtype=np.float32), np.array(batch_labels, dtype=np.int32)

def main():
    features, labels = load_data()
    labels = remove_lr(labels)
    
    (X_train, y_train), (X_val, y_val), (X_test, y_test), le = split_data(features, labels)
    
    input_dim = X_train[0].shape[1]
    num_classes = len(le.classes_)
    
    print("\nBuilding Hybrid Conv1D-BiLSTM Model...")
    model = hybrid_model(input_dim=input_dim, num_classes=num_classes)
    model.summary()
    
    # نعود لاستخدام ReduceLROnPlateau لأنه ممتاز مع LSTM
    model.compile(
        optimizer=Adam(learning_rate=LR),
        loss='sparse_categorical_crossentropy',
        metrics=['sparse_categorical_accuracy']
    )
    
    train_steps = int(np.ceil(len(X_train) / BATCH_SIZE))
    val_steps = int(np.ceil(len(X_val) / BATCH_SIZE))
    test_steps = int(np.ceil(len(X_test) / BATCH_SIZE))
    
    callbacks = [
        EarlyStopping(monitor='val_loss', patience=PATIENCE, restore_best_weights=True, verbose=1),
        ReduceLROnPlateau(monitor='val_loss', factor=0.2, patience=5, min_lr=1e-6, verbose=1)
    ]
    
    print("\nStarting Training...")
    history = model.fit(
        generator(X_train, y_train, batch_size=BATCH_SIZE),
        validation_data=generator(X_val, y_val, batch_size=BATCH_SIZE, shuffle=False),
        steps_per_epoch=train_steps,
        validation_steps=val_steps,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    print("\nEvaluating on Test Set...")
    test_loss, test_acc = model.evaluate(
        generator(X_test, y_test, batch_size=BATCH_SIZE, shuffle=False),
        steps=test_steps
    )
    print(f"\nTest Accuracy: {test_acc:.2%}")
    
    model.save('hybrid_conv_lstm_best.keras')
    print("Saved model as hybrid_conv_lstm_best.keras")

if __name__ == "__main__":
    main()

#Test Accuracy: 94.14% 
#مبيقرئش الاصفار بيحولها شاشة سودا 