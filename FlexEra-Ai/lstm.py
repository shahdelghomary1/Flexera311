import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers, models
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from collections import Counter
import pickle
import matplotlib.pyplot as plt


NPZ_FILE = r"C:\Users\yasmin\Downloads\Ai_FlexEra\features_resnet50.npz"

MAX_FRAMES = 400  

BATCH_SIZE = 8
LR = 0.001
EPOCHS = 100
HIDDEN_SIZE = 256
DROPOUT = 0.2
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
TEST_RATIO = 0.15
PATIENCE = 10


def lstm_model(input_dim, num_classes, hidden_size=HIDDEN_SIZE, dropout=DROPOUT):
    model = models.Sequential([
        # Masking layer is crucial here to ignore the padded zeros
        layers.Masking(mask_value=0.0, input_shape=(MAX_FRAMES, input_dim)), 
        layers.LSTM(hidden_size, return_sequences=True),
        layers.Dropout(dropout),
        layers.LSTM(hidden_size),
        layers.Dropout(dropout),
        layers.Dense(num_classes, activation='softmax')
    ])
    return model


def load_data(npz_file=NPZ_FILE):
    if not os.path.exists(npz_file):
        raise FileNotFoundError(f"NPZ file not found: {npz_file}")
    
    data = np.load(npz_file, allow_pickle=True)
    features = data['features']
    labels = data['labels']
    
    seq_lengths = [f.shape[0] for f in features]
    print(f"Total videos: {len(features)}")
    print(f"Exercises: {len(np.unique(labels))}")
    print(f"Sequence lengths (Original): {min(seq_lengths)}-{max(seq_lengths)} frames")
    
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

def pad_sequences(features_list, max_len=None):
    if max_len is None:
        max_len = max(f.shape[0] for f in features_list)
    
    padded = []
    for feat in features_list:
        if feat.shape[0] < max_len:
            # Padding (adds zeros if shorter than 400)
            padded.append(np.pad(feat, ((0, max_len - feat.shape[0]), (0, 0))))
        else:
            # Truncating (cuts the video if longer than 400)
            padded.append(feat[:max_len])
    return np.array(padded)

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

def create_dataset(X, y, batch_size, shuffle=False):
    dataset = tf.data.Dataset.from_tensor_slices((X, y))
    if shuffle:
        dataset = dataset.shuffle(buffer_size=len(X))
    dataset = dataset.batch(batch_size).prefetch(tf.data.AUTOTUNE)
    return dataset


def main():
    features, labels = load_data()
    labels = remove_lr(labels)
    
    (X_train, y_train), (X_val, y_val), (X_test, y_test), le = split_data(features, labels)
    
    # === التغيير الرئيسي هنا ===
    # بدلاً من حساب max_len من البيانات، نستخدم القيمة الثابتة 400
    print(f"Padding/Truncating sequences to fixed length: {MAX_FRAMES}")
    X_train = pad_sequences(X_train, MAX_FRAMES)
    X_val = pad_sequences(X_val, MAX_FRAMES)
    X_test = pad_sequences(X_test, MAX_FRAMES)
    # ==========================
    
    train_dataset = create_dataset(X_train, y_train, BATCH_SIZE, shuffle=True)
    val_dataset = create_dataset(X_val, y_val, BATCH_SIZE, shuffle=False)
    test_dataset = create_dataset(X_test, y_test, BATCH_SIZE, shuffle=False)
    
    input_dim = X_train.shape[2]
    num_classes = len(le.classes_)
    
    # قمنا بتحديث شكل الإدخال في المودل ليكون (MAX_FRAMES, input_dim) بدلاً من None
    model = lstm_model(input_dim=input_dim, num_classes=num_classes)
    model.compile(
        optimizer=Adam(learning_rate=LR),
        loss='sparse_categorical_crossentropy',
        metrics=['sparse_categorical_accuracy']
    )
    
    callbacks = [
        EarlyStopping(monitor='val_loss', patience=PATIENCE, restore_best_weights=True, verbose=1),
        ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=5, min_lr=1e-6, verbose=1)
    ]
    
    history = model.fit(
        train_dataset,
        validation_data=val_dataset,
        epochs=EPOCHS,
        callbacks=callbacks,
        verbose=1
    )
    
    test_loss, test_acc = model.evaluate(test_dataset)
    print(f"\nTest Accuracy: {test_acc:.2%}")
    
  
    model.save('lstm_model.keras')
    print("Saved LSTM model as lstm_model.keras")

if __name__ == "__main__":
    main()


#Test Accuracy: 87.65%