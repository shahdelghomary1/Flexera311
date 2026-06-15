import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras.models import load_model
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split

# --- نفس الإعدادات ---
NPZ_FILE = r"C:\Users\yasmin\Downloads\Ai_FlexEra\features_resnet50.npz"
BATCH_SIZE = 16
TEST_RATIO = 0.15
TRAIN_RATIO = 0.7
VAL_RATIO = 0.15
MAX_LEN_TRIM = 400

# --- 1. كلاس FocalLoss المصحح (لازم يكون موجود عشان التحميل ينجح) ---
class FocalLoss(tf.keras.losses.Loss):
    def __init__(self, gamma=2.0, alpha=0.25, **kwargs):
        super(FocalLoss, self).__init__(**kwargs)
        self.gamma = gamma
        self.alpha = alpha

    def call(self, y_true, y_pred):
        y_true = tf.cast(y_true, tf.float32)
        y_pred = tf.clip_by_value(y_pred, 1e-7, 1.0 - 1e-7)
        cross_entropy = -y_true * tf.math.log(y_pred)
        weight = self.alpha * y_true * tf.math.pow((1 - y_pred), self.gamma)
        loss = weight * cross_entropy
        return tf.reduce_sum(loss, axis=-1)

    def get_config(self):
        config = super(FocalLoss, self).get_config()
        config.update({'gamma': self.gamma, 'alpha': self.alpha})
        return config

# --- 2. Generator ---
def generator(features, labels, num_classes, batch_size=BATCH_SIZE, max_len=MAX_LEN_TRIM, mode='eval'):
    num_samples = len(features)
    indices = np.arange(num_samples)
    
    while True:
        # في وضع التقييم (eval) مش بنعمل shuffle ولا augmentation
        for start in range(0, num_samples, batch_size):
            end = start + batch_size
            batch_idx = indices[start:end]
            
            batch_features = []
            batch_labels = []
            
            for i in batch_idx:
                feat = features[i]
                label = labels[i]
                
                # Trim
                feat = feat[:max_len]
                
                # Feature Engineering (Deltas) - لازم نعملها عشان المودل متدرب عليها
                deltas = np.diff(feat, axis=0, prepend=feat[0:1])
                combined_feat = np.concatenate([feat, deltas], axis=-1)
                
                batch_features.append(combined_feat)
                label_one_hot = tf.keras.utils.to_categorical(label, num_classes=num_classes)
                batch_labels.append(label_one_hot)
            
            batch_max_len = max(f.shape[0] for f in batch_features)
            batch_padded = []
            for f in batch_features:
                padding_len = batch_max_len - f.shape[0]
                if padding_len > 0:
                    batch_padded.append(np.pad(f, ((0, padding_len), (0,0))))
                else:
                    batch_padded.append(f)
            
            yield np.array(batch_padded, dtype=np.float32), np.array(batch_labels, dtype=np.float32)

# --- 3. دوال مساعدة ---
def load_data(npz_file=NPZ_FILE):
    if not os.path.exists(npz_file):
        raise FileNotFoundError(f"NPZ file not found: {npz_file}")
    data = np.load(npz_file, allow_pickle=True)
    return data['features'], data['labels']

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
    X_temp, X_test, y_temp, y_test = train_test_split(features, labels_numeric, test_size=TEST_RATIO, random_state=42, stratify=labels_numeric)
    print(f"Test Set Size: {len(X_test)}")
    return (None, None), (None, None), (X_test, y_test), le

# --- Main Evaluation ---
def main():
    print("Loading Data...")
    features, labels = load_data()
    labels = remove_lr(labels)
    _, _, (X_test, y_test), le = split_data(features, labels)
    
    num_classes = len(le.classes_)
    test_steps = int(np.ceil(len(X_test) / BATCH_SIZE))
    
    print("\nLoading Trained Model (ultimate_best_model.keras)...")
    
    try:
        # هنا بنحمل المودل الجاهز اللي اتسيف عندك
        model = load_model('ultimate_best_model.keras', custom_objects={'FocalLoss': FocalLoss})
        print("Model Loaded Successfully!")
        
        print("\nEvaluating on Test Set...")
        test_loss, test_acc = model.evaluate(
            generator(X_test, y_test, num_classes, batch_size=BATCH_SIZE, mode='eval'),
            steps=test_steps
        )
        
        print("-" * 30)
        print(f"Final Test Accuracy: {test_acc:.2%}")
        print(f"Final Test Loss:     {test_loss:.4f}")
        print("-" * 30)
        
    except Exception as e:
        print(f"\nError Loading Model: {e}")
        print("تأكدي أن ملف ultimate_best_model.keras موجود في نفس الفولدر")

if __name__ == "__main__":
    main()

#Final Test Accuracy: 96.60%