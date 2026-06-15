import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models, regularizers
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from collections import Counter

NPZ_FILE = r"C:\Users\yasmin\Downloads\Ai_FlexEra\features_resnet50.npz"

BATCH_SIZE = 16
LR = 0.0005  
EPOCHS = 60
HIDDEN_SIZE = 256
DROPOUT = 0.4
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15
PATIENCE = 10       
MAX_LEN_TRIM = 400  

def complex_attention_model(input_dim, num_classes, hidden_size=HIDDEN_SIZE, dropout=DROPOUT):
    inputs = layers.Input(shape=(None, input_dim))
    
    x = layers.Masking(mask_value=0.0)(inputs)
    x = layers.TimeDistributed(layers.Dense(hidden_size, activation='relu'))(x)
    x = layers.TimeDistributed(layers.Dropout(0.2))(x)
    x = layers.Bidirectional(layers.LSTM(hidden_size, return_sequences=True, dropout=dropout))(x)
    x = layers.BatchNormalization()(x)
    x = layers.Bidirectional(layers.LSTM(hidden_size // 2, return_sequences=True, dropout=dropout))(x)
    x = layers.BatchNormalization()(x)
    attention = layers.MultiHeadAttention(num_heads=4, key_dim=hidden_size//2)(x, x)
    x = layers.Add()([x, attention])
    x = layers.LayerNormalization()(x)
    avg_pool = layers.GlobalAveragePooling1D()(x)
    max_pool = layers.GlobalMaxPooling1D()(x)
    x = layers.Concatenate()([avg_pool, max_pool])
    x = layers.Dense(128, activation='relu', kernel_regularizer=regularizers.l2(0.001))(x)
    x = layers.Dropout(dropout)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)
    model = models.Model(inputs=inputs, outputs=outputs, name="bilstm_attention_model8cls")
    return model

def load_data(npz_file=NPZ_FILE):
    if not os.path.exists(npz_file):
        raise FileNotFoundError(f"NPZ file not found: {npz_file}")
    data = np.load(npz_file, allow_pickle=True)
    features = data['features']
    labels = data['labels']
    seq_lengths = [f.shape[0] for f in features]
    print(f"total videos: {len(features)}")
    print(f"exercises: {len(np.unique(labels))}")
    print(f"sequence lengths: {min(seq_lengths)}-{max(seq_lengths)} frames")
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

def per_class_8class(features, labels, le):
    indices = []
    for i, label in enumerate(labels):
        if label < 8:
            indices.append(i)
    features_limited = np.array([features[i] for i in indices], dtype=object)
    labels_limited = labels[indices]
    return features_limited, labels_limited

def split_data(features, labels):
    le = LabelEncoder()
    labels_numeric = le.fit_transform(labels)
    num_classes = len(le.classes_)
    print(f"\n number of classes: {num_classes}")
    print(f"{list(le.classes_)}")
    features_limited, labels_limited = per_class_8class(features, labels_numeric, le)
    X_temp, X_test, y_temp, y_test = train_test_split(
        features_limited, labels_limited,
        test_size=TEST_RATIO,
        random_state=42,
        stratify=labels_limited
    )
    val_split = VAL_RATIO / (TRAIN_RATIO + VAL_RATIO)
    X_train, X_val, y_train, y_val = train_test_split(
        X_temp, y_temp,
        test_size=val_split,
        random_state=42,
        stratify=y_temp
    )
    print(f"train set:")
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

def eval_model(model, test_gen, test_steps, le):
    print("eval to test set")
    all_preds = []
    all_labels = []
    batch_num = 0
    for features, labels in test_gen:
        batch_num += 1
        logits = model.predict(features, verbose=0)
        preds = np.argmax(logits, axis=1)
        all_preds.extend(preds)
        all_labels.extend(labels)
        if batch_num >= test_steps:
            break
        if batch_num % 10 == 0:
            print(f"batch {batch_num}")
    
    all_preds = np.array(all_preds)
    all_labels = np.array(all_labels)
    overall_acc = (all_preds == all_labels).mean()
    print(f"\ntest acc: {overall_acc:.4f} ({overall_acc*100:.2f}%)")
    print("\neach class acc")
    for i, class_name in enumerate(le.classes_[:8]):
        mask = all_labels == i
        if mask.sum() > 0:
            class_acc = (all_preds[mask] == all_labels[mask]).mean()
            count = mask.sum()
            print(f"{class_name:50s} {class_acc:6.2%} ({count:3d} samples)")
        else:
            print(f"{class_name:50s} no samples found")
    return all_preds, all_labels, overall_acc

def main(): 
    features, labels = load_data()
    labels = remove_lr(labels)
    (X_train, y_train), (X_val, y_val), (X_test, y_test), le = split_data(features, labels)
    input_dim = X_train[0].shape[1]
    num_classes = 8
    print("\nbuilding lstm model")
    model = complex_attention_model(input_dim=input_dim, num_classes=num_classes)  
    model.compile(
        optimizer=Adam(learning_rate=LR),
        loss='sparse_categorical_crossentropy',
        metrics=['sparse_categorical_accuracy']
    )
    train_steps = int(np.ceil(len(X_train) / BATCH_SIZE))
    val_steps = int(np.ceil(len(X_val) / BATCH_SIZE))
    test_steps = int(np.ceil(len(X_test) / BATCH_SIZE))
    callbacks = [
        EarlyStopping(
            monitor='val_loss', 
            patience=PATIENCE,
            restore_best_weights=True,
            verbose=1
        ),
        ReduceLROnPlateau(
            monitor='val_loss', 
            factor=0.5, 
            patience=5, 
            min_lr=1e-6, 
            verbose=1
        )
    ]
    
    print("\nstarted training")
    history = model.fit(
        generator(X_train, y_train, batch_size=BATCH_SIZE),
        validation_data=generator(X_val, y_val, batch_size=BATCH_SIZE, shuffle=False),
        steps_per_epoch=train_steps,
        validation_steps=val_steps,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    print("\neval on test set")
    test_gen = generator(X_test, y_test, batch_size=BATCH_SIZE, shuffle=False)
    preds, labels_test, test_acc = eval_model(model, test_gen, test_steps, le)    
    model.save('bilstm_attention_8classes.keras')
    print("saved model .keras")
    
    
    import matplotlib.pyplot as plt
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    
    ax1.plot(history.history['loss'], label='Train Loss', marker='o', markersize=3)
    ax1.plot(history.history['val_loss'], label='Val Loss', marker='s', markersize=3)
    ax1.set_title('Loss (8 Classes)', fontsize=12, fontweight='bold')
    ax1.set_xlabel('Epoch')
    ax1.set_ylabel('Loss')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    ax2.plot(history.history['sparse_categorical_accuracy'], label='Train Acc', marker='o', markersize=3)
    ax2.plot(history.history['val_sparse_categorical_accuracy'], label='Val Acc', marker='s', markersize=3)
    ax2.set_title('Accuracy (8 Classes)', fontsize=12, fontweight='bold')
    ax2.set_xlabel('Epoch')
    ax2.set_ylabel('Accuracy')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('bilstm_8classes_training.png', dpi=150, bbox_inches='tight')
    plt.close(fig)

    print(f"\nfinal Results:")
    print(f"test Accuracy: {test_acc:.2%}")
    
if __name__ == "__main__":
    main()

# Bending knee no support seated                     67.50% ( 40 samples)
# Bending knee with bed support supine               100.00% ( 40 samples)
# Bending knee with support seated                   87.80% ( 41 samples)
# Circular pendulum standing                         100.00% ( 41 samples)
# Circular pendulum standing                         100.00% ( 41 samples)
# External rotation shoulders elastic                100.00% ( 41 samples)
# External rotation shoulders elastic                100.00% ( 41 samples)
# Horizontal weighted openings standing              100.00% ( 40 samples)
# Lift extended leg supine                           100.00% ( 41 samples)
# Shoulder flexion seated                            100.00% ( 40 samples)
# Shoulder flexion seated                            100.00% ( 40 samples)
# saved model .keras

# final Results:
# test Accuracy: 94.44%