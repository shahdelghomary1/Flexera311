import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, regularizers
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

NPZ_FILE = "/home/abdelraheem/Documents/Graduation_test/bidirectional_lstm8cls/features_resnet50_yolo.npz"

BATCH_SIZE = 16
# قللنا الـ Learning Rate لأن الـ Transformer حساس ويحتاج دقة في التعلم
LR = 0.0001  
EPOCHS = 70 
HIDDEN_SIZE = 256
DROPOUT = 0.3 # تقليل الـ Dropout قليلاً لأننا سنستخدم Gaussian Noise
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15
PATIENCE = 15 # زيادة الصبر قليلاً لأن المودل قد يحتاج وقتاً للاستقرار
MAX_LEN_TRIM = 400 

# --- دالة المودل الجديد (Transformer Encoder) ---
def transformer_encoder_model(input_dim, num_classes, hidden_size=HIDDEN_SIZE, dropout=DROPOUT):
    inputs = layers.Input(shape=(None, input_dim))
    
    # 1. Data Augmentation on Features (حيلة لتقليل الاوفرفيتنج)
    # إضافة تشويش عشوائي بسيط جداً للداتا عشان المودل يتعلم الأنماط الصعبة
    x = layers.GaussianNoise(0.05)(inputs)
    
    # 2. Masking
    x = layers.Masking(mask_value=0.0)(x)
    
    # 3. Projection & Local Feature Extraction
    # طبقة Conv1D لاستخراج أنماط الحركة المحلية (Local Patterns)
    x = layers.Conv1D(filters=hidden_size, kernel_size=3, padding="same", activation="relu")(x)
    x = layers.LayerNormalization()(x)
    
    # --- Transformer Block 1 ---
    # Multi-Head Attention
    attention_output = layers.MultiHeadAttention(num_heads=8, key_dim=hidden_size // 8)(x, x)
    # Skip Connection 1
    x2 = layers.Add()([x, attention_output])
    x2 = layers.LayerNormalization()(x2)
    
    # Feed Forward Network
    ffn = layers.Dense(hidden_size, activation="gelu")(x2) # GELU أفضل من RELU في الترانسمفورمر
    ffn = layers.Dropout(dropout)(ffn)
    ffn = layers.Dense(hidden_size)(ffn)
    
    # Skip Connection 2
    x = layers.Add()([x2, ffn])
    x = layers.LayerNormalization()(x)
    
    # --- Transformer Block 2 (تكرار لزيادة العمق والذكاء) ---
    attention_output = layers.MultiHeadAttention(num_heads=8, key_dim=hidden_size // 8)(x, x)
    x2 = layers.Add()([x, attention_output])
    x2 = layers.LayerNormalization()(x2)
    
    ffn = layers.Dense(hidden_size, activation="gelu")(x2)
    ffn = layers.Dropout(dropout)(ffn)
    ffn = layers.Dense(hidden_size)(ffn)
    x = layers.Add()([x2, ffn])
    x = layers.LayerNormalization()(x)

    # 4. Global Pooling
    # دمج المتوسط والحد الأقصى
    avg_pool = layers.GlobalAveragePooling1D()(x)
    max_pool = layers.GlobalMaxPooling1D()(x)
    x = layers.Concatenate()([avg_pool, max_pool])
    
    # 5. Classification Head
    x = layers.Dense(128, activation="gelu", kernel_regularizer=regularizers.l2(0.0005))(x)
    x = layers.Dropout(dropout)(x)
    
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    
    model = models.Model(inputs=inputs, outputs=outputs, name="Transformer_Encoder_Model")
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
    
    print("\nBuilding Transformer Encoder Model...")
    model = transformer_encoder_model(input_dim=input_dim, num_classes=num_classes)
    model.summary()
    
    # استخدام CosineDecay لتقليل الـ Learning rate بنعومة للوصول لأقل Loss ممكن
    lr_schedule = keras.optimizers.schedules.CosineDecay(
        initial_learning_rate=LR,
        decay_steps=EPOCHS * int(np.ceil(len(X_train) / BATCH_SIZE)),
        alpha=0.1
    )

    model.compile(
        optimizer=Adam(learning_rate=lr_schedule),
        loss='sparse_categorical_crossentropy',
        metrics=['sparse_categorical_accuracy']
    )
    
    train_steps = int(np.ceil(len(X_train) / BATCH_SIZE))
    val_steps = int(np.ceil(len(X_val) / BATCH_SIZE))
    test_steps = int(np.ceil(len(X_test) / BATCH_SIZE))
    
    callbacks = [
        EarlyStopping(monitor='val_loss', patience=PATIENCE, restore_best_weights=True, verbose=1),
        # شلنا الـ ReduceLROnPlateau لأننا بنستخدم CosineDecay
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
    
    model.save('transformer_model_high_acc.keras')
    print("Saved model as transformer_model_high_acc.keras")

if __name__ == "__main__":
    main()

#Test Accuracy: 97.22%