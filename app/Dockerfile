# שימוש בגרסה רזה של פייתון
FROM python:3.9-slim

# הגדרת תיקיית עבודה
WORKDIR /app

# העתקת קובץ התלויות והתקנתן
COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# העתקת שאר הקוד
COPY src/ .

# חשיפת הפורט החוצה
EXPOSE 5000

# פקודת ההרצה
CMD ["python", "app.py"]