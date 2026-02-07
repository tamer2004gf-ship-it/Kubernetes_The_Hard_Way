terraform {
  backend "s3" {
    bucket         = "terraform-tamer-state-bucket" # حط اسم الباكت اللي أنشأته يدوياً
    key            = "k8s-hard-way/terraform.tfstate"     # مسار ملف الحالة داخل الباكت
    region         = "eu-central-1"                     # نفس المنطقة اللي شغالين عليها
    encrypt        = true                               # تشفير ملف الـ state للأمان
  }
}