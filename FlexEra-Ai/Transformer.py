import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from tensorflow.keras.layers import MultiHeadAttention, LayerNormalization, Embedding, Input
from tensorflow.keras.models import Model
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

NPZ_FILE = r"C:\Users\yasmin\Downloads\Ai_FlexEra\features_resnet50.npz"

BATCH_SIZE = 16
LR = 0.001
EPOCHS = 50
# تحديد طول التسلسل بـ 400 إطار (ثابت)
MAX_LEN_TRIM = 400 
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15
PATIENCE = 10


# --- 2. دالة بناء وحدة Transformer Encoder ---
def transformer_encoder(inputs, head_size, num_heads, ff_dim, dropout=0.4):
    """بناء وحدة واحدة من Transformer Encoder"""
    
    # 1. طبقة الانتباه الذاتي (Multi-Head Attention)
    x = LayerNormalization(epsilon=1e-6)(inputs)
    x = MultiHeadAttention(
        key_dim=head_size, num_heads=num_heads, dropout=dropout
    )(x, x)
    x = layers.Dropout(dropout)(x)
    res = x + inputs # اتصال تخطي (Skip Connection)

    # 2. طبقة التغذية الأمامية (Feed Forward)
    x = LayerNormalization(epsilon=1e-6)(res)
    x = layers.Conv1D(filters=ff_dim, kernel_size=1, activation="relu")(x)
    x = layers.Dropout(dropout)(x)
    x = layers.Conv1D(filters=inputs.shape[-1], kernel_size=1)(x)
    return x + res # اتصال تخطي


# --- 3. نموذج Transformer الكامل ---
def transformer_model(input_dim, num_classes, max_len=MAX_LEN_TRIM, dropout=0.4):
    """
    نموذج Transformer لتصنيف تسلسلات الحركة.
    """
    
    head_size = 512
    num_heads = 4
    ff_dim = 1024
    num_transformer_blocks = 2 
    
    # تعديل هام: تحديد الشكل الثابت (400) بدلاً من None
    inputs = Input(shape=(max_len, input_dim))
    
    # Masking لتجاهل الأصفار المضافة في الـ Padding
    x = layers.Masking(mask_value=0.0)(inputs)
    
    # تضمين الموضع (Positional Embedding)
    # نستخدم max_len للتأكد من أن الأوزان تغطي الـ 400 فريم
    positions = tf.range(start=0, limit=max_len, delta=1)
    position_embeddings = Embedding(
        input_dim=max_len, 
        output_dim=input_dim,
        weights=[np.zeros((max_len, input_dim))] # تهيئة أولية
    )(positions)
    
    x = x + position_embeddings

    # تطبيق وحدات Transformer Encoder
    for _ in range(num_transformer_blocks):
        x = transformer_encoder(x, head_size, num_heads, ff_dim, dropout)

    # التجميع
    x = layers.GlobalAveragePooling1D(data_format="channels_last")(x)

    # طبقات التصنيف
    x = layers.Dense(head_size, activation="relu", kernel_regularizer=keras.regularizers.l2(0.001))(x)
    x = layers.Dropout(dropout)(x)
    
    outputs = layers.Dense(num_classes, activation="softmax")(x)
    
    return Model(inputs, outputs)


# --- 4. دالة تحميل البيانات ---
def load_data(npz_file=NPZ_FILE):
    if not os.path.exists(npz_file):
        raise FileNotFoundError(f"NPZ file not found: {npz_file}")
    
    data = np.load(npz_file, allow_pickle=True)
    features = data['features']
    labels = data['labels']
    
    seq_lengths = [f.shape[0] for f in features]
    print(f"Total videos: {len(features)}")
    print(f"Exercises: {len(np.unique(labels))}")
    print(f"Sequence lengths: {min(seq_lengths)}-{max(seq_lengths)} frames")
    
    return features, labels


# --- 5. دالة دمج L/R ---
def remove_lr(labels):
    merged_labels = []
    for label in labels:
        label_str = str(label)
        if label_str.endswith(' L') or label_str.endswith(' R'):
            merged_labels.append(label_str[:-2].strip())
        else:
            merged_labels.append(label_str)
    return np.array(merged_labels)


# --- 6. دالة تقسيم البيانات ---
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


# --- 7. دالة المولد (معدلة لتثبيت الطول) ---
def generator(features, labels, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM, shuffle=True):
    """
    Generator معدل ليجعل جميع الفيديوهات بطول ثابت (400).
    """
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
                
                # 1. قص الفيديو إذا كان أطول من 400
                if feat.shape[0] > max_len:
                    feat = feat[:max_len]
                
                # 2. إضافة حشو (Padding) إذا كان أقصر من 400
                elif feat.shape[0] < max_len:
                    padding_len = max_len - feat.shape[0]
                    feat = np.pad(feat, ((0, padding_len), (0,0)), mode='constant')
                
                # إذا كان يساوي 400 يمر كما هو
                
                batch_features.append(feat)
                batch_labels.append(label)
            
            # تحويل القائمة إلى numpy array
            # الشكل الناتج سيكون: (Batch_Size, 400, Features)
            yield np.array(batch_features, dtype=np.float32), np.array(batch_labels, dtype=np.int32)


# --- 8. دالة التشغيل الرئيسية ---
def main():
    features, labels = load_data()
    labels = remove_lr(labels)
    
    (X_train, y_train), (X_val, y_val), (X_test, y_test), le = split_data(features, labels)
    
    input_dim = X_train[0].shape[1]
    num_classes = len(le.classes_)
    
    # طباعة تأكيد على تثبيت الفريمات
    print(f"Building Transformer Model with fixed sequence length: {MAX_LEN_TRIM}")

    model = transformer_model(input_dim=input_dim, num_classes=num_classes, max_len=MAX_LEN_TRIM)
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
        ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-6, verbose=1)
    ]
    
    print("--- Model Summary (Transformer) ---")
    model.summary()
    print("-----------------------------------")

    history = model.fit(
        generator(X_train, y_train, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM),
        validation_data=generator(X_val, y_val, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM, shuffle=False),
        steps_per_epoch=train_steps,
        validation_steps=val_steps,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    test_loss, test_acc = model.evaluate(
        generator(X_test, y_test, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM, shuffle=False),
        steps=test_steps
    )
    print(f"\nTest Accuracy (Transformer): {test_acc:.2%}")
    
    model.save('transformer_model_fixed_400.keras')
    print("Saved Transformer model as transformer_model_fixed_400.keras")


if __name__ == "__main__":
    main()

#Test Accuracy (Transformer): 52.16%