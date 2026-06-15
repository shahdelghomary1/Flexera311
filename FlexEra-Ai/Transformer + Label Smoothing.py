import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, regularizers
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

# --- إعدادات الملف والبارامترات ---
NPZ_FILE = r"C:\Users\yasmin\Downloads\Ai_FlexEra\features_resnet50.npz"

BATCH_SIZE = 16
LR = 0.0001  
EPOCHS = 70 
HIDDEN_SIZE = 256
DROPOUT = 0.4  # زودنا الـ Dropout شوية عشان نمنع الاوفرفيتنج تماماً
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15
PATIENCE = 15 
MAX_LEN_TRIM = 400 

# --- دالة المودل (Transformer محسّن) ---
def transformer_tuned_model(input_dim, num_classes, hidden_size=HIDDEN_SIZE, dropout=DROPOUT):
    inputs = layers.Input(shape=(None, input_dim))
    
    # Gaussian Noise لجعل المودل أقوى ضد التغييرات
    x = layers.GaussianNoise(0.05)(inputs)
    x = layers.Masking(mask_value=0.0)(x)
    
    # Projection
    x = layers.Dense(hidden_size, activation="gelu")(x)
    x = layers.Dropout(0.2)(x)
    
    # --- Transformer Block 1 ---
    # زيادة عدد الـ Heads لـ 8 عشان يركز في تفاصيل أكتر
    attention_output = layers.MultiHeadAttention(num_heads=8, key_dim=hidden_size // 8, dropout=0.2)(x, x)
    x2 = layers.Add()([x, attention_output])
    x2 = layers.LayerNormalization()(x2)
    
    ffn = layers.Dense(hidden_size * 2, activation="gelu")(x2) # وسعنا الشبكة الداخلية شوية
    ffn = layers.Dropout(dropout)(ffn)
    ffn = layers.Dense(hidden_size)(ffn)
    
    x = layers.Add()([x2, ffn])
    x = layers.LayerNormalization()(x)
    
    # --- Transformer Block 2 ---
    attention_output = layers.MultiHeadAttention(num_heads=8, key_dim=hidden_size // 8, dropout=0.2)(x, x)
    x2 = layers.Add()([x, attention_output])
    x2 = layers.LayerNormalization()(x2)
    
    ffn = layers.Dense(hidden_size * 2, activation="gelu")(x2)
    ffn = layers.Dropout(dropout)(ffn)
    ffn = layers.Dense(hidden_size)(ffn)
    x = layers.Add()([x2, ffn])
    x = layers.LayerNormalization()(x)

    # Global Pooling
    avg_pool = layers.GlobalAveragePooling1D()(x)
    max_pool = layers.GlobalMaxPooling1D()(x)
    x = layers.Concatenate()([avg_pool, max_pool])
    
    # Classification Head
    x = layers.Dense(128, activation="gelu", kernel_regularizer=regularizers.l2(0.0005))(x)
    x = layers.Dropout(dropout)(x)
    
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    
    model = models.Model(inputs=inputs, outputs=outputs, name="Transformer_LabelSmoothing")
    return model

# --- باقي الدوال ---

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

# --- تحديث Generator لدعم One-Hot Encoding (عشان Label Smoothing) ---
def generator(features, labels, num_classes, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM, shuffle=True):
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
                # تحويل الليبل إلى One-Hot
                label_one_hot = tf.keras.utils.to_categorical(label, num_classes=num_classes)
                batch_labels.append(label_one_hot)
            
            batch_max_len = max(f.shape[0] for f in batch_features)
            batch_padded = []
            for f in batch_features:
                if f.shape[0] < batch_max_len:
                    batch_padded.append(np.pad(f, ((0, batch_max_len - f.shape[0]), (0,0))))
                else:
                    batch_padded.append(f)
            
            yield np.array(batch_padded, dtype=np.float32), np.array(batch_labels, dtype=np.float32)

def main():
    features, labels = load_data()
    labels = remove_lr(labels)
    
    (X_train, y_train), (X_val, y_val), (X_test, y_test), le = split_data(features, labels)
    
    input_dim = X_train[0].shape[1]
    num_classes = len(le.classes_)
    
    print("\nBuilding Transformer V2 (with Label Smoothing)...")
    model = transformer_tuned_model(input_dim=input_dim, num_classes=num_classes)
    model.summary()
    
    # استخدام Label Smoothing بقيمة 0.1
    # هذا هو السر لرفع الدقة وتقليل الاوفرفيتنج
    loss_fn = tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1)

    model.compile(
        optimizer=Adam(learning_rate=LR),
        loss=loss_fn,
        metrics=['categorical_accuracy'] # غيرنا المتركس لـ categorical
    )
    
    train_steps = int(np.ceil(len(X_train) / BATCH_SIZE))
    val_steps = int(np.ceil(len(X_val) / BATCH_SIZE))
    test_steps = int(np.ceil(len(X_test) / BATCH_SIZE))
    
    callbacks = [
        EarlyStopping(monitor='val_loss', patience=PATIENCE, restore_best_weights=True, verbose=1),
    ]
    
    print("\nStarting Training...")
    history = model.fit(
        generator(X_train, y_train, num_classes, batch_size=BATCH_SIZE),
        validation_data=generator(X_val, y_val, num_classes, batch_size=BATCH_SIZE, shuffle=False),
        steps_per_epoch=train_steps,
        validation_steps=val_steps,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    print("\nEvaluating on Test Set...")
    test_loss, test_acc = model.evaluate(
        generator(X_test, y_test, num_classes, batch_size=BATCH_SIZE, shuffle=False),
        steps=test_steps
    )
    print(f"\nTest Accuracy: {test_acc:.2%}")
    
    model.save('transformer_final_best.keras')
    print("Saved model as transformer_final_best.keras")

if __name__ == "__main__":
    main()

#Test Accuracy: 96.60%