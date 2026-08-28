<div align="center">

  # 🦅 AdsNest
  **Multi-Tenant Performance Marketing & Agency Operations Platform**

  [![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
  [![Riverpod](https://img.shields.io/badge/State_Management-Riverpod_2.0-0553B1?style=for-the-badge)](https://riverpod.dev)
  [![Supabase](https://img.shields.io/badge/Backend-Supabase_PostgreSQL-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
  [![Architecture](https://img.shields.io/badge/Architecture-Clean_%2B_Feature__First-FF6F00?style=for-the-badge)](#architecture)

</div>

---

## 📌 Overview

**AdsNest** คือ Mobile Application สไตล์ B2B SaaS ที่ออกแบบมาเพื่อแก้ปัญหาการทำงานของ Digital Marketing Agency ในเอเชียตะวันออกเฉียงใต้ (เน้นช่องทาง **TikTok Ads** และ **Shopee Ads**) 

ระบบรองรับสถาปัตยกรรม **Multi-Tenant** ช่วยให้เอเจนซี่สามารถดูแลสถิติโฆษณา แจ้งเตือนงบประมาณรั่วไหล จัดการลิงก์นายหน้า (Affiliate) และอนุมัติงบโฆษณาผ่านแบรนด์ลูกค้าหลายรายได้อย่างปลอดภัยในแอปพลิเคชันเดียว

---

## ✨ Key Features

* 📊 **Multi-Tenant Client Dashboard:** แยกการเข้าถึงข้อมูลของลูกค้าแต่ละบริษัทเด็ดขาดด้วย Supabase Row Level Security (RLS) พร้อมแสดงกราฟ ROAS & Spend แบบ Real-time
* 🔔 **Real-Time Ad Budget Alerts:** ระบบแจ้งเตือนอัตโนมัติผ่าน Firebase Cloud Messaging (FCM) เมื่อแคมเปญโฆษณามีค่าใช้จ่ายเกินกำหนดหรือยอดขายตก
* 🔗 **Affiliate & Campaign Link Generator:** เจนลิงก์สั้น (Short Link) พร้อม QR Code และติดตามยอดขายแยกตามราย Influencer/แคมเปญ
* 💬 **Integrated CRM & Media Briefing Chat:** ช่องทางสื่อสารระหว่างทีมงานและลูกค้า รองรับการส่งวิดีโอบรีฟงาน TikTok และมี **Interactive Action Card** กด [อนุมัติงบโฆษณา] ได้ทันทีในหน้าแชท

---

## 🏗️ Architecture & Technical Design

โครงการนี้พัฒนาขึ้นโดยยึดหลัก **Feature-First + Clean Architecture** เพื่อแยกส่วนประกอบของโค้ดออกจากกันอย่างเด็ดขาด (Separation of Concerns) ทำให้ง่ายต่อการทำ Unit Test และการขยายทีมในอนาคต

```text
lib/
├── core/                              # Shared components (Theme, Utilities, Network, Base Providers)
├── features/                          # Core Business Domains
│   ├── auth/                          # Authentication & Tenant Management
│   ├── dashboard/                     # ROAS Analytics & Charts (Data -> Domain -> Presentation)
│   ├── affiliate/                     # Link Generator & Tracking System
│   └── chat/                          # Realtime CRM Chat & Budget Approvals
└── main.dart                          # Application Entry point wrapped with ProviderScope
