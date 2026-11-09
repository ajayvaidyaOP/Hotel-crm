-- =====================================================================
--  V2 - Development / demo seed data (5 hotels, staff, rooms, bookings).
--  Applied only when app.seed.enabled=true (see FlywayConfig).
--  All passwords: Owner@123 (owner), Hotel@123 (all other accounts).
-- =====================================================================

SET @now = UTC_TIMESTAMP(6);

INSERT INTO roles (id, code, name, description) VALUES (1, 'SUPER_ADMIN', 'Owner / Super Admin', 'Full access to every hotel and financial report');
INSERT INTO roles (id, code, name, description) VALUES (2, 'HOTEL_MANAGER', 'Hotel Manager', 'Full operational access to assigned hotels');
INSERT INTO roles (id, code, name, description) VALUES (3, 'RECEPTIONIST', 'Receptionist', 'Reservations, check-in/out, payments, invoices');
INSERT INTO roles (id, code, name, description) VALUES (4, 'HOUSEKEEPING', 'Housekeeping', 'Cleaning tasks, room status, maintenance requests');
INSERT INTO roles (id, code, name, description) VALUES (5, 'ACCOUNTANT', 'Accountant', 'Payments, expenses, invoices and financial reports');

INSERT INTO permissions (id, code, description) VALUES (1, 'hotel:read', 'hotel read access');
INSERT INTO permissions (id, code, description) VALUES (2, 'hotel:write', 'hotel write access');
INSERT INTO permissions (id, code, description) VALUES (3, 'room:read', 'room read access');
INSERT INTO permissions (id, code, description) VALUES (4, 'room:write', 'room write access');
INSERT INTO permissions (id, code, description) VALUES (5, 'pricing:read', 'pricing read access');
INSERT INTO permissions (id, code, description) VALUES (6, 'pricing:write', 'pricing write access');
INSERT INTO permissions (id, code, description) VALUES (7, 'booking:read', 'booking read access');
INSERT INTO permissions (id, code, description) VALUES (8, 'booking:write', 'booking write access');
INSERT INTO permissions (id, code, description) VALUES (9, 'booking:cancel', 'booking cancel access');
INSERT INTO permissions (id, code, description) VALUES (10, 'checkin:write', 'checkin write access');
INSERT INTO permissions (id, code, description) VALUES (11, 'checkout:write', 'checkout write access');
INSERT INTO permissions (id, code, description) VALUES (12, 'guest:read', 'guest read access');
INSERT INTO permissions (id, code, description) VALUES (13, 'guest:write', 'guest write access');
INSERT INTO permissions (id, code, description) VALUES (14, 'payment:read', 'payment read access');
INSERT INTO permissions (id, code, description) VALUES (15, 'payment:write', 'payment write access');
INSERT INTO permissions (id, code, description) VALUES (16, 'invoice:read', 'invoice read access');
INSERT INTO permissions (id, code, description) VALUES (17, 'invoice:write', 'invoice write access');
INSERT INTO permissions (id, code, description) VALUES (18, 'refund:write', 'refund write access');
INSERT INTO permissions (id, code, description) VALUES (19, 'expense:read', 'expense read access');
INSERT INTO permissions (id, code, description) VALUES (20, 'expense:write', 'expense write access');
INSERT INTO permissions (id, code, description) VALUES (21, 'housekeeping:read', 'housekeeping read access');
INSERT INTO permissions (id, code, description) VALUES (22, 'housekeeping:write', 'housekeeping write access');
INSERT INTO permissions (id, code, description) VALUES (23, 'maintenance:read', 'maintenance read access');
INSERT INTO permissions (id, code, description) VALUES (24, 'maintenance:write', 'maintenance write access');
INSERT INTO permissions (id, code, description) VALUES (25, 'staff:read', 'staff read access');
INSERT INTO permissions (id, code, description) VALUES (26, 'staff:write', 'staff write access');
INSERT INTO permissions (id, code, description) VALUES (27, 'report:read', 'report read access');
INSERT INTO permissions (id, code, description) VALUES (28, 'analytics:read', 'analytics read access');
INSERT INTO permissions (id, code, description) VALUES (29, 'notification:read', 'notification read access');
INSERT INTO permissions (id, code, description) VALUES (30, 'audit:read', 'audit read access');
INSERT INTO permissions (id, code, description) VALUES (31, 'coupon:write', 'coupon write access');
INSERT INTO permissions (id, code, description) VALUES (32, 'service:read', 'service read access');
INSERT INTO permissions (id, code, description) VALUES (33, 'service:write', 'service write access');

INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 1);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 2);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 3);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 4);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 5);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 6);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 7);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 8);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 9);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 10);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 11);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 12);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 13);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 14);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 15);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 16);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 17);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 18);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 19);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 20);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 21);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 22);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 23);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 24);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 25);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 26);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 27);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 28);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 29);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 30);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 31);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 32);
INSERT INTO role_permissions (role_id, permission_id) VALUES (1, 33);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 1);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 3);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 4);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 5);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 6);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 7);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 8);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 9);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 10);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 11);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 12);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 13);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 14);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 15);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 16);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 17);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 18);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 19);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 20);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 21);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 22);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 23);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 24);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 25);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 26);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 27);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 28);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 29);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 32);
INSERT INTO role_permissions (role_id, permission_id) VALUES (2, 33);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 1);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 3);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 4);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 7);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 8);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 9);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 10);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 11);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 12);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 13);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 14);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 15);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 16);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 17);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 29);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 32);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 33);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 5);
INSERT INTO role_permissions (role_id, permission_id) VALUES (3, 21);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 1);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 3);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 21);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 22);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 23);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 24);
INSERT INTO role_permissions (role_id, permission_id) VALUES (4, 29);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 1);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 14);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 15);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 16);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 17);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 18);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 19);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 20);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 27);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 28);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 7);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 12);
INSERT INTO role_permissions (role_id, permission_id) VALUES (5, 29);

INSERT INTO hotels (id, name, code, address, city, state, country, postal_code, contact_number, email, description,
  image_urls, facilities, check_in_time, check_out_time, timezone, star_rating, gst_number, tax_rate, status, created_at, updated_at)
VALUES (1, 'Grand Vista Mumbai', 'HTL-MUM', '12 Marine Drive, Colaba', 'Mumbai', 'Maharashtra', 'India', '400001',
  '+91 22 4000 1200', 'stay@grandvista-mumbai.com', 'A waterfront five-star landmark on Marine Drive offering panoramic sea views, a rooftop infinity pool and award-winning dining.',
  '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200","https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=1200"]', '["Free WiFi","Rooftop Pool","Spa","Business Centre","Airport Transfer","Valet Parking","Restaurant","Bar","Gym"]', '14:00:00', '11:00:00', 'Asia/Kolkata',
  5, '27AABCG1234M1Z5', 12, 'ACTIVE', DATE_SUB(@now, INTERVAL 420 DAY), @now);
INSERT INTO hotels (id, name, code, address, city, state, country, postal_code, contact_number, email, description,
  image_urls, facilities, check_in_time, check_out_time, timezone, star_rating, gst_number, tax_rate, status, created_at, updated_at)
VALUES (2, 'Palm Bay Resort Goa', 'HTS-GOA', 'Beach Road, Candolim', 'Candolim', 'Goa', 'India', '403515',
  '+91 832 660 2200', 'reservations@palmbaygoa.com', 'Beachfront resort with private access to Candolim beach, tropical pool deck, seafood grill and sunset cruises.',
  '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200","https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=1200"]', '["Private Beach","Outdoor Pool","Restaurant","Bar","Water Sports","Spa","Free WiFi","Laundry"]', '13:00:00', '10:00:00', 'Asia/Kolkata',
  4, '30AABCP5678R1Z2', 12, 'ACTIVE', DATE_SUB(@now, INTERVAL 390 DAY), @now);
INSERT INTO hotels (id, name, code, address, city, state, country, postal_code, contact_number, email, description,
  image_urls, facilities, check_in_time, check_out_time, timezone, star_rating, gst_number, tax_rate, status, created_at, updated_at)
VALUES (3, 'Heritage Palace Jaipur', 'HTS-JAI', 'Amber Road, Brahmpuri', 'Jaipur', 'Rajasthan', 'India', '302001',
  '+91 141 220 8800', 'hello@heritagepalace.in', 'A restored 18th-century palace with hand-painted frescoes, courtyard gardens, royal dining and heritage walks.',
  '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200","https://images.unsplash.com/photo-1590490360182-c33d57733427?w=1200"]', '["Heritage Tours","Courtyard Pool","Fine Dining","Spa","Free WiFi","Airport Transfer","Wedding Lawn","Library"]', '14:00:00', '12:00:00', 'Asia/Kolkata',
  5, '08AABCH9012P1Z9', 18, 'ACTIVE', DATE_SUB(@now, INTERVAL 360 DAY), @now);
INSERT INTO hotels (id, name, code, address, city, state, country, postal_code, contact_number, email, description,
  image_urls, facilities, check_in_time, check_out_time, timezone, star_rating, gst_number, tax_rate, status, created_at, updated_at)
VALUES (4, 'Alpine Crest Manali', 'HTS-MNL', 'Log Huts Area, Old Manali', 'Manali', 'Himachal Pradesh', 'India', '175131',
  '+91 1902 250 700', 'frontdesk@alpinecrest.in', 'Mountain lodge with cedar balconies, fireplace lounges, guided treks and valley-facing suites.',
  '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200","https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=1200"]', '["Mountain View","Fireplace Lounge","Trek Desk","Restaurant","Free Parking","Free WiFi","Bonfire","Pet Friendly"]', '12:00:00', '10:00:00', 'Asia/Kolkata',
  4, '02AABCA3456K1Z7', 12, 'ACTIVE', DATE_SUB(@now, INTERVAL 330 DAY), @now);
INSERT INTO hotels (id, name, code, address, city, state, country, postal_code, contact_number, email, description,
  image_urls, facilities, check_in_time, check_out_time, timezone, star_rating, gst_number, tax_rate, status, created_at, updated_at)
VALUES (5, 'Urban Nest Pune', 'HTS-PNQ', '35 Bund Garden Road', 'Pune', 'Maharashtra', 'India', '411001',
  '+91 20 6722 4400', 'stay@urbannestpune.com', 'Smart business hotel near the Koregaon Park business district with co-working lounge and 24x7 room service.',
  '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200","https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=1200"]', '["Co-working Lounge","Gym","Restaurant","Free WiFi","Laundry","Airport Transfer","Meeting Rooms"]', '13:00:00', '11:00:00', 'Asia/Kolkata',
  3, '27AABCU7890L1Z3', 12, 'ACTIVE', DATE_SUB(@now, INTERVAL 300 DAY), @now);

-- users (owner@hotelgroup.com / Owner@123 , all others Hotel@123)
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (1, 'Rajiv Mehta', 'owner@hotelgroup.com', '+91 98200 11001', '$2a$10$7he4.VUYnhDMe0pvL4uiAufi88xCepWHFE1i4NE8w4/NxtZ7DKnhi', 'SUPER_ADMIN', b'1', b'0', 0, 'Group Owner',
  DATE_SUB(@now, INTERVAL 2 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (2, 'Ananya Sharma', 'manager.mumbai@hotelgroup.com', '+91 98200 11002', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOTEL_MANAGER', b'1', b'0', 0, 'General Manager',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (3, 'Carlos Fernandes', 'manager.goa@hotelgroup.com', '+91 98200 11003', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOTEL_MANAGER', b'1', b'0', 0, 'Resort Manager',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (4, 'Meera Rathore', 'manager.jaipur@hotelgroup.com', '+91 98200 11004', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOTEL_MANAGER', b'1', b'0', 0, 'General Manager',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (5, 'Karan Thakur', 'manager.manali@hotelgroup.com', '+91 98200 11005', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOTEL_MANAGER', b'1', b'0', 0, 'Lodge Manager',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (6, 'Priya Deshpande', 'manager.pune@hotelgroup.com', '+91 98200 11006', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOTEL_MANAGER', b'1', b'0', 0, 'Hotel Manager',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (7, 'Nikhil Verma', 'reception.mumbai@hotelgroup.com', '+91 98200 11007', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'RECEPTIONIST', b'1', b'0', 0, 'Front Desk Executive',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (8, 'Fatima Shaikh', 'reception.goa@hotelgroup.com', '+91 98200 11008', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'RECEPTIONIST', b'1', b'0', 0, 'Front Desk Executive',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (9, 'Rohit Kumawat', 'reception.jaipur@hotelgroup.com', '+91 98200 11009', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'RECEPTIONIST', b'1', b'0', 0, 'Front Office Supervisor',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (10, 'Sunita Yadav', 'housekeeping.mumbai@hotelgroup.com', '+91 98200 11010', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOUSEKEEPING', b'1', b'0', 0, 'Housekeeping Supervisor',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (11, 'Lakshmi Nair', 'housekeeping.goa@hotelgroup.com', '+91 98200 11011', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOUSEKEEPING', b'1', b'0', 0, 'Room Attendant',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (12, 'Deepak Chauhan', 'housekeeping.pune@hotelgroup.com', '+91 98200 11012', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'HOUSEKEEPING', b'1', b'0', 0, 'Housekeeping Attendant',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (13, 'Vikram Sethi', 'accounts@hotelgroup.com', '+91 98200 11013', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'ACCOUNTANT', b'1', b'0', 0, 'Chief Accountant',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO users (id, full_name, email, phone, password_hash, primary_role, enabled, must_change_password, token_version, designation, last_login_at, created_at, updated_at)
VALUES (14, 'Neha Kapoor', 'billing@hotelgroup.com', '+91 98200 11014', '$2a$10$xo9kR7T6egEEc7d5Cw4dd.l.yyz/HTehDem.g7yB8R2C4hQcjje.O', 'ACCOUNTANT', b'1', b'0', 0, 'Accounts Executive',
  DATE_SUB(@now, INTERVAL 26 HOUR), DATE_SUB(@now, INTERVAL 400 DAY), @now);

INSERT INTO user_roles (user_id, role_id) VALUES (1, 1);
INSERT INTO user_roles (user_id, role_id) VALUES (2, 2);
INSERT INTO user_roles (user_id, role_id) VALUES (3, 2);
INSERT INTO user_roles (user_id, role_id) VALUES (4, 2);
INSERT INTO user_roles (user_id, role_id) VALUES (5, 2);
INSERT INTO user_roles (user_id, role_id) VALUES (6, 2);
INSERT INTO user_roles (user_id, role_id) VALUES (7, 3);
INSERT INTO user_roles (user_id, role_id) VALUES (8, 3);
INSERT INTO user_roles (user_id, role_id) VALUES (9, 3);
INSERT INTO user_roles (user_id, role_id) VALUES (10, 4);
INSERT INTO user_roles (user_id, role_id) VALUES (11, 4);
INSERT INTO user_roles (user_id, role_id) VALUES (12, 4);
INSERT INTO user_roles (user_id, role_id) VALUES (13, 5);
INSERT INTO user_roles (user_id, role_id) VALUES (14, 5);

INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (1, 1, 1, 'Group Owner', 'GV-EMP-001', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 548 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (2, 2, 1, 'Group Owner', 'PB-EMP-001', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 465 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (3, 3, 1, 'Group Owner', 'HP-EMP-001', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 372 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (4, 4, 1, 'Group Owner', 'AC-EMP-001', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 235 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (5, 5, 1, 'Group Owner', 'UN-EMP-001', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 203 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (6, 1, 2, 'General Manager', 'GV-EMP-002', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 296 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (7, 2, 3, 'Resort Manager', 'PB-EMP-003', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 706 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (8, 3, 4, 'General Manager', 'HP-EMP-004', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 366 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (9, 4, 5, 'Lodge Manager', 'AC-EMP-005', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 770 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (10, 5, 6, 'Hotel Manager', 'UN-EMP-006', 'Management',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 755 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (11, 1, 7, 'Front Desk Executive', 'GV-EMP-007', 'Front Office',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 547 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (12, 2, 8, 'Front Desk Executive', 'PB-EMP-008', 'Front Office',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 271 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (13, 4, 8, 'Front Desk Executive', 'AC-EMP-008', 'Front Office',
  'Evening', '15:00:00', '23:00:00', DATE_SUB(CURDATE(), INTERVAL 272 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (14, 3, 9, 'Front Office Supervisor', 'HP-EMP-009', 'Front Office',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 660 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (15, 1, 10, 'Housekeeping Supervisor', 'GV-EMP-010', 'Housekeeping',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 230 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (16, 3, 10, 'Housekeeping Supervisor', 'HP-EMP-010', 'Housekeeping',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 778 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (17, 2, 11, 'Room Attendant', 'PB-EMP-011', 'Housekeeping',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 301 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (18, 5, 12, 'Housekeeping Attendant', 'UN-EMP-012', 'Housekeeping',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 533 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (19, 4, 12, 'Housekeeping Attendant', 'AC-EMP-012', 'Housekeeping',
  'Morning', '07:00:00', '15:00:00', DATE_SUB(CURDATE(), INTERVAL 353 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (20, 1, 13, 'Chief Accountant', 'GV-EMP-013', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 229 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (21, 2, 13, 'Chief Accountant', 'PB-EMP-013', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 468 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (22, 3, 13, 'Chief Accountant', 'HP-EMP-013', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 332 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (23, 4, 13, 'Chief Accountant', 'AC-EMP-013', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 618 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (24, 5, 13, 'Chief Accountant', 'UN-EMP-013', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 846 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (25, 1, 14, 'Accounts Executive', 'GV-EMP-014', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 608 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);
INSERT INTO hotel_staff (id, hotel_id, user_id, designation, employee_code, department, shift_name, shift_start, shift_end, joined_on, active, created_at, updated_at)
VALUES (26, 5, 14, 'Accounts Executive', 'UN-EMP-014', 'Finance',
  'General', '09:30:00', '18:30:00', DATE_SUB(CURDATE(), INTERVAL 255 DAY), b'1', DATE_SUB(@now, INTERVAL 300 DAY), @now);

INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (1, 1, 'Standard', 'STD', 'Standard room at Grand Vista Mumbai', 5100.00, 6400.00, 918.00,
  1122.00, 1530.00, 1530.00, 2, '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', 1, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (2, 1, 'Deluxe', 'DLX', 'Deluxe room at Grand Vista Mumbai', 8300.00, 10400.00, 1494.00,
  1826.00, 2490.00, 2490.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', 2, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (3, 1, 'Premium', 'PRM', 'Premium room at Grand Vista Mumbai', 12500.00, 15600.00, 2250.00,
  2750.00, 3750.00, 3750.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', 3, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (4, 1, 'Suite', 'STE', 'Suite room at Grand Vista Mumbai', 20000.00, 25000.00, 3600.00,
  4400.00, 6000.00, 6000.00, 4, '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', 4, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (5, 1, 'Family Room', 'FAM', 'Family Room room at Grand Vista Mumbai', 15400.00, 19300.00, 2772.00,
  3388.00, 4620.00, 4620.00, 5, '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', 5, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (6, 2, 'Standard', 'STD', 'Standard room at Palm Bay Resort Goa', 4000.00, 5000.00, 720.00,
  880.00, 1200.00, 1200.00, 2, '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', 1, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (7, 2, 'Deluxe', 'DLX', 'Deluxe room at Palm Bay Resort Goa', 6500.00, 8100.00, 1170.00,
  1430.00, 1950.00, 1950.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', 2, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (8, 2, 'Premium', 'PRM', 'Premium room at Palm Bay Resort Goa', 9800.00, 12300.00, 1764.00,
  2156.00, 2940.00, 2940.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', 3, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (9, 2, 'Suite', 'STE', 'Suite room at Palm Bay Resort Goa', 15600.00, 19500.00, 2808.00,
  3432.00, 4680.00, 4680.00, 4, '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', 4, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (10, 2, 'Family Room', 'FAM', 'Family Room room at Palm Bay Resort Goa', 12000.00, 15000.00, 2160.00,
  2640.00, 3600.00, 3600.00, 5, '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', 5, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (11, 3, 'Standard', 'STD', 'Standard room at Heritage Palace Jaipur', 4500.00, 5600.00, 810.00,
  990.00, 1350.00, 1350.00, 2, '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', 1, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (12, 3, 'Deluxe', 'DLX', 'Deluxe room at Heritage Palace Jaipur', 7300.00, 9100.00, 1314.00,
  1606.00, 2190.00, 2190.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', 2, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (13, 3, 'Premium', 'PRM', 'Premium room at Heritage Palace Jaipur', 10900.00, 13600.00, 1962.00,
  2398.00, 3270.00, 3270.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', 3, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (14, 3, 'Suite', 'STE', 'Suite room at Heritage Palace Jaipur', 17500.00, 21900.00, 3150.00,
  3850.00, 5250.00, 5250.00, 4, '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', 4, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (15, 3, 'Family Room', 'FAM', 'Family Room room at Heritage Palace Jaipur', 13400.00, 16800.00, 2412.00,
  2948.00, 4020.00, 4020.00, 5, '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', 5, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (16, 4, 'Standard', 'STD', 'Standard room at Alpine Crest Manali', 3000.00, 3800.00, 540.00,
  660.00, 900.00, 900.00, 2, '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', 1, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (17, 4, 'Deluxe', 'DLX', 'Deluxe room at Alpine Crest Manali', 4900.00, 6100.00, 882.00,
  1078.00, 1470.00, 1470.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', 2, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (18, 4, 'Premium', 'PRM', 'Premium room at Alpine Crest Manali', 7400.00, 9300.00, 1332.00,
  1628.00, 2220.00, 2220.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', 3, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (19, 4, 'Suite', 'STE', 'Suite room at Alpine Crest Manali', 11900.00, 14900.00, 2142.00,
  2618.00, 3570.00, 3570.00, 4, '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', 4, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (20, 4, 'Family Room', 'FAM', 'Family Room room at Alpine Crest Manali', 9100.00, 11400.00, 1638.00,
  2002.00, 2730.00, 2730.00, 5, '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', 5, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (21, 5, 'Standard', 'STD', 'Standard room at Urban Nest Pune', 2700.00, 3400.00, 486.00,
  594.00, 810.00, 810.00, 2, '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', 1, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (22, 5, 'Deluxe', 'DLX', 'Deluxe room at Urban Nest Pune', 4400.00, 5500.00, 792.00,
  968.00, 1320.00, 1320.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', 2, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (23, 5, 'Premium', 'PRM', 'Premium room at Urban Nest Pune', 6600.00, 8300.00, 1188.00,
  1452.00, 1980.00, 1980.00, 3, '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', 3, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (24, 5, 'Suite', 'STE', 'Suite room at Urban Nest Pune', 10600.00, 13300.00, 1908.00,
  2332.00, 3180.00, 3180.00, 4, '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', 4, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);
INSERT INTO room_categories (id, hotel_id, name, code, description, base_price, weekend_price, extra_person_charge, extra_bed_charge,
  early_checkin_charge, late_checkout_charge, max_occupancy, amenities, image_urls, sort_order, active, created_at, updated_at)
VALUES (25, 5, 'Family Room', 'FAM', 'Family Room room at Urban Nest Pune', 8200.00, 10300.00, 1476.00,
  1804.00, 2460.00, 2460.00, 5, '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', 5, b'1', DATE_SUB(@now, INTERVAL 400 DAY), @now);

INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (1, 1, 1, '111', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 111', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  5100.00, 6400.00, 918.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (2, 1, 1, '112', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 112', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  5100.00, 6400.00, 918.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (3, 1, 1, '211', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 211', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  5100.00, 6400.00, 918.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (4, 1, 1, '212', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 212', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  5100.00, 6400.00, 918.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (5, 1, 2, '121', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 121', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  8300.00, 10400.00, 1494.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (6, 1, 2, '122', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 122', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  8300.00, 10400.00, 1494.00, 'MAINTENANCE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (7, 1, 2, '221', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 221', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  8300.00, 10400.00, 1494.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (8, 1, 2, '222', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 222', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  8300.00, 10400.00, 1494.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (9, 1, 3, '131', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 131', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  12500.00, 15600.00, 2250.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (10, 1, 3, '132', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 132', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  12500.00, 15600.00, 2250.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (11, 1, 3, '231', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 231', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  12500.00, 15600.00, 2250.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (12, 1, 3, '232', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 232', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  12500.00, 15600.00, 2250.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (13, 1, 4, '141', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 141', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  20000.00, 25000.00, 3600.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (14, 1, 4, '142', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 142', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  20000.00, 25000.00, 3600.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (15, 1, 4, '241', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 241', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  20000.00, 25000.00, 3600.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (16, 1, 4, '242', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 242', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  20000.00, 25000.00, 3600.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (17, 1, 5, '151', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 151', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  15400.00, 19300.00, 2772.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (18, 1, 5, '152', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 152', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  15400.00, 19300.00, 2772.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (19, 1, 5, '251', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 251', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  15400.00, 19300.00, 2772.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (20, 1, 5, '252', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 252', '["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  15400.00, 19300.00, 2772.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (21, 2, 6, '111', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 111', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4000.00, 5000.00, 720.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (22, 2, 6, '112', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 112', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4000.00, 5000.00, 720.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (23, 2, 6, '211', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 211', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4000.00, 5000.00, 720.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (24, 2, 6, '212', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 212', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4000.00, 5000.00, 720.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (25, 2, 7, '121', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 121', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  6500.00, 8100.00, 1170.00, 'MAINTENANCE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (26, 2, 7, '122', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 122', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  6500.00, 8100.00, 1170.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (27, 2, 7, '221', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 221', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  6500.00, 8100.00, 1170.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (28, 2, 7, '222', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 222', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  6500.00, 8100.00, 1170.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (29, 2, 8, '131', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 131', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  9800.00, 12300.00, 1764.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (30, 2, 8, '132', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 132', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  9800.00, 12300.00, 1764.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (31, 2, 8, '231', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 231', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  9800.00, 12300.00, 1764.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (32, 2, 8, '232', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 232', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  9800.00, 12300.00, 1764.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (33, 2, 9, '141', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 141', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  15600.00, 19500.00, 2808.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (34, 2, 9, '142', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 142', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  15600.00, 19500.00, 2808.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (35, 2, 9, '241', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 241', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  15600.00, 19500.00, 2808.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (36, 2, 9, '242', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 242', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  15600.00, 19500.00, 2808.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (37, 2, 10, '151', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 151', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  12000.00, 15000.00, 2160.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (38, 2, 10, '152', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 152', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  12000.00, 15000.00, 2160.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (39, 2, 10, '251', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 251', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  12000.00, 15000.00, 2160.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (40, 2, 10, '252', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 252', '["https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  12000.00, 15000.00, 2160.00, 'MAINTENANCE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (41, 3, 11, '111', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 111', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4500.00, 5600.00, 810.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (42, 3, 11, '112', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 112', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4500.00, 5600.00, 810.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (43, 3, 11, '211', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 211', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4500.00, 5600.00, 810.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (44, 3, 11, '212', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 212', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  4500.00, 5600.00, 810.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (45, 3, 12, '121', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 121', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  7300.00, 9100.00, 1314.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (46, 3, 12, '122', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 122', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  7300.00, 9100.00, 1314.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (47, 3, 12, '221', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 221', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  7300.00, 9100.00, 1314.00, 'MAINTENANCE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (48, 3, 12, '222', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 222', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  7300.00, 9100.00, 1314.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (49, 3, 13, '131', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 131', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  10900.00, 13600.00, 1962.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (50, 3, 13, '132', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 132', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  10900.00, 13600.00, 1962.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (51, 3, 13, '231', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 231', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  10900.00, 13600.00, 1962.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (52, 3, 13, '232', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 232', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  10900.00, 13600.00, 1962.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (53, 3, 14, '141', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 141', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  17500.00, 21900.00, 3150.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (54, 3, 14, '142', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 142', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  17500.00, 21900.00, 3150.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (55, 3, 14, '241', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 241', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  17500.00, 21900.00, 3150.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (56, 3, 14, '242', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 242', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  17500.00, 21900.00, 3150.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (57, 3, 15, '151', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 151', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  13400.00, 16800.00, 2412.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (58, 3, 15, '152', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 152', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  13400.00, 16800.00, 2412.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (59, 3, 15, '251', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 251', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  13400.00, 16800.00, 2412.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (60, 3, 15, '252', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 252', '["https://images.unsplash.com/photo-1582719508461-905c673771fd?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  13400.00, 16800.00, 2412.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (61, 4, 16, '111', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 111', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  3000.00, 3800.00, 540.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (62, 4, 16, '112', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 112', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  3000.00, 3800.00, 540.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (63, 4, 16, '211', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 211', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  3000.00, 3800.00, 540.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (64, 4, 16, '212', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 212', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  3000.00, 3800.00, 540.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (65, 4, 17, '121', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 121', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4900.00, 6100.00, 882.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (66, 4, 17, '122', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 122', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4900.00, 6100.00, 882.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (67, 4, 17, '221', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 221', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4900.00, 6100.00, 882.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (68, 4, 17, '222', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 222', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4900.00, 6100.00, 882.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (69, 4, 18, '131', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 131', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  7400.00, 9300.00, 1332.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (70, 4, 18, '132', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 132', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  7400.00, 9300.00, 1332.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (71, 4, 18, '231', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 231', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  7400.00, 9300.00, 1332.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (72, 4, 18, '232', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 232', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  7400.00, 9300.00, 1332.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (73, 4, 19, '141', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 141', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  11900.00, 14900.00, 2142.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (74, 4, 19, '142', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 142', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  11900.00, 14900.00, 2142.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (75, 4, 19, '241', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 241', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  11900.00, 14900.00, 2142.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (76, 4, 19, '242', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 242', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  11900.00, 14900.00, 2142.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (77, 4, 20, '151', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 151', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  9100.00, 11400.00, 1638.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (78, 4, 20, '152', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 152', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  9100.00, 11400.00, 1638.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (79, 4, 20, '251', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 251', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  9100.00, 11400.00, 1638.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (80, 4, 20, '252', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 252', '["https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  9100.00, 11400.00, 1638.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (81, 5, 21, '111', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 111', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  2700.00, 3400.00, 486.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (82, 5, 21, '112', 1, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 112', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  2700.00, 3400.00, 486.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (83, 5, 21, '211', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 211', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  2700.00, 3400.00, 486.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (84, 5, 21, '212', 2, 'DOUBLE', 'DOUBLE', 2, b'1',
  'Standard - room 212', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","LED TV","Tea/Coffee Kit","Work Desk"]',
  2700.00, 3400.00, 486.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (85, 5, 22, '121', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 121', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4400.00, 5500.00, 792.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (86, 5, 22, '122', 1, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 122', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4400.00, 5500.00, 792.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (87, 5, 22, '221', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 221', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4400.00, 5500.00, 792.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (88, 5, 22, '222', 2, 'DOUBLE', 'QUEEN', 3, b'1',
  'Deluxe - room 222', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","City View","Room Service"]',
  4400.00, 5500.00, 792.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (89, 5, 23, '131', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 131', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  6600.00, 8300.00, 1188.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (90, 5, 23, '132', 1, 'TWIN', 'KING', 3, b'1',
  'Premium - room 132', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  6600.00, 8300.00, 1188.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (91, 5, 23, '231', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 231', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  6600.00, 8300.00, 1188.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (92, 5, 23, '232', 2, 'TWIN', 'KING', 3, b'1',
  'Premium - room 232', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Air Conditioning","Free WiFi","Smart TV","Minibar","Balcony","Bathtub","Lounge Access"]',
  6600.00, 8300.00, 1188.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (93, 5, 24, '141', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 141', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  10600.00, 13300.00, 1908.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (94, 5, 24, '142', 1, 'SUITE', 'KING', 4, b'1',
  'Suite - room 142', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  10600.00, 13300.00, 1908.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (95, 5, 24, '241', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 241', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  10600.00, 13300.00, 1908.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (96, 5, 24, '242', 2, 'SUITE', 'KING', 4, b'1',
  'Suite - room 242', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Living Room","Air Conditioning","Free WiFi","Smart TV","Minibar","Jacuzzi","Butler Service","Lounge Access"]',
  10600.00, 13300.00, 1908.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (97, 5, 25, '151', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 151', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  8200.00, 10300.00, 1476.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (98, 5, 25, '152', 1, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 152', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  8200.00, 10300.00, 1476.00, 'AVAILABLE', 'INSPECTED', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (99, 5, 25, '251', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 251', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  8200.00, 10300.00, 1476.00, 'AVAILABLE', 'DIRTY', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);
INSERT INTO rooms (id, hotel_id, room_category_id, room_number, floor, room_type, bed_type, max_occupancy, is_ac, description,
  image_urls, amenities, base_price, weekend_price, extra_person_charge, status, housekeeping_status, active, created_at, updated_at)
VALUES (100, 5, 25, '252', 2, 'FAMILY', 'TWIN', 5, b'1',
  'Family Room - room 252', '["https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=1200"]', '["Two Bedrooms","Air Conditioning","Free WiFi","Smart TV","Kids Amenities","Refrigerator"]',
  8200.00, 10300.00, 1476.00, 'AVAILABLE', 'CLEAN', b'1', DATE_SUB(@now, INTERVAL 380 DAY), @now);

INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (1, 1, NULL, NULL, 'Peak Season Surcharge', 'SEASONAL', 'PERCENTAGE', 18.00,
  DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY), NULL, 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (2, 1, NULL, NULL, 'Diwali Holiday Rate', 'HOLIDAY', 'PERCENTAGE', 25.00,
  DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 116 DAY), NULL, 30, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (3, 1, NULL, NULL, 'Monsoon Promotion', 'PROMO', 'PERCENTAGE', -15.00,
  DATE_ADD(CURDATE(), INTERVAL -20 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 10, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (4, 1, NULL, NULL, 'Weekend Premium', 'WEEKEND', 'PERCENTAGE', 15.00,
  NULL, NULL, 'SAT,SUN', 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (5, 2, NULL, NULL, 'Peak Season Surcharge', 'SEASONAL', 'PERCENTAGE', 18.00,
  DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY), NULL, 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (6, 2, NULL, NULL, 'Diwali Holiday Rate', 'HOLIDAY', 'PERCENTAGE', 25.00,
  DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 116 DAY), NULL, 30, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (7, 2, NULL, NULL, 'Monsoon Promotion', 'PROMO', 'PERCENTAGE', -15.00,
  DATE_ADD(CURDATE(), INTERVAL -20 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 10, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (8, 2, NULL, NULL, 'Weekend Premium', 'WEEKEND', 'PERCENTAGE', 15.00,
  NULL, NULL, 'SAT,SUN', 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (9, 3, NULL, NULL, 'Peak Season Surcharge', 'SEASONAL', 'PERCENTAGE', 18.00,
  DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY), NULL, 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (10, 3, NULL, NULL, 'Diwali Holiday Rate', 'HOLIDAY', 'PERCENTAGE', 25.00,
  DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 116 DAY), NULL, 30, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (11, 3, NULL, NULL, 'Monsoon Promotion', 'PROMO', 'PERCENTAGE', -15.00,
  DATE_ADD(CURDATE(), INTERVAL -20 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 10, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (12, 3, NULL, NULL, 'Weekend Premium', 'WEEKEND', 'PERCENTAGE', 15.00,
  NULL, NULL, 'SAT,SUN', 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (13, 4, NULL, NULL, 'Peak Season Surcharge', 'SEASONAL', 'PERCENTAGE', 18.00,
  DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY), NULL, 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (14, 4, NULL, NULL, 'Diwali Holiday Rate', 'HOLIDAY', 'PERCENTAGE', 25.00,
  DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 116 DAY), NULL, 30, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (15, 4, NULL, NULL, 'Monsoon Promotion', 'PROMO', 'PERCENTAGE', -15.00,
  DATE_ADD(CURDATE(), INTERVAL -20 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 10, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (16, 4, NULL, NULL, 'Weekend Premium', 'WEEKEND', 'PERCENTAGE', 15.00,
  NULL, NULL, 'SAT,SUN', 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (17, 5, NULL, NULL, 'Peak Season Surcharge', 'SEASONAL', 'PERCENTAGE', 18.00,
  DATE_ADD(CURDATE(), INTERVAL 20 DAY), DATE_ADD(CURDATE(), INTERVAL 75 DAY), NULL, 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (18, 5, NULL, NULL, 'Diwali Holiday Rate', 'HOLIDAY', 'PERCENTAGE', 25.00,
  DATE_ADD(CURDATE(), INTERVAL 110 DAY), DATE_ADD(CURDATE(), INTERVAL 116 DAY), NULL, 30, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (19, 5, NULL, NULL, 'Monsoon Promotion', 'PROMO', 'PERCENTAGE', -15.00,
  DATE_ADD(CURDATE(), INTERVAL -20 DAY), DATE_ADD(CURDATE(), INTERVAL 30 DAY), NULL, 10, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);
INSERT INTO room_pricing (id, hotel_id, room_category_id, room_id, name, pricing_type, adjustment_type, amount, start_date, end_date, days_of_week, priority, active, created_at, updated_at)
VALUES (20, 5, NULL, NULL, 'Weekend Premium', 'WEEKEND', 'PERCENTAGE', 15.00,
  NULL, NULL, 'SAT,SUN', 20, b'1', DATE_SUB(@now, INTERVAL 90 DAY), @now);

INSERT INTO coupons (id, hotel_id, code, description, discount_type, value, min_amount, max_discount, valid_from, valid_to, usage_limit, used_count, active, created_at, updated_at) VALUES
 (1, NULL, 'WELCOME10', '10% off for first-time direct bookings', 'PERCENTAGE', 10.00, 3000.00, 2500.00, DATE_ADD(CURDATE(), INTERVAL -60 DAY), DATE_ADD(CURDATE(), INTERVAL 180 DAY), 500, 12, b'1', DATE_SUB(@now, INTERVAL 60 DAY), @now),
 (2, NULL, 'STAYLONG', 'Flat INR 1500 off on stays of 4 nights or more', 'FLAT', 1500.00, 12000.00, NULL, DATE_ADD(CURDATE(), INTERVAL -30 DAY), DATE_ADD(CURDATE(), INTERVAL 120 DAY), 200, 8, b'1', DATE_SUB(@now, INTERVAL 30 DAY), @now),
 (3, 2, 'GOASUN20', '20% monsoon special for Palm Bay Resort Goa', 'PERCENTAGE', 20.00, 5000.00, 4000.00, DATE_ADD(CURDATE(), INTERVAL -15 DAY), DATE_ADD(CURDATE(), INTERVAL 45 DAY), 100, 5, b'1', DATE_SUB(@now, INTERVAL 15 DAY), @now);

INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (1, 3, 'Aarav Kapoor', '+91 98210 33445', 'aarav.kapoor@gmail.com', '82 Sector 21, Pune',
  'Mumbai', 'Maharashtra', 'India', 'AADHAAR', NULL, '4123', 'VIP', b'1', b'0',
  'Long-standing VIP guest. Prefers high floor and late check-out.',
  'Late check-out',
  179, DATE_SUB(@now, INTERVAL 791 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (2, 1, 'Ishita Menon', '+91 98450 11223', 'ishita.menon@outlook.com', '57 Banjara Hills, Bengaluru',
  'Bengaluru', 'Karnataka', 'India', 'PASSPORT', NULL, '8821', 'VIP', b'1', b'0',
  'Long-standing VIP guest. Prefers high floor and late check-out.',
  'Vegetarian breakfast',
  790, DATE_SUB(@now, INTERVAL 314 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (3, 1, 'Rahul Bhatia', '+91 99870 44556', 'rahul.bhatia@techcorp.io', '22 Linking Road, Delhi',
  'Pune', 'Maharashtra', 'India', 'DRIVING_LICENSE', NULL, '5512', 'CORPORATE', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Airport pickup',
  409, DATE_SUB(@now, INTERVAL 590 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (4, 3, 'Sneha Kulkarni', '+91 98220 77889', 'sneha.k@designstudio.in', '28 Park Street, Bengaluru',
  'Pune', 'Maharashtra', 'India', 'PAN', NULL, '3390', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  NULL,
  661, DATE_SUB(@now, INTERVAL 575 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (5, 4, 'Michael Chen', '+65 8123 4455', 'michael.chen@globalventures.sg', '33 Sector 21, Mumbai',
  'Singapore', 'Singapore', 'Singapore', 'VOTER_ID', NULL, '1102', 'CORPORATE', b'1', b'0',
  'Long-standing VIP guest. Prefers high floor and late check-out.',
  'Extra pillows',
  228, DATE_SUB(@now, INTERVAL 325 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (6, 3, 'Anjali Deshmukh', '+91 90040 12345', 'anjali.deshmukh@gmail.com', '56 Park Street, Hyderabad',
  'Nagpur', 'Maharashtra', 'India', 'AADHAAR', NULL, '7745', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Vegetarian breakfast',
  450, DATE_SUB(@now, INTERVAL 647 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (7, 3, 'Vikram Singh Rathore', '+91 94140 55667', 'vikram.rathore@rajmail.in', '28 Linking Road, Delhi',
  'Jaipur', 'Rajasthan', 'India', 'PASSPORT', NULL, '2288', 'VIP', b'1', b'0',
  'Long-standing VIP guest. Prefers high floor and late check-out.',
  NULL,
  334, DATE_SUB(@now, INTERVAL 731 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (8, 5, 'Emily Watson', '+44 7700 900123', 'emily.watson@mail.co.uk', '38 Sector 21, Hyderabad',
  'London', 'England', 'United Kingdom', 'DRIVING_LICENSE', NULL, '4451', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Late check-out',
  197, DATE_SUB(@now, INTERVAL 133 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (9, 2, 'Sanjay Gupta', '+91 98110 66778', 'sanjay.gupta@guptaexports.com', '82 MG Road, Hyderabad',
  'Delhi', 'Delhi', 'India', 'PAN', NULL, '9903', 'CORPORATE', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Late check-out',
  149, DATE_SUB(@now, INTERVAL 823 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (10, 3, 'Pooja Iyer', '+91 98400 88990', 'pooja.iyer@gmail.com', '84 Banjara Hills, Bengaluru',
  'Chennai', 'Tamil Nadu', 'India', 'VOTER_ID', NULL, '6617', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  NULL,
  151, DATE_SUB(@now, INTERVAL 94 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (11, 2, 'Arjun Malhotra', '+91 99200 33441', 'arjun.malhotra@startuply.in', '16 Linking Road, Pune',
  'Mumbai', 'Maharashtra', 'India', 'AADHAAR', NULL, '8823', 'LOYALTY', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Extra pillows',
  717, DATE_SUB(@now, INTERVAL 417 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (12, 3, 'Kavita Nair', '+91 94470 22334', 'kavita.nair@keralamail.com', '64 Banjara Hills, Pune',
  'Kochi', 'Kerala', 'India', 'PASSPORT', NULL, '4432', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  NULL,
  659, DATE_SUB(@now, INTERVAL 408 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (13, 5, 'Rohan Joshi', '+91 98230 55667', 'rohan.joshi@gmail.com', '66 Banjara Hills, Bengaluru',
  'Thane', 'Maharashtra', 'India', 'DRIVING_LICENSE', NULL, '1176', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Extra pillows',
  200, DATE_SUB(@now, INTERVAL 563 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (14, 3, 'Tara Bhandari', '+91 98200 99887', 'tara.bhandari@fashionably.in', '51 Banjara Hills, Hyderabad',
  'Mumbai', 'Maharashtra', 'India', 'PAN', NULL, '3358', 'VIP', b'1', b'0',
  'Long-standing VIP guest. Prefers high floor and late check-out.',
  'Late check-out',
  566, DATE_SUB(@now, INTERVAL 303 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (15, 2, 'Daniel Pereira', '+91 98220 44332', 'daniel.pereira@gmail.com', '45 Banjara Hills, Pune',
  'Goa', 'Goa', 'India', 'VOTER_ID', NULL, '7789', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Airport pickup',
  16, DATE_SUB(@now, INTERVAL 60 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (16, 3, 'Aisha Khan', '+91 99870 11229', 'aisha.khan@mediacorp.in', '66 Linking Road, Delhi',
  'Mumbai', 'Maharashtra', 'India', 'AADHAAR', NULL, '5540', 'LOYALTY', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Airport pickup',
  67, DATE_SUB(@now, INTERVAL 450 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (17, 1, 'Nikhil Bansal', '+91 98100 66554', 'nikhil.bansal@bansalfoods.com', '37 MG Road, Hyderabad',
  'Gurugram', 'Haryana', 'India', 'PASSPORT', NULL, '2290', 'CORPORATE', b'0', b'0',
  'Prefers non-smoking rooms.',
  'High floor',
  214, DATE_SUB(@now, INTERVAL 158 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (18, 3, 'Priyanka Reddy', '+91 99490 77883', 'priyanka.reddy@hydmail.com', '39 Banjara Hills, Mumbai',
  'Hyderabad', 'Telangana', 'India', 'DRIVING_LICENSE', NULL, '8812', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  NULL,
  80, DATE_SUB(@now, INTERVAL 276 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (19, 5, 'Sunil Agarwal', '+91 98300 44556', 'sunil.agarwal@agarwaltraders.com', '58 Sector 21, Mumbai',
  'Kolkata', 'West Bengal', 'India', 'PAN', NULL, '4467', 'REGULAR', b'0', b'0',
  'Prefers non-smoking rooms.',
  'Late check-out',
  423, DATE_SUB(@now, INTERVAL 601 DAY), @now);
INSERT INTO guests (id, hotel_id, full_name, mobile, email, address, city, state, country, id_proof_type, id_proof_number, id_proof_last4, category, vip, blacklisted, notes, special_requests, loyalty_points, created_at, updated_at)
VALUES (20, 2, 'Nandini Rao', '+91 98860 99112', 'nandini.rao@gmail.com', '39 Sector 21, Delhi',
  'Bengaluru', 'Karnataka', 'India', 'VOTER_ID', NULL, '9902', 'VIP', b'1', b'0',
  'Long-standing VIP guest. Prefers high floor and late check-out.',
  'Extra pillows',
  216, DATE_SUB(@now, INTERVAL 84 DAY), @now);

INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (1, 'GV-24001', 1, 1, DATE_ADD(CURDATE(), INTERVAL -45 DAY), DATE_ADD(CURDATE(), INTERVAL -42 DAY), 3, 0, 'WALK_IN',
  'CHECKED_OUT', 'PAID', 60000.00, 1800.00, 3000.00, 7056.00, 65856.00, 65856.00, 65856.00, 0.00,
  'Airport pickup required',
  'Booked by Aarav Kapoor - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -45 DAY), '14:18:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -42 DAY), '10:27:00'),
  7, 7,
  7, DATE_SUB(@now, INTERVAL 47 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (2, 'PB-24002', 2, 2, DATE_ADD(CURDATE(), INTERVAL -38 DAY), DATE_ADD(CURDATE(), INTERVAL -36 DAY), 2, 2, 'OTA',
  'CHECKED_OUT', 'PAID', 13000.00, 450.00, 650.00, 1536.00, 14336.00, 14336.00, 14336.00, 0.00,
  'Early breakfast at 7 AM',
  'Booked by Ishita Menon - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -38 DAY), '14:40:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -36 DAY), '10:37:00'),
  7, 7,
  1, DATE_SUB(@now, INTERVAL 40 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (3, 'HP-24003', 3, 3, DATE_ADD(CURDATE(), INTERVAL -30 DAY), DATE_ADD(CURDATE(), INTERVAL -26 DAY), 2, 0, 'AGENT',
  'CHECKED_OUT', 'PAID', 43600.00, 1800.00, 0.00, 8172.00, 53572.00, 53572.00, 53572.00, 0.00,
  'Extra bed for child',
  'Booked by Rahul Bhatia - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '14:49:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -26 DAY), '10:38:00'),
  7, 7,
  7, DATE_SUB(@now, INTERVAL 32 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (4, 'AC-24004', 4, 4, DATE_ADD(CURDATE(), INTERVAL -25 DAY), DATE_ADD(CURDATE(), INTERVAL -24 DAY), 2, 0, 'WALK_IN',
  'CHECKED_OUT', 'PAID', 9100.00, 1350.00, 0.00, 1254.00, 11704.00, 11704.00, 11704.00, 0.00,
  NULL,
  'Booked by Sneha Kulkarni - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -25 DAY), '14:04:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -24 DAY), '10:16:00'),
  7, 7,
  2, DATE_SUB(@now, INTERVAL 27 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (5, 'UN-24005', 5, 5, DATE_ADD(CURDATE(), INTERVAL -21 DAY), DATE_ADD(CURDATE(), INTERVAL -18 DAY), 2, 0, 'OTA',
  'CHECKED_OUT', 'PAID', 13200.00, 1800.00, 0.00, 1800.00, 16800.00, 16800.00, 16800.00, 0.00,
  'Extra bed for child',
  'Booked by Michael Chen - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -21 DAY), '14:04:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -18 DAY), '10:02:00'),
  7, 7,
  9, DATE_SUB(@now, INTERVAL 23 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (6, 'GV-24006', 1, 6, DATE_ADD(CURDATE(), INTERVAL -16 DAY), DATE_ADD(CURDATE(), INTERVAL -14 DAY), 2, 2, 'CORPORATE',
  'CANCELLED', 'REFUNDED', 10200.00, 0.00, 0.00, 1224.00, 11424.00, 0.00, 0.00, 11424.00,
  'Extra bed for child',
  'Booked by Anjali Deshmukh - new guest.',
  'Travel plans changed by guest', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -17 DAY), '12:00:00'),
  NULL,
  NULL,
  NULL, NULL,
  8, DATE_SUB(@now, INTERVAL 18 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (7, 'PB-24007', 2, 7, DATE_ADD(CURDATE(), INTERVAL -14 DAY), DATE_ADD(CURDATE(), INTERVAL -12 DAY), 3, 0, 'AGENT',
  'CHECKED_OUT', 'PAID', 13000.00, 450.00, 0.00, 1614.00, 15064.00, 15064.00, 15064.00, 0.00,
  NULL,
  'Booked by Vikram Singh Rathore - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -14 DAY), '14:15:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -12 DAY), '10:31:00'),
  7, 7,
  9, DATE_SUB(@now, INTERVAL 16 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (8, 'HP-24008', 3, 8, DATE_ADD(CURDATE(), INTERVAL -12 DAY), DATE_ADD(CURDATE(), INTERVAL -7 DAY), 1, 2, 'WEBSITE',
  'CHECKED_OUT', 'PAID', 36500.00, 450.00, 0.00, 6651.00, 43601.00, 43601.00, 43601.00, 0.00,
  'Airport pickup required',
  'Booked by Emily Watson - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -12 DAY), '14:47:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '10:34:00'),
  7, 7,
  9, DATE_SUB(@now, INTERVAL 14 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (9, 'AC-24009', 4, 9, DATE_ADD(CURDATE(), INTERVAL -9 DAY), DATE_ADD(CURDATE(), INTERVAL -7 DAY), 1, 1, 'PHONE',
  'CHECKED_OUT', 'PAID', 23800.00, 450.00, 1190.00, 2767.20, 25827.20, 25827.20, 25827.20, 0.00,
  'Airport pickup required',
  'Booked by Sanjay Gupta - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -9 DAY), '14:18:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '10:24:00'),
  7, 7,
  3, DATE_SUB(@now, INTERVAL 11 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (10, 'UN-24010', 5, 10, DATE_ADD(CURDATE(), INTERVAL -7 DAY), DATE_ADD(CURDATE(), INTERVAL -4 DAY), 2, 1, 'AGENT',
  'CHECKED_OUT', 'PAID', 31800.00, 900.00, 0.00, 3924.00, 36624.00, 36624.00, 36624.00, 0.00,
  NULL,
  'Booked by Pooja Iyer - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -7 DAY), '14:50:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '10:01:00'),
  7, 7,
  2, DATE_SUB(@now, INTERVAL 9 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (11, 'GV-24011', 1, 11, DATE_ADD(CURDATE(), INTERVAL -6 DAY), DATE_ADD(CURDATE(), INTERVAL -4 DAY), 3, 0, 'WALK_IN',
  'NO_SHOW', 'UNPAID', 30800.00, 0.00, 1540.00, 3511.20, 32771.20, 0.00, 0.00, 32771.20,
  'Quiet room away from elevator',
  'Booked by Arjun Malhotra - new guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  2, DATE_SUB(@now, INTERVAL 8 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (12, 'PB-24012', 2, 12, DATE_ADD(CURDATE(), INTERVAL -5 DAY), DATE_ADD(CURDATE(), INTERVAL -1 DAY), 3, 0, 'AGENT',
  'CHECKED_OUT', 'PAID', 48000.00, 1350.00, 0.00, 5922.00, 55272.00, 55272.00, 55272.00, 0.00,
  'Early breakfast at 7 AM',
  'Booked by Kavita Nair - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '14:34:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:02:00'),
  7, 7,
  2, DATE_SUB(@now, INTERVAL 7 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (13, 'HP-24013', 3, 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), DATE_ADD(CURDATE(), INTERVAL -2 DAY), 3, 0, 'DIRECT',
  'CHECKED_OUT', 'PAID', 35000.00, 1350.00, 0.00, 6543.00, 42893.00, 42893.00, 42893.00, 0.00,
  'Airport pickup required',
  'Booked by Rohan Joshi - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:19:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '10:01:00'),
  7, 7,
  2, DATE_SUB(@now, INTERVAL 6 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (14, 'AC-24014', 4, 14, DATE_ADD(CURDATE(), INTERVAL -3 DAY), DATE_ADD(CURDATE(), INTERVAL -1 DAY), 2, 0, 'WALK_IN',
  'CHECKED_OUT', 'PAID', 23800.00, 1800.00, 0.00, 3072.00, 28672.00, 28672.00, 28672.00, 0.00,
  'Extra bed for child',
  'Booked by Tara Bhandari - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '14:48:00'),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:23:00'),
  7, 7,
  7, DATE_SUB(@now, INTERVAL 5 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (15, 'UN-24015', 5, 15, DATE_ADD(CURDATE(), INTERVAL -2 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 1, 'CORPORATE',
  'CHECKED_IN', 'PAID', 8100.00, 1800.00, 0.00, 1188.00, 11088.00, 11088.00, 11088.00, 0.00,
  NULL,
  'Booked by Daniel Pereira - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '14:26:00'),
  NULL,
  7, NULL,
  3, DATE_SUB(@now, INTERVAL 4 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (16, 'GV-24016', 1, 16, DATE_ADD(CURDATE(), INTERVAL -2 DAY), DATE_ADD(CURDATE(), INTERVAL 0 DAY), 3, 0, 'WALK_IN',
  'CHECKED_IN', 'PAID', 30800.00, 1800.00, 0.00, 3912.00, 36512.00, 36512.00, 36512.00, 0.00,
  NULL,
  'Booked by Aisha Khan - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '14:08:00'),
  NULL,
  7, NULL,
  3, DATE_SUB(@now, INTERVAL 4 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (17, 'PB-24017', 2, 17, DATE_ADD(CURDATE(), INTERVAL -1 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 2, 0, 'AGENT',
  'CHECKED_IN', 'PAID', 12000.00, 1350.00, 600.00, 1530.00, 14280.00, 14280.00, 14280.00, 0.00,
  'Airport pickup required',
  'Booked by Nikhil Bansal - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '14:42:00'),
  NULL,
  7, NULL,
  2, DATE_SUB(@now, INTERVAL 3 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (18, 'HP-24018', 3, 18, DATE_ADD(CURDATE(), INTERVAL -1 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 2, 'CORPORATE',
  'CHECKED_IN', 'PAID', 9000.00, 1350.00, 450.00, 1782.00, 11682.00, 11682.00, 11682.00, 0.00,
  'Early breakfast at 7 AM',
  'Booked by Priyanka Reddy - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '14:46:00'),
  NULL,
  7, NULL,
  1, DATE_SUB(@now, INTERVAL 3 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (19, 'AC-24019', 4, 19, DATE_ADD(CURDATE(), INTERVAL -1 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 3, 0, 'CORPORATE',
  'CHECKED_IN', 'PAID', 19600.00, 1800.00, 0.00, 2568.00, 23968.00, 23968.00, 23968.00, 0.00,
  NULL,
  'Booked by Sunil Agarwal - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '14:27:00'),
  NULL,
  7, NULL,
  8, DATE_SUB(@now, INTERVAL 3 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (20, 'UN-24020', 5, 20, DATE_ADD(CURDATE(), INTERVAL -3 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 0, 'DIRECT',
  'CHECKED_IN', 'PAID', 22000.00, 1350.00, 0.00, 2802.00, 26152.00, 26152.00, 26152.00, 0.00,
  'Airport pickup required',
  'Booked by Nandini Rao - new guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '14:23:00'),
  NULL,
  7, NULL,
  2, DATE_SUB(@now, INTERVAL 5 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (21, 'GV-24021', 1, 1, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 0, 'CORPORATE',
  'CONFIRMED', 'UNPAID', 25000.00, 0.00, 0.00, 3000.00, 28000.00, 0.00, 0.00, 28000.00,
  'Early breakfast at 7 AM',
  'Booked by Aarav Kapoor - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  7, DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (22, 'PB-24022', 2, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 0, 'PHONE',
  'CONFIRMED', 'UNPAID', 12000.00, 0.00, 0.00, 1440.00, 13440.00, 0.00, 0.00, 13440.00,
  'Airport pickup required',
  'Booked by Ishita Menon - new guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  7, DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (23, 'HP-24023', 3, 3, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 0, 'WALK_IN',
  'CONFIRMED', 'PARTIALLY_PAID', 17500.00, 0.00, 0.00, 3150.00, 20650.00, 6195.00, 6195.00, 14455.00,
  'Airport pickup required',
  'Booked by Rahul Bhatia - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  3, DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (24, 'AC-24024', 4, 4, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 1, 2, 'OTA',
  'CHECKED_IN', 'PAID', 23800.00, 450.00, 0.00, 2910.00, 27160.00, 27160.00, 27160.00, 0.00,
  'Extra bed for child',
  'Booked by Sneha Kulkarni - repeat guest.',
  NULL, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '14:16:00'),
  NULL,
  7, NULL,
  1, DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (25, 'UN-24025', 5, 5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 2, 'OTA',
  'CONFIRMED', 'PARTIALLY_PAID', 5400.00, 0.00, 0.00, 648.00, 6048.00, 1814.00, 1814.00, 4234.00,
  'Airport pickup required',
  'Booked by Michael Chen - new guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  7, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (26, 'GV-24026', 1, 6, DATE_ADD(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 0, 'OTA',
  'CONFIRMED', 'UNPAID', 46200.00, 0.00, 2310.00, 5266.80, 49156.80, 0.00, 0.00, 49156.80,
  'Extra bed for child',
  'Booked by Anjali Deshmukh - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  8, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (27, 'PB-24027', 2, 7, DATE_ADD(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 1, 1, 'CORPORATE',
  'CONFIRMED', 'UNPAID', 8000.00, 0.00, 0.00, 960.00, 8960.00, 0.00, 0.00, 8960.00,
  'Early breakfast at 7 AM',
  'Booked by Vikram Singh Rathore - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  2, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (28, 'HP-24028', 3, 8, DATE_ADD(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 2, 2, 'PHONE',
  'PENDING', 'PARTIALLY_PAID', 29200.00, 0.00, 0.00, 5256.00, 34456.00, 10337.00, 10337.00, 24119.00,
  'Airport pickup required',
  'Booked by Emily Watson - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  2, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (29, 'AC-24029', 4, 9, DATE_ADD(CURDATE(), INTERVAL 4 DAY), DATE_ADD(CURDATE(), INTERVAL 6 DAY), 2, 0, 'DIRECT',
  'CONFIRMED', 'UNPAID', 14800.00, 0.00, 0.00, 1776.00, 16576.00, 0.00, 0.00, 16576.00,
  'Extra bed for child',
  'Booked by Sanjay Gupta - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  8, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (30, 'UN-24030', 5, 10, DATE_ADD(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 8 DAY), 3, 0, 'CORPORATE',
  'CONFIRMED', 'UNPAID', 24600.00, 0.00, 0.00, 2952.00, 27552.00, 0.00, 0.00, 27552.00,
  'Quiet room away from elevator',
  'Booked by Pooja Iyer - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  3, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (31, 'GV-24031', 1, 11, DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 3, 1, 'PHONE',
  'CONFIRMED', 'PARTIALLY_PAID', 10200.00, 0.00, 0.00, 1224.00, 11424.00, 3427.00, 3427.00, 7997.00,
  NULL,
  'Booked by Arjun Malhotra - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  8, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (32, 'PB-24032', 2, 12, DATE_ADD(CURDATE(), INTERVAL 9 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 2, 0, 'AGENT',
  'CONFIRMED', 'PARTIALLY_PAID', 60000.00, 0.00, 0.00, 7200.00, 67200.00, 20160.00, 20160.00, 47040.00,
  'Extra bed for child',
  'Booked by Kavita Nair - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  1, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (33, 'HP-24033', 3, 13, DATE_ADD(CURDATE(), INTERVAL 11 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), 1, 0, 'OTA',
  'PENDING', 'UNPAID', 9000.00, 0.00, 0.00, 1620.00, 10620.00, 0.00, 0.00, 10620.00,
  'Quiet room away from elevator',
  'Booked by Rohan Joshi - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  2, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (34, 'AC-24034', 4, 14, DATE_ADD(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 17 DAY), 2, 0, 'WEBSITE',
  'CONFIRMED', 'PARTIALLY_PAID', 14700.00, 0.00, 0.00, 1764.00, 16464.00, 4939.00, 4939.00, 11525.00,
  'Airport pickup required',
  'Booked by Tara Bhandari - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  1, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (35, 'UN-24035', 5, 15, DATE_ADD(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 3, 2, 'OTA',
  'CONFIRMED', 'UNPAID', 13200.00, 0.00, 0.00, 1584.00, 14784.00, 0.00, 0.00, 14784.00,
  'Quiet room away from elevator',
  'Booked by Daniel Pereira - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  2, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (36, 'GV-24036', 1, 16, DATE_ADD(CURDATE(), INTERVAL 21 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 3, 2, 'PHONE',
  'CONFIRMED', 'PARTIALLY_PAID', 33200.00, 0.00, 0.00, 3984.00, 37184.00, 11155.00, 11155.00, 26029.00,
  'Early breakfast at 7 AM',
  'Booked by Aisha Khan - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  7, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (37, 'PB-24037', 2, 17, DATE_ADD(CURDATE(), INTERVAL 26 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 1, 0, 'DIRECT',
  'CONFIRMED', 'UNPAID', 8000.00, 0.00, 0.00, 960.00, 8960.00, 0.00, 0.00, 8960.00,
  NULL,
  'Booked by Nikhil Bansal - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  9, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (38, 'HP-24038', 3, 18, DATE_ADD(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 3, 0, 'DIRECT',
  'CONFIRMED', 'PARTIALLY_PAID', 13500.00, 0.00, 0.00, 2430.00, 15930.00, 4779.00, 4779.00, 11151.00,
  'Quiet room away from elevator',
  'Booked by Priyanka Reddy - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  7, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (39, 'AC-24039', 4, 19, DATE_ADD(CURDATE(), INTERVAL 35 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 2, 2, 'WALK_IN',
  'CONFIRMED', 'PARTIALLY_PAID', 23800.00, 0.00, 1190.00, 2713.20, 25323.20, 7597.00, 7597.00, 17726.20,
  'Extra bed for child',
  'Booked by Sunil Agarwal - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  1, DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO bookings (id, booking_code, hotel_id, guest_id, check_in_date, check_out_date, adults, children, booking_source,
  status, payment_status, room_charge_total, extra_charges, discount_amount, tax_amount, total_amount, advance_amount, paid_amount, pending_amount,
  special_requests, internal_notes, cancellation_reason, cancelled_at, actual_check_in_at, actual_check_out_at, checked_in_by, checked_out_by, created_by, created_at, updated_at)
VALUES (40, 'UN-24040', 5, 20, DATE_ADD(CURDATE(), INTERVAL 42 DAY), DATE_ADD(CURDATE(), INTERVAL 45 DAY), 2, 1, 'CORPORATE',
  'CONFIRMED', 'PARTIALLY_PAID', 19800.00, 0.00, 0.00, 2376.00, 22176.00, 6653.00, 6653.00, 15523.00,
  'Airport pickup required',
  'Booked by Nandini Rao - repeat guest.',
  NULL, NULL,
  NULL,
  NULL,
  NULL, NULL,
  2, DATE_SUB(@now, INTERVAL 1 DAY), @now);

INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (1, 1, 16, 4, DATE_ADD(CURDATE(), INTERVAL -45 DAY), DATE_ADD(CURDATE(), INTERVAL -42 DAY), 3, 20000.00, 0.00, 0, 60000.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 47 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (2, 2, 28, 7, DATE_ADD(CURDATE(), INTERVAL -38 DAY), DATE_ADD(CURDATE(), INTERVAL -36 DAY), 2, 6500.00, 0.00, 0, 13000.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 40 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (3, 3, 50, 13, DATE_ADD(CURDATE(), INTERVAL -30 DAY), DATE_ADD(CURDATE(), INTERVAL -26 DAY), 4, 10900.00, 0.00, 0, 43600.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 32 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (4, 4, 79, 20, DATE_ADD(CURDATE(), INTERVAL -25 DAY), DATE_ADD(CURDATE(), INTERVAL -24 DAY), 1, 9100.00, 0.00, 0, 9100.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 27 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (5, 5, 86, 22, DATE_ADD(CURDATE(), INTERVAL -21 DAY), DATE_ADD(CURDATE(), INTERVAL -18 DAY), 3, 4400.00, 0.00, 0, 13200.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 23 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (6, 6, 4, 1, DATE_ADD(CURDATE(), INTERVAL -16 DAY), DATE_ADD(CURDATE(), INTERVAL -14 DAY), 2, 5100.00, 0.00, 0, 10200.00, 'CANCELLED', DATE_SUB(@now, INTERVAL 18 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (7, 7, 26, 7, DATE_ADD(CURDATE(), INTERVAL -14 DAY), DATE_ADD(CURDATE(), INTERVAL -12 DAY), 2, 6500.00, 0.00, 0, 13000.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 16 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (8, 8, 45, 12, DATE_ADD(CURDATE(), INTERVAL -12 DAY), DATE_ADD(CURDATE(), INTERVAL -7 DAY), 5, 7300.00, 0.00, 0, 36500.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 14 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (9, 9, 73, 19, DATE_ADD(CURDATE(), INTERVAL -9 DAY), DATE_ADD(CURDATE(), INTERVAL -7 DAY), 2, 11900.00, 0.00, 0, 23800.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 11 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (10, 10, 96, 24, DATE_ADD(CURDATE(), INTERVAL -7 DAY), DATE_ADD(CURDATE(), INTERVAL -4 DAY), 3, 10600.00, 0.00, 0, 31800.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 9 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (11, 11, 20, 5, DATE_ADD(CURDATE(), INTERVAL -6 DAY), DATE_ADD(CURDATE(), INTERVAL -4 DAY), 2, 15400.00, 0.00, 0, 30800.00, 'RESERVED', DATE_SUB(@now, INTERVAL 8 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (12, 12, 37, 10, DATE_ADD(CURDATE(), INTERVAL -5 DAY), DATE_ADD(CURDATE(), INTERVAL -1 DAY), 4, 12000.00, 0.00, 0, 48000.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 7 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (13, 13, 55, 14, DATE_ADD(CURDATE(), INTERVAL -4 DAY), DATE_ADD(CURDATE(), INTERVAL -2 DAY), 2, 17500.00, 0.00, 0, 35000.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 6 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (14, 14, 74, 19, DATE_ADD(CURDATE(), INTERVAL -3 DAY), DATE_ADD(CURDATE(), INTERVAL -1 DAY), 2, 11900.00, 0.00, 0, 23800.00, 'CHECKED_OUT', DATE_SUB(@now, INTERVAL 5 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (15, 15, 83, 21, DATE_ADD(CURDATE(), INTERVAL -2 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 3, 2700.00, 0.00, 0, 8100.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 4 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (16, 16, 19, 5, DATE_ADD(CURDATE(), INTERVAL -2 DAY), DATE_ADD(CURDATE(), INTERVAL 0 DAY), 2, 15400.00, 0.00, 0, 30800.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 4 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (17, 17, 24, 6, DATE_ADD(CURDATE(), INTERVAL -1 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 3, 4000.00, 0.00, 0, 12000.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 3 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (18, 18, 41, 11, DATE_ADD(CURDATE(), INTERVAL -1 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 2, 4500.00, 0.00, 0, 9000.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 3 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (19, 19, 68, 17, DATE_ADD(CURDATE(), INTERVAL -1 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 4, 4900.00, 0.00, 0, 19600.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 3 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (20, 20, 86, 22, DATE_ADD(CURDATE(), INTERVAL -3 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 5, 4400.00, 0.00, 0, 22000.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 5 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (21, 21, 10, 3, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 2, 12500.00, 0.00, 0, 25000.00, 'RESERVED', DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (22, 22, 23, 6, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 3, 4000.00, 0.00, 0, 12000.00, 'RESERVED', DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (23, 23, 55, 14, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 1 DAY), 1, 17500.00, 0.00, 0, 17500.00, 'RESERVED', DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (24, 24, 74, 19, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 2 DAY), 2, 11900.00, 0.00, 0, 23800.00, 'CHECKED_IN', DATE_SUB(@now, INTERVAL 2 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (25, 25, 81, 21, DATE_ADD(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 3 DAY), 2, 2700.00, 0.00, 0, 5400.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (26, 26, 19, 5, DATE_ADD(CURDATE(), INTERVAL 1 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 3, 15400.00, 0.00, 0, 46200.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (27, 27, 22, 6, DATE_ADD(CURDATE(), INTERVAL 2 DAY), DATE_ADD(CURDATE(), INTERVAL 4 DAY), 2, 4000.00, 0.00, 0, 8000.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (28, 28, 45, 12, DATE_ADD(CURDATE(), INTERVAL 3 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 4, 7300.00, 0.00, 0, 29200.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (29, 29, 72, 18, DATE_ADD(CURDATE(), INTERVAL 4 DAY), DATE_ADD(CURDATE(), INTERVAL 6 DAY), 2, 7400.00, 0.00, 0, 14800.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (30, 30, 99, 25, DATE_ADD(CURDATE(), INTERVAL 5 DAY), DATE_ADD(CURDATE(), INTERVAL 8 DAY), 3, 8200.00, 0.00, 0, 24600.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (31, 31, 4, 1, DATE_ADD(CURDATE(), INTERVAL 7 DAY), DATE_ADD(CURDATE(), INTERVAL 9 DAY), 2, 5100.00, 0.00, 0, 10200.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (32, 32, 37, 10, DATE_ADD(CURDATE(), INTERVAL 9 DAY), DATE_ADD(CURDATE(), INTERVAL 14 DAY), 5, 12000.00, 0.00, 0, 60000.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (33, 33, 43, 11, DATE_ADD(CURDATE(), INTERVAL 11 DAY), DATE_ADD(CURDATE(), INTERVAL 13 DAY), 2, 4500.00, 0.00, 0, 9000.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (34, 34, 67, 17, DATE_ADD(CURDATE(), INTERVAL 14 DAY), DATE_ADD(CURDATE(), INTERVAL 17 DAY), 3, 4900.00, 0.00, 0, 14700.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (35, 35, 91, 23, DATE_ADD(CURDATE(), INTERVAL 18 DAY), DATE_ADD(CURDATE(), INTERVAL 20 DAY), 2, 6600.00, 0.00, 0, 13200.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (36, 36, 5, 2, DATE_ADD(CURDATE(), INTERVAL 21 DAY), DATE_ADD(CURDATE(), INTERVAL 25 DAY), 4, 8300.00, 0.00, 0, 33200.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (37, 37, 21, 6, DATE_ADD(CURDATE(), INTERVAL 26 DAY), DATE_ADD(CURDATE(), INTERVAL 28 DAY), 2, 4000.00, 0.00, 0, 8000.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (38, 38, 44, 11, DATE_ADD(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL 33 DAY), 3, 4500.00, 0.00, 0, 13500.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (39, 39, 76, 19, DATE_ADD(CURDATE(), INTERVAL 35 DAY), DATE_ADD(CURDATE(), INTERVAL 37 DAY), 2, 11900.00, 0.00, 0, 23800.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);
INSERT INTO booking_rooms (id, booking_id, room_id, room_category_id, check_in_date, check_out_date, nights, rate_per_night, extra_person_charge, extra_bed_count, total_amount, status, created_at, updated_at)
VALUES (40, 40, 90, 23, DATE_ADD(CURDATE(), INTERVAL 42 DAY), DATE_ADD(CURDATE(), INTERVAL 45 DAY), 3, 6600.00, 0.00, 0, 19800.00, 'RESERVED', DATE_SUB(@now, INTERVAL 1 DAY), @now);

INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (1, 1, 1, b'1', DATE_SUB(@now, INTERVAL 47 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (2, 2, 2, b'1', DATE_SUB(@now, INTERVAL 40 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (3, 3, 3, b'1', DATE_SUB(@now, INTERVAL 32 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (4, 4, 4, b'1', DATE_SUB(@now, INTERVAL 27 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (5, 5, 5, b'1', DATE_SUB(@now, INTERVAL 23 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (6, 6, 6, b'1', DATE_SUB(@now, INTERVAL 18 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (7, 7, 7, b'1', DATE_SUB(@now, INTERVAL 16 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (8, 8, 8, b'1', DATE_SUB(@now, INTERVAL 14 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (9, 9, 9, b'1', DATE_SUB(@now, INTERVAL 11 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (10, 10, 10, b'1', DATE_SUB(@now, INTERVAL 9 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (11, 11, 11, b'1', DATE_SUB(@now, INTERVAL 8 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (12, 12, 12, b'1', DATE_SUB(@now, INTERVAL 7 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (13, 13, 13, b'1', DATE_SUB(@now, INTERVAL 6 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (14, 14, 14, b'1', DATE_SUB(@now, INTERVAL 5 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (15, 15, 15, b'1', DATE_SUB(@now, INTERVAL 4 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (16, 16, 16, b'1', DATE_SUB(@now, INTERVAL 4 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (17, 17, 17, b'1', DATE_SUB(@now, INTERVAL 3 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (18, 18, 18, b'1', DATE_SUB(@now, INTERVAL 3 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (19, 19, 19, b'1', DATE_SUB(@now, INTERVAL 3 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (20, 20, 20, b'1', DATE_SUB(@now, INTERVAL 5 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (21, 21, 1, b'1', DATE_SUB(@now, INTERVAL 2 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (22, 22, 2, b'1', DATE_SUB(@now, INTERVAL 2 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (23, 23, 3, b'1', DATE_SUB(@now, INTERVAL 2 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (24, 24, 4, b'1', DATE_SUB(@now, INTERVAL 2 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (25, 25, 5, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (26, 26, 6, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (27, 27, 7, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (28, 28, 8, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (29, 29, 9, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (30, 30, 10, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (31, 31, 11, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (32, 32, 12, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (33, 33, 13, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (34, 34, 14, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (35, 35, 15, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (36, 36, 16, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (37, 37, 17, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (38, 38, 18, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (39, 39, 19, b'1', DATE_SUB(@now, INTERVAL 1 DAY));
INSERT INTO booking_guests (id, booking_id, guest_id, primary_guest, created_at) VALUES (40, 40, 20, b'1', DATE_SUB(@now, INTERVAL 1 DAY));

INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (1, 'PAY-90001', 1, 1, NULL, 65856.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-308704', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -46 DAY), '10:27:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -46 DAY), '10:27:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (2, 'PAY-90002', 2, 2, NULL, 14336.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-582003', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -39 DAY), '18:46:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -39 DAY), '18:46:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (3, 'PAY-90003', 3, 3, NULL, 53572.00, 'ONLINE', 'FULL', 'SUCCESS',
  'ONL-TXN-328218', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -31 DAY), '16:26:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -31 DAY), '16:26:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (4, 'PAY-90004', 4, 4, NULL, 11704.00, 'ONLINE', 'FULL', 'SUCCESS',
  'ONL-TXN-947974', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -26 DAY), '17:46:00'), 9, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -26 DAY), '17:46:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (5, 'PAY-90005', 5, 5, NULL, 16800.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-396710', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -22 DAY), '15:56:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -22 DAY), '15:56:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (6, 'PAY-90006', 2, 7, NULL, 15064.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-477909', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -15 DAY), '18:55:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -15 DAY), '18:55:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (7, 'PAY-90007', 3, 8, NULL, 43601.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-694454', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -13 DAY), '10:14:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -13 DAY), '10:14:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (8, 'PAY-90008', 4, 9, NULL, 25827.20, 'BANK_TRANSFER', 'FULL', 'SUCCESS',
  'BAN-TXN-335135', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -10 DAY), '15:09:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -10 DAY), '15:09:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (9, 'PAY-90009', 5, 10, NULL, 36624.00, 'BANK_TRANSFER', 'FULL', 'SUCCESS',
  'BAN-TXN-549188', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -8 DAY), '11:47:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -8 DAY), '11:47:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (10, 'PAY-90010', 2, 12, NULL, 55272.00, 'CARD', 'FULL', 'SUCCESS',
  'CAR-TXN-785313', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:29:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:29:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (11, 'PAY-90011', 3, 13, NULL, 42893.00, 'ONLINE', 'FULL', 'SUCCESS',
  'ONL-TXN-749011', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '16:11:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '16:11:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (12, 'PAY-90012', 4, 14, NULL, 28672.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-519742', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:45:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:45:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (13, 'PAY-90013', 5, 15, NULL, 11088.00, 'CARD', 'FULL', 'SUCCESS',
  'CAR-TXN-273347', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:03:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:03:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (14, 'PAY-90014', 1, 16, NULL, 36512.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-331877', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '14:03:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '14:03:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (15, 'PAY-90015', 2, 17, NULL, 14280.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-618535', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '11:37:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '11:37:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (16, 'PAY-90016', 3, 18, NULL, 11682.00, 'BANK_TRANSFER', 'FULL', 'SUCCESS',
  'BAN-TXN-586130', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '15:20:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '15:20:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (17, 'PAY-90017', 4, 19, NULL, 23968.00, 'CARD', 'FULL', 'SUCCESS',
  'CAR-TXN-519615', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '12:31:00'), 9, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '12:31:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (18, 'PAY-90018', 5, 20, NULL, 26152.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-143027', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:06:00'), 9, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:06:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (19, 'PAY-90019', 3, 23, NULL, 6195.00, 'CARD', 'ADVANCE', 'SUCCESS',
  'CAR-TXN-994864', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '14:14:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '14:14:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (20, 'PAY-90020', 4, 24, NULL, 27160.00, 'UPI', 'FULL', 'SUCCESS',
  'UPI-TXN-129769', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:54:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:54:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (21, 'PAY-90021', 5, 25, NULL, 1814.00, 'CASH', 'ADVANCE', 'SUCCESS',
  'CASH-21', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '16:51:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '16:51:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (22, 'PAY-90022', 3, 28, NULL, 10337.00, 'CARD', 'ADVANCE', 'SUCCESS',
  'CAR-TXN-540519', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:42:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:42:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (23, 'PAY-90023', 1, 31, NULL, 3427.00, 'UPI', 'ADVANCE', 'SUCCESS',
  'UPI-TXN-488248', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '13:14:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '13:14:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (24, 'PAY-90024', 2, 32, NULL, 20160.00, 'CASH', 'ADVANCE', 'SUCCESS',
  'CASH-24', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '16:44:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '16:44:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (25, 'PAY-90025', 4, 34, NULL, 4939.00, 'ONLINE', 'ADVANCE', 'SUCCESS',
  'ONL-TXN-313715', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '12:15:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '12:15:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (26, 'PAY-90026', 1, 36, NULL, 11155.00, 'CASH', 'ADVANCE', 'SUCCESS',
  'CASH-26', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '15:23:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '15:23:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (27, 'PAY-90027', 3, 38, NULL, 4779.00, 'UPI', 'ADVANCE', 'SUCCESS',
  'UPI-TXN-386989', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:32:00'), 9, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:32:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (28, 'PAY-90028', 4, 39, NULL, 7597.00, 'CASH', 'ADVANCE', 'SUCCESS',
  'CASH-28', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '10:50:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '10:50:00'), @now);
INSERT INTO payments (id, payment_code, hotel_id, booking_id, invoice_id, amount, method, payment_type, status, reference_no, notes, paid_at, received_by, created_at, updated_at)
VALUES (29, 'PAY-90029', 5, 40, NULL, 6653.00, 'BANK_TRANSFER', 'ADVANCE', 'SUCCESS',
  'BAN-TXN-434297', 'Collected at front desk', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:52:00'), 13, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:52:00'), @now);

INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (1, 'INV-GV-10001', 1, 1, 1, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 61800.00, 3000.00, 12.00,
  7056.00, 65856.00, 65856.00, 0.00, 'PAID', '27AABCG1234M1Z5',
  'Aarav Kapoor', 'Mumbai, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (2, 'INV-PB-10002', 2, 2, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 13450.00, 650.00, 12.00,
  1536.00, 14336.00, 14336.00, 0.00, 'PAID', '30AABCP5678R1Z2',
  'Ishita Menon', 'Bengaluru, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (3, 'INV-HP-10003', 3, 3, 3, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 45400.00, 0.00, 18.00,
  8172.00, 53572.00, 53572.00, 0.00, 'PAID', '08AABCH9012P1Z9',
  'Rahul Bhatia', 'Pune, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (4, 'INV-AC-10004', 4, 4, 4, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 10450.00, 0.00, 12.00,
  1254.00, 11704.00, 11704.00, 0.00, 'PAID', '02AABCA3456K1Z7',
  'Sneha Kulkarni', 'Pune, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (5, 'INV-UN-10005', 5, 5, 5, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 15000.00, 0.00, 12.00,
  1800.00, 16800.00, 16800.00, 0.00, 'PAID', '27AABCU7890L1Z3',
  'Michael Chen', 'Singapore, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (6, 'INV-PB-10006', 2, 7, 7, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 13450.00, 0.00, 12.00,
  1614.00, 15064.00, 15064.00, 0.00, 'PAID', '30AABCP5678R1Z2',
  'Vikram Singh Rathore', 'Jaipur, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (7, 'INV-HP-10007', 3, 8, 8, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 36950.00, 0.00, 18.00,
  6651.00, 43601.00, 43601.00, 0.00, 'PAID', '08AABCH9012P1Z9',
  'Emily Watson', 'London, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (8, 'INV-AC-10008', 4, 9, 9, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 24250.00, 1190.00, 12.00,
  2767.20, 25827.20, 25827.20, 0.00, 'PAID', '02AABCA3456K1Z7',
  'Sanjay Gupta', 'Delhi, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (9, 'INV-UN-10009', 5, 10, 10, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 32700.00, 0.00, 12.00,
  3924.00, 36624.00, 36624.00, 0.00, 'PAID', '27AABCU7890L1Z3',
  'Pooja Iyer', 'Chennai, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (10, 'INV-PB-10010', 2, 12, 12, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 49350.00, 0.00, 12.00,
  5922.00, 55272.00, 55272.00, 0.00, 'PAID', '30AABCP5678R1Z2',
  'Kavita Nair', 'Kochi, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (11, 'INV-HP-10011', 3, 13, 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 36350.00, 0.00, 18.00,
  6543.00, 42893.00, 42893.00, 0.00, 'PAID', '08AABCH9012P1Z9',
  'Rohan Joshi', 'Thane, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (12, 'INV-AC-10012', 4, 14, 14, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 25600.00, 0.00, 12.00,
  3072.00, 28672.00, 28672.00, 0.00, 'PAID', '02AABCA3456K1Z7',
  'Tara Bhandari', 'Mumbai, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (13, 'INV-UN-10013', 5, 15, 15, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 9900.00, 0.00, 12.00,
  1188.00, 11088.00, 11088.00, 0.00, 'PAID', '27AABCU7890L1Z3',
  'Daniel Pereira', 'Goa, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (14, 'INV-GV-10014', 1, 16, 16, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 32600.00, 0.00, 12.00,
  3912.00, 36512.00, 36512.00, 0.00, 'PAID', '27AABCG1234M1Z5',
  'Aisha Khan', 'Mumbai, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (15, 'INV-PB-10015', 2, 17, 17, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 13350.00, 600.00, 12.00,
  1530.00, 14280.00, 14280.00, 0.00, 'PAID', '30AABCP5678R1Z2',
  'Nikhil Bansal', 'Gurugram, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (16, 'INV-HP-10016', 3, 18, 18, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 10350.00, 450.00, 18.00,
  1782.00, 11682.00, 11682.00, 0.00, 'PAID', '08AABCH9012P1Z9',
  'Priyanka Reddy', 'Hyderabad, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (17, 'INV-AC-10017', 4, 19, 19, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 21400.00, 0.00, 12.00,
  2568.00, 23968.00, 23968.00, 0.00, 'PAID', '02AABCA3456K1Z7',
  'Sunil Agarwal', 'Kolkata, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (18, 'INV-UN-10018', 5, 20, 20, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 23350.00, 0.00, 12.00,
  2802.00, 26152.00, 26152.00, 0.00, 'PAID', '27AABCU7890L1Z3',
  'Nandini Rao', 'Bengaluru, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO invoices (id, invoice_number, hotel_id, booking_id, guest_id, issue_date, due_date, subtotal, discount, tax_rate, tax_amount, total, amount_paid, balance, status, gstin, bill_to_name, bill_to_address, notes, created_by, created_at, updated_at)
VALUES (19, 'INV-AC-10019', 4, 24, 4, DATE_ADD(CURDATE(), INTERVAL 0 DAY), DATE_ADD(CURDATE(), INTERVAL 7 DAY), 24250.00, 0.00, 12.00,
  2910.00, 27160.00, 27160.00, 0.00, 'PAID', '02AABCA3456K1Z7',
  'Sneha Kulkarni', 'Pune, India', 'Thank you for staying with us.', 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);

INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (1, 1, 'ROOM', 'Suite room 242 - 3 night(s) @ 20000.00', 3.00, 20000.00, 60000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (2, 1, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (3, 2, 'ROOM', 'Deluxe room 222 - 2 night(s) @ 6500.00', 2.00, 6500.00, 13000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (4, 2, 'SERVICE', 'Restaurant & room service charges', 1.00, 450.00, 450.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (5, 3, 'ROOM', 'Premium room 132 - 4 night(s) @ 10900.00', 4.00, 10900.00, 43600.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (6, 3, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (7, 4, 'ROOM', 'Family Room room 251 - 1 night(s) @ 9100.00', 1.00, 9100.00, 9100.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (8, 4, 'SERVICE', 'Restaurant & room service charges', 1.00, 1350.00, 1350.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (9, 5, 'ROOM', 'Deluxe room 122 - 3 night(s) @ 4400.00', 3.00, 4400.00, 13200.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (10, 5, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (11, 6, 'ROOM', 'Deluxe room 122 - 2 night(s) @ 6500.00', 2.00, 6500.00, 13000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (12, 6, 'SERVICE', 'Restaurant & room service charges', 1.00, 450.00, 450.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (13, 7, 'ROOM', 'Deluxe room 121 - 5 night(s) @ 7300.00', 5.00, 7300.00, 36500.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (14, 7, 'SERVICE', 'Restaurant & room service charges', 1.00, 450.00, 450.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (15, 8, 'ROOM', 'Suite room 141 - 2 night(s) @ 11900.00', 2.00, 11900.00, 23800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (16, 8, 'SERVICE', 'Restaurant & room service charges', 1.00, 450.00, 450.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (17, 9, 'ROOM', 'Suite room 242 - 3 night(s) @ 10600.00', 3.00, 10600.00, 31800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (18, 9, 'SERVICE', 'Restaurant & room service charges', 1.00, 900.00, 900.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (19, 10, 'ROOM', 'Family Room room 151 - 4 night(s) @ 12000.00', 4.00, 12000.00, 48000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (20, 10, 'SERVICE', 'Restaurant & room service charges', 1.00, 1350.00, 1350.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (21, 11, 'ROOM', 'Suite room 241 - 2 night(s) @ 17500.00', 2.00, 17500.00, 35000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (22, 11, 'SERVICE', 'Restaurant & room service charges', 1.00, 1350.00, 1350.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (23, 12, 'ROOM', 'Suite room 142 - 2 night(s) @ 11900.00', 2.00, 11900.00, 23800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (24, 12, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (25, 13, 'ROOM', 'Standard room 211 - 3 night(s) @ 2700.00', 3.00, 2700.00, 8100.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (26, 13, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (27, 14, 'ROOM', 'Family Room room 251 - 2 night(s) @ 15400.00', 2.00, 15400.00, 30800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (28, 14, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (29, 15, 'ROOM', 'Standard room 212 - 3 night(s) @ 4000.00', 3.00, 4000.00, 12000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (30, 15, 'SERVICE', 'Restaurant & room service charges', 1.00, 1350.00, 1350.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (31, 16, 'ROOM', 'Standard room 111 - 2 night(s) @ 4500.00', 2.00, 4500.00, 9000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (32, 16, 'SERVICE', 'Restaurant & room service charges', 1.00, 1350.00, 1350.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (33, 17, 'ROOM', 'Deluxe room 222 - 4 night(s) @ 4900.00', 4.00, 4900.00, 19600.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (34, 17, 'SERVICE', 'Restaurant & room service charges', 1.00, 1800.00, 1800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (35, 18, 'ROOM', 'Deluxe room 122 - 5 night(s) @ 4400.00', 5.00, 4400.00, 22000.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (36, 18, 'SERVICE', 'Restaurant & room service charges', 1.00, 1350.00, 1350.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (37, 19, 'ROOM', 'Suite room 142 - 2 night(s) @ 11900.00', 2.00, 11900.00, 23800.00);
INSERT INTO invoice_lines (id, invoice_id, line_type, description, quantity, unit_price, amount) VALUES (38, 19, 'SERVICE', 'Restaurant & room service charges', 1.00, 450.00, 450.00);

INSERT INTO refunds (id, hotel_id, payment_id, booking_id, amount, reason, method, status, processed_by, processed_at, created_at)
VALUES (1, 1, NULL, 6, 0.00, 'Booking cancelled by guest - no advance taken', 'CASH', 'COMPLETED', 13, DATE_SUB(@now, INTERVAL 5 DAY), DATE_SUB(@now, INTERVAL 5 DAY));

-- rooms currently occupied by in-house guests
UPDATE rooms SET status = 'OCCUPIED', housekeeping_status = 'CLEAN' WHERE id IN (83, 19, 24, 41, 68, 86, 74);
UPDATE rooms SET housekeeping_status = 'DIRTY' WHERE id IN (1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13);

INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (1, 1, 'ELECTRICITY', 'electricity expense - Grand Vista Mumbai', 87900.00, DATE_ADD(CURDATE(), INTERVAL -14 DAY),
  'Maharashtra State Electricity Board', 'BANK_TRANSFER', 'EXP-1001', 13, DATE_ADD(CURDATE(), INTERVAL -14 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (2, 1, 'WATER', 'water expense - Grand Vista Mumbai', 13300.00, DATE_ADD(CURDATE(), INTERVAL -8 DAY),
  'City Water Works', 'CASH', 'EXP-1002', 13, DATE_ADD(CURDATE(), INTERVAL -8 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (3, 1, 'MAINTENANCE', 'maintenance expense - Grand Vista Mumbai', 7000.00, DATE_ADD(CURDATE(), INTERVAL -5 DAY),
  'TechFix Facilities', 'UPI', 'EXP-1003', 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (4, 1, 'SALARY', 'salary expense - Grand Vista Mumbai', 205450.00, DATE_ADD(CURDATE(), INTERVAL -17 DAY),
  'Payroll', 'BANK_TRANSFER', 'EXP-1004', 13, DATE_ADD(CURDATE(), INTERVAL -17 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (5, 1, 'FOOD_SUPPLIES', 'food supplies expense - Grand Vista Mumbai', 86550.00, DATE_ADD(CURDATE(), INTERVAL -27 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1005', 13, DATE_ADD(CURDATE(), INTERVAL -27 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (6, 1, 'LAUNDRY', 'laundry expense - Grand Vista Mumbai', 25300.00, DATE_ADD(CURDATE(), INTERVAL -4 DAY),
  'CleanPro Laundry', 'CASH', 'EXP-1006', 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (7, 1, 'VENDOR', 'vendor expense - Grand Vista Mumbai', 7050.00, DATE_ADD(CURDATE(), INTERVAL -17 DAY),
  'Hotel Essentials Pvt Ltd', 'CASH', 'EXP-1007', 13, DATE_ADD(CURDATE(), INTERVAL -17 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (8, 1, 'OTHER', 'other expense - Grand Vista Mumbai', 20750.00, DATE_ADD(CURDATE(), INTERVAL -5 DAY),
  'Miscellaneous', 'CARD', 'EXP-1008', 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (9, 2, 'ELECTRICITY', 'electricity expense - Palm Bay Resort Goa', 68700.00, DATE_ADD(CURDATE(), INTERVAL -14 DAY),
  'Maharashtra State Electricity Board', 'CARD', 'EXP-1009', 13, DATE_ADD(CURDATE(), INTERVAL -14 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (10, 2, 'WATER', 'water expense - Palm Bay Resort Goa', 17600.00, DATE_ADD(CURDATE(), INTERVAL -16 DAY),
  'City Water Works', 'BANK_TRANSFER', 'EXP-1010', 13, DATE_ADD(CURDATE(), INTERVAL -16 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (11, 2, 'MAINTENANCE', 'maintenance expense - Palm Bay Resort Goa', 13650.00, DATE_ADD(CURDATE(), INTERVAL -14 DAY),
  'TechFix Facilities', 'BANK_TRANSFER', 'EXP-1011', 13, DATE_ADD(CURDATE(), INTERVAL -14 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (12, 2, 'SALARY', 'salary expense - Palm Bay Resort Goa', 278650.00, DATE_ADD(CURDATE(), INTERVAL -8 DAY),
  'Payroll', 'BANK_TRANSFER', 'EXP-1012', 13, DATE_ADD(CURDATE(), INTERVAL -8 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (13, 2, 'FOOD_SUPPLIES', 'food supplies expense - Palm Bay Resort Goa', 107500.00, DATE_ADD(CURDATE(), INTERVAL -27 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1013', 13, DATE_ADD(CURDATE(), INTERVAL -27 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (14, 2, 'LAUNDRY', 'laundry expense - Palm Bay Resort Goa', 22600.00, DATE_ADD(CURDATE(), INTERVAL -15 DAY),
  'CleanPro Laundry', 'CARD', 'EXP-1014', 13, DATE_ADD(CURDATE(), INTERVAL -15 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (15, 2, 'VENDOR', 'vendor expense - Palm Bay Resort Goa', 15150.00, DATE_ADD(CURDATE(), INTERVAL -4 DAY),
  'Hotel Essentials Pvt Ltd', 'CASH', 'EXP-1015', 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (16, 2, 'OTHER', 'other expense - Palm Bay Resort Goa', 20400.00, DATE_ADD(CURDATE(), INTERVAL -20 DAY),
  'Miscellaneous', 'CASH', 'EXP-1016', 13, DATE_ADD(CURDATE(), INTERVAL -20 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (17, 3, 'ELECTRICITY', 'electricity expense - Heritage Palace Jaipur', 44050.00, DATE_ADD(CURDATE(), INTERVAL -20 DAY),
  'Maharashtra State Electricity Board', 'UPI', 'EXP-1017', 13, DATE_ADD(CURDATE(), INTERVAL -20 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (18, 3, 'WATER', 'water expense - Heritage Palace Jaipur', 9200.00, DATE_ADD(CURDATE(), INTERVAL -27 DAY),
  'City Water Works', 'BANK_TRANSFER', 'EXP-1018', 13, DATE_ADD(CURDATE(), INTERVAL -27 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (19, 3, 'MAINTENANCE', 'maintenance expense - Heritage Palace Jaipur', 5600.00, DATE_ADD(CURDATE(), INTERVAL -12 DAY),
  'TechFix Facilities', 'CASH', 'EXP-1019', 13, DATE_ADD(CURDATE(), INTERVAL -12 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (20, 3, 'SALARY', 'salary expense - Heritage Palace Jaipur', 211950.00, DATE_ADD(CURDATE(), INTERVAL -9 DAY),
  'Payroll', 'UPI', 'EXP-1020', 13, DATE_ADD(CURDATE(), INTERVAL -9 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (21, 3, 'FOOD_SUPPLIES', 'food supplies expense - Heritage Palace Jaipur', 104400.00, DATE_ADD(CURDATE(), INTERVAL -17 DAY),
  'Fresh Farm Supplies', 'CASH', 'EXP-1021', 13, DATE_ADD(CURDATE(), INTERVAL -17 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (22, 3, 'LAUNDRY', 'laundry expense - Heritage Palace Jaipur', 9300.00, DATE_ADD(CURDATE(), INTERVAL -23 DAY),
  'CleanPro Laundry', 'BANK_TRANSFER', 'EXP-1022', 13, DATE_ADD(CURDATE(), INTERVAL -23 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (23, 3, 'VENDOR', 'vendor expense - Heritage Palace Jaipur', 8250.00, DATE_ADD(CURDATE(), INTERVAL -2 DAY),
  'Hotel Essentials Pvt Ltd', 'BANK_TRANSFER', 'EXP-1023', 13, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (24, 3, 'OTHER', 'other expense - Heritage Palace Jaipur', 18100.00, DATE_ADD(CURDATE(), INTERVAL -22 DAY),
  'Miscellaneous', 'BANK_TRANSFER', 'EXP-1024', 13, DATE_ADD(CURDATE(), INTERVAL -22 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (25, 4, 'ELECTRICITY', 'electricity expense - Alpine Crest Manali', 90300.00, DATE_ADD(CURDATE(), INTERVAL -17 DAY),
  'Maharashtra State Electricity Board', 'BANK_TRANSFER', 'EXP-1025', 13, DATE_ADD(CURDATE(), INTERVAL -17 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (26, 4, 'WATER', 'water expense - Alpine Crest Manali', 4050.00, DATE_ADD(CURDATE(), INTERVAL -14 DAY),
  'City Water Works', 'UPI', 'EXP-1026', 13, DATE_ADD(CURDATE(), INTERVAL -14 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (27, 4, 'MAINTENANCE', 'maintenance expense - Alpine Crest Manali', 23800.00, DATE_ADD(CURDATE(), INTERVAL -17 DAY),
  'TechFix Facilities', 'UPI', 'EXP-1027', 13, DATE_ADD(CURDATE(), INTERVAL -17 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (28, 4, 'SALARY', 'salary expense - Alpine Crest Manali', 209450.00, DATE_ADD(CURDATE(), INTERVAL -17 DAY),
  'Payroll', 'UPI', 'EXP-1028', 13, DATE_ADD(CURDATE(), INTERVAL -17 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (29, 4, 'FOOD_SUPPLIES', 'food supplies expense - Alpine Crest Manali', 62000.00, DATE_ADD(CURDATE(), INTERVAL -16 DAY),
  'Fresh Farm Supplies', 'UPI', 'EXP-1029', 13, DATE_ADD(CURDATE(), INTERVAL -16 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (30, 4, 'LAUNDRY', 'laundry expense - Alpine Crest Manali', 8750.00, DATE_ADD(CURDATE(), INTERVAL -6 DAY),
  'CleanPro Laundry', 'BANK_TRANSFER', 'EXP-1030', 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (31, 4, 'VENDOR', 'vendor expense - Alpine Crest Manali', 12900.00, DATE_ADD(CURDATE(), INTERVAL -11 DAY),
  'Hotel Essentials Pvt Ltd', 'CARD', 'EXP-1031', 13, DATE_ADD(CURDATE(), INTERVAL -11 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (32, 4, 'OTHER', 'other expense - Alpine Crest Manali', 16350.00, DATE_ADD(CURDATE(), INTERVAL -14 DAY),
  'Miscellaneous', 'UPI', 'EXP-1032', 13, DATE_ADD(CURDATE(), INTERVAL -14 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (33, 5, 'ELECTRICITY', 'electricity expense - Urban Nest Pune', 59300.00, DATE_ADD(CURDATE(), INTERVAL -4 DAY),
  'Maharashtra State Electricity Board', 'BANK_TRANSFER', 'EXP-1033', 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (34, 5, 'WATER', 'water expense - Urban Nest Pune', 5850.00, DATE_ADD(CURDATE(), INTERVAL -9 DAY),
  'City Water Works', 'UPI', 'EXP-1034', 13, DATE_ADD(CURDATE(), INTERVAL -9 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (35, 5, 'MAINTENANCE', 'maintenance expense - Urban Nest Pune', 23200.00, DATE_ADD(CURDATE(), INTERVAL -11 DAY),
  'TechFix Facilities', 'BANK_TRANSFER', 'EXP-1035', 13, DATE_ADD(CURDATE(), INTERVAL -11 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (36, 5, 'SALARY', 'salary expense - Urban Nest Pune', 241350.00, DATE_ADD(CURDATE(), INTERVAL -22 DAY),
  'Payroll', 'CARD', 'EXP-1036', 13, DATE_ADD(CURDATE(), INTERVAL -22 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (37, 5, 'FOOD_SUPPLIES', 'food supplies expense - Urban Nest Pune', 70250.00, DATE_ADD(CURDATE(), INTERVAL -6 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1037', 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (38, 5, 'LAUNDRY', 'laundry expense - Urban Nest Pune', 10800.00, DATE_ADD(CURDATE(), INTERVAL -10 DAY),
  'CleanPro Laundry', 'CARD', 'EXP-1038', 13, DATE_ADD(CURDATE(), INTERVAL -10 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (39, 5, 'VENDOR', 'vendor expense - Urban Nest Pune', 20250.00, DATE_ADD(CURDATE(), INTERVAL -15 DAY),
  'Hotel Essentials Pvt Ltd', 'UPI', 'EXP-1039', 13, DATE_ADD(CURDATE(), INTERVAL -15 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (40, 5, 'OTHER', 'other expense - Urban Nest Pune', 14650.00, DATE_ADD(CURDATE(), INTERVAL -18 DAY),
  'Miscellaneous', 'BANK_TRANSFER', 'EXP-1040', 13, DATE_ADD(CURDATE(), INTERVAL -18 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (41, 1, 'ELECTRICITY', 'electricity expense - Grand Vista Mumbai', 80600.00, DATE_ADD(CURDATE(), INTERVAL -52 DAY),
  'Maharashtra State Electricity Board', 'BANK_TRANSFER', 'EXP-1041', 13, DATE_ADD(CURDATE(), INTERVAL -52 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (42, 1, 'WATER', 'water expense - Grand Vista Mumbai', 14800.00, DATE_ADD(CURDATE(), INTERVAL -49 DAY),
  'City Water Works', 'CARD', 'EXP-1042', 13, DATE_ADD(CURDATE(), INTERVAL -49 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (43, 1, 'MAINTENANCE', 'maintenance expense - Grand Vista Mumbai', 35000.00, DATE_ADD(CURDATE(), INTERVAL -39 DAY),
  'TechFix Facilities', 'CASH', 'EXP-1043', 13, DATE_ADD(CURDATE(), INTERVAL -39 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (44, 1, 'SALARY', 'salary expense - Grand Vista Mumbai', 385350.00, DATE_ADD(CURDATE(), INTERVAL -32 DAY),
  'Payroll', 'CASH', 'EXP-1044', 13, DATE_ADD(CURDATE(), INTERVAL -32 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (45, 1, 'FOOD_SUPPLIES', 'food supplies expense - Grand Vista Mumbai', 201650.00, DATE_ADD(CURDATE(), INTERVAL -50 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1045', 13, DATE_ADD(CURDATE(), INTERVAL -50 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (46, 1, 'LAUNDRY', 'laundry expense - Grand Vista Mumbai', 33750.00, DATE_ADD(CURDATE(), INTERVAL -42 DAY),
  'CleanPro Laundry', 'CASH', 'EXP-1046', 13, DATE_ADD(CURDATE(), INTERVAL -42 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (47, 1, 'VENDOR', 'vendor expense - Grand Vista Mumbai', 40300.00, DATE_ADD(CURDATE(), INTERVAL -51 DAY),
  'Hotel Essentials Pvt Ltd', 'CARD', 'EXP-1047', 13, DATE_ADD(CURDATE(), INTERVAL -51 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (48, 1, 'OTHER', 'other expense - Grand Vista Mumbai', 21400.00, DATE_ADD(CURDATE(), INTERVAL -46 DAY),
  'Miscellaneous', 'BANK_TRANSFER', 'EXP-1048', 13, DATE_ADD(CURDATE(), INTERVAL -46 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (49, 2, 'ELECTRICITY', 'electricity expense - Palm Bay Resort Goa', 133000.00, DATE_ADD(CURDATE(), INTERVAL -36 DAY),
  'Maharashtra State Electricity Board', 'UPI', 'EXP-1049', 13, DATE_ADD(CURDATE(), INTERVAL -36 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (50, 2, 'WATER', 'water expense - Palm Bay Resort Goa', 27500.00, DATE_ADD(CURDATE(), INTERVAL -48 DAY),
  'City Water Works', 'BANK_TRANSFER', 'EXP-1050', 13, DATE_ADD(CURDATE(), INTERVAL -48 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (51, 2, 'MAINTENANCE', 'maintenance expense - Palm Bay Resort Goa', 50950.00, DATE_ADD(CURDATE(), INTERVAL -43 DAY),
  'TechFix Facilities', 'UPI', 'EXP-1051', 13, DATE_ADD(CURDATE(), INTERVAL -43 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (52, 2, 'SALARY', 'salary expense - Palm Bay Resort Goa', 584100.00, DATE_ADD(CURDATE(), INTERVAL -31 DAY),
  'Payroll', 'CASH', 'EXP-1052', 13, DATE_ADD(CURDATE(), INTERVAL -31 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (53, 2, 'FOOD_SUPPLIES', 'food supplies expense - Palm Bay Resort Goa', 217300.00, DATE_ADD(CURDATE(), INTERVAL -41 DAY),
  'Fresh Farm Supplies', 'UPI', 'EXP-1053', 13, DATE_ADD(CURDATE(), INTERVAL -41 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (54, 2, 'LAUNDRY', 'laundry expense - Palm Bay Resort Goa', 39150.00, DATE_ADD(CURDATE(), INTERVAL -52 DAY),
  'CleanPro Laundry', 'CASH', 'EXP-1054', 13, DATE_ADD(CURDATE(), INTERVAL -52 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (55, 2, 'VENDOR', 'vendor expense - Palm Bay Resort Goa', 27400.00, DATE_ADD(CURDATE(), INTERVAL -41 DAY),
  'Hotel Essentials Pvt Ltd', 'CARD', 'EXP-1055', 13, DATE_ADD(CURDATE(), INTERVAL -41 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (56, 2, 'OTHER', 'other expense - Palm Bay Resort Goa', 47950.00, DATE_ADD(CURDATE(), INTERVAL -55 DAY),
  'Miscellaneous', 'CASH', 'EXP-1056', 13, DATE_ADD(CURDATE(), INTERVAL -55 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (57, 3, 'ELECTRICITY', 'electricity expense - Heritage Palace Jaipur', 182950.00, DATE_ADD(CURDATE(), INTERVAL -38 DAY),
  'Maharashtra State Electricity Board', 'CASH', 'EXP-1057', 13, DATE_ADD(CURDATE(), INTERVAL -38 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (58, 3, 'WATER', 'water expense - Heritage Palace Jaipur', 43550.00, DATE_ADD(CURDATE(), INTERVAL -53 DAY),
  'City Water Works', 'CARD', 'EXP-1058', 13, DATE_ADD(CURDATE(), INTERVAL -53 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (59, 3, 'MAINTENANCE', 'maintenance expense - Heritage Palace Jaipur', 34300.00, DATE_ADD(CURDATE(), INTERVAL -45 DAY),
  'TechFix Facilities', 'BANK_TRANSFER', 'EXP-1059', 13, DATE_ADD(CURDATE(), INTERVAL -45 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (60, 3, 'SALARY', 'salary expense - Heritage Palace Jaipur', 560700.00, DATE_ADD(CURDATE(), INTERVAL -46 DAY),
  'Payroll', 'CARD', 'EXP-1060', 13, DATE_ADD(CURDATE(), INTERVAL -46 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (61, 3, 'FOOD_SUPPLIES', 'food supplies expense - Heritage Palace Jaipur', 137150.00, DATE_ADD(CURDATE(), INTERVAL -32 DAY),
  'Fresh Farm Supplies', 'BANK_TRANSFER', 'EXP-1061', 13, DATE_ADD(CURDATE(), INTERVAL -32 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (62, 3, 'LAUNDRY', 'laundry expense - Heritage Palace Jaipur', 51850.00, DATE_ADD(CURDATE(), INTERVAL -56 DAY),
  'CleanPro Laundry', 'BANK_TRANSFER', 'EXP-1062', 13, DATE_ADD(CURDATE(), INTERVAL -56 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (63, 3, 'VENDOR', 'vendor expense - Heritage Palace Jaipur', 51200.00, DATE_ADD(CURDATE(), INTERVAL -37 DAY),
  'Hotel Essentials Pvt Ltd', 'UPI', 'EXP-1063', 13, DATE_ADD(CURDATE(), INTERVAL -37 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (64, 3, 'OTHER', 'other expense - Heritage Palace Jaipur', 17900.00, DATE_ADD(CURDATE(), INTERVAL -42 DAY),
  'Miscellaneous', 'CASH', 'EXP-1064', 13, DATE_ADD(CURDATE(), INTERVAL -42 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (65, 4, 'ELECTRICITY', 'electricity expense - Alpine Crest Manali', 146950.00, DATE_ADD(CURDATE(), INTERVAL -46 DAY),
  'Maharashtra State Electricity Board', 'CASH', 'EXP-1065', 13, DATE_ADD(CURDATE(), INTERVAL -46 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (66, 4, 'WATER', 'water expense - Alpine Crest Manali', 43000.00, DATE_ADD(CURDATE(), INTERVAL -42 DAY),
  'City Water Works', 'UPI', 'EXP-1066', 13, DATE_ADD(CURDATE(), INTERVAL -42 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (67, 4, 'MAINTENANCE', 'maintenance expense - Alpine Crest Manali', 28750.00, DATE_ADD(CURDATE(), INTERVAL -43 DAY),
  'TechFix Facilities', 'CARD', 'EXP-1067', 13, DATE_ADD(CURDATE(), INTERVAL -43 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (68, 4, 'SALARY', 'salary expense - Alpine Crest Manali', 519200.00, DATE_ADD(CURDATE(), INTERVAL -46 DAY),
  'Payroll', 'CARD', 'EXP-1068', 13, DATE_ADD(CURDATE(), INTERVAL -46 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (69, 4, 'FOOD_SUPPLIES', 'food supplies expense - Alpine Crest Manali', 153800.00, DATE_ADD(CURDATE(), INTERVAL -38 DAY),
  'Fresh Farm Supplies', 'UPI', 'EXP-1069', 13, DATE_ADD(CURDATE(), INTERVAL -38 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (70, 4, 'LAUNDRY', 'laundry expense - Alpine Crest Manali', 29600.00, DATE_ADD(CURDATE(), INTERVAL -33 DAY),
  'CleanPro Laundry', 'CARD', 'EXP-1070', 13, DATE_ADD(CURDATE(), INTERVAL -33 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (71, 4, 'VENDOR', 'vendor expense - Alpine Crest Manali', 12850.00, DATE_ADD(CURDATE(), INTERVAL -53 DAY),
  'Hotel Essentials Pvt Ltd', 'CASH', 'EXP-1071', 13, DATE_ADD(CURDATE(), INTERVAL -53 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (72, 4, 'OTHER', 'other expense - Alpine Crest Manali', 21100.00, DATE_ADD(CURDATE(), INTERVAL -51 DAY),
  'Miscellaneous', 'CARD', 'EXP-1072', 13, DATE_ADD(CURDATE(), INTERVAL -51 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (73, 5, 'ELECTRICITY', 'electricity expense - Urban Nest Pune', 119550.00, DATE_ADD(CURDATE(), INTERVAL -44 DAY),
  'Maharashtra State Electricity Board', 'CARD', 'EXP-1073', 13, DATE_ADD(CURDATE(), INTERVAL -44 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (74, 5, 'WATER', 'water expense - Urban Nest Pune', 38950.00, DATE_ADD(CURDATE(), INTERVAL -51 DAY),
  'City Water Works', 'CARD', 'EXP-1074', 13, DATE_ADD(CURDATE(), INTERVAL -51 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (75, 5, 'MAINTENANCE', 'maintenance expense - Urban Nest Pune', 30200.00, DATE_ADD(CURDATE(), INTERVAL -43 DAY),
  'TechFix Facilities', 'CARD', 'EXP-1075', 13, DATE_ADD(CURDATE(), INTERVAL -43 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (76, 5, 'SALARY', 'salary expense - Urban Nest Pune', 563200.00, DATE_ADD(CURDATE(), INTERVAL -49 DAY),
  'Payroll', 'CASH', 'EXP-1076', 13, DATE_ADD(CURDATE(), INTERVAL -49 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (77, 5, 'FOOD_SUPPLIES', 'food supplies expense - Urban Nest Pune', 125750.00, DATE_ADD(CURDATE(), INTERVAL -52 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1077', 13, DATE_ADD(CURDATE(), INTERVAL -52 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (78, 5, 'LAUNDRY', 'laundry expense - Urban Nest Pune', 8550.00, DATE_ADD(CURDATE(), INTERVAL -37 DAY),
  'CleanPro Laundry', 'CASH', 'EXP-1078', 13, DATE_ADD(CURDATE(), INTERVAL -37 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (79, 5, 'VENDOR', 'vendor expense - Urban Nest Pune', 42200.00, DATE_ADD(CURDATE(), INTERVAL -49 DAY),
  'Hotel Essentials Pvt Ltd', 'CARD', 'EXP-1079', 13, DATE_ADD(CURDATE(), INTERVAL -49 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (80, 5, 'OTHER', 'other expense - Urban Nest Pune', 22900.00, DATE_ADD(CURDATE(), INTERVAL -41 DAY),
  'Miscellaneous', 'BANK_TRANSFER', 'EXP-1080', 13, DATE_ADD(CURDATE(), INTERVAL -41 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (81, 1, 'ELECTRICITY', 'electricity expense - Grand Vista Mumbai', 165450.00, DATE_ADD(CURDATE(), INTERVAL -83 DAY),
  'Maharashtra State Electricity Board', 'UPI', 'EXP-1081', 13, DATE_ADD(CURDATE(), INTERVAL -83 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (82, 1, 'WATER', 'water expense - Grand Vista Mumbai', 54550.00, DATE_ADD(CURDATE(), INTERVAL -70 DAY),
  'City Water Works', 'UPI', 'EXP-1082', 13, DATE_ADD(CURDATE(), INTERVAL -70 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (83, 1, 'MAINTENANCE', 'maintenance expense - Grand Vista Mumbai', 17500.00, DATE_ADD(CURDATE(), INTERVAL -75 DAY),
  'TechFix Facilities', 'BANK_TRANSFER', 'EXP-1083', 13, DATE_ADD(CURDATE(), INTERVAL -75 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (84, 1, 'SALARY', 'salary expense - Grand Vista Mumbai', 650300.00, DATE_ADD(CURDATE(), INTERVAL -69 DAY),
  'Payroll', 'BANK_TRANSFER', 'EXP-1084', 13, DATE_ADD(CURDATE(), INTERVAL -69 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (85, 1, 'FOOD_SUPPLIES', 'food supplies expense - Grand Vista Mumbai', 256000.00, DATE_ADD(CURDATE(), INTERVAL -78 DAY),
  'Fresh Farm Supplies', 'BANK_TRANSFER', 'EXP-1085', 13, DATE_ADD(CURDATE(), INTERVAL -78 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (86, 1, 'LAUNDRY', 'laundry expense - Grand Vista Mumbai', 27000.00, DATE_ADD(CURDATE(), INTERVAL -82 DAY),
  'CleanPro Laundry', 'CARD', 'EXP-1086', 13, DATE_ADD(CURDATE(), INTERVAL -82 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (87, 1, 'VENDOR', 'vendor expense - Grand Vista Mumbai', 57700.00, DATE_ADD(CURDATE(), INTERVAL -83 DAY),
  'Hotel Essentials Pvt Ltd', 'CASH', 'EXP-1087', 13, DATE_ADD(CURDATE(), INTERVAL -83 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (88, 1, 'OTHER', 'other expense - Grand Vista Mumbai', 64750.00, DATE_ADD(CURDATE(), INTERVAL -69 DAY),
  'Miscellaneous', 'BANK_TRANSFER', 'EXP-1088', 13, DATE_ADD(CURDATE(), INTERVAL -69 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (89, 2, 'ELECTRICITY', 'electricity expense - Palm Bay Resort Goa', 156550.00, DATE_ADD(CURDATE(), INTERVAL -84 DAY),
  'Maharashtra State Electricity Board', 'CASH', 'EXP-1089', 13, DATE_ADD(CURDATE(), INTERVAL -84 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (90, 2, 'WATER', 'water expense - Palm Bay Resort Goa', 51850.00, DATE_ADD(CURDATE(), INTERVAL -76 DAY),
  'City Water Works', 'CARD', 'EXP-1090', 13, DATE_ADD(CURDATE(), INTERVAL -76 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (91, 2, 'MAINTENANCE', 'maintenance expense - Palm Bay Resort Goa', 53700.00, DATE_ADD(CURDATE(), INTERVAL -78 DAY),
  'TechFix Facilities', 'BANK_TRANSFER', 'EXP-1091', 13, DATE_ADD(CURDATE(), INTERVAL -78 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (92, 2, 'SALARY', 'salary expense - Palm Bay Resort Goa', 548400.00, DATE_ADD(CURDATE(), INTERVAL -68 DAY),
  'Payroll', 'CARD', 'EXP-1092', 13, DATE_ADD(CURDATE(), INTERVAL -68 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (93, 2, 'FOOD_SUPPLIES', 'food supplies expense - Palm Bay Resort Goa', 327550.00, DATE_ADD(CURDATE(), INTERVAL -79 DAY),
  'Fresh Farm Supplies', 'CASH', 'EXP-1093', 13, DATE_ADD(CURDATE(), INTERVAL -79 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (94, 2, 'LAUNDRY', 'laundry expense - Palm Bay Resort Goa', 58800.00, DATE_ADD(CURDATE(), INTERVAL -74 DAY),
  'CleanPro Laundry', 'CASH', 'EXP-1094', 13, DATE_ADD(CURDATE(), INTERVAL -74 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (95, 2, 'VENDOR', 'vendor expense - Palm Bay Resort Goa', 70600.00, DATE_ADD(CURDATE(), INTERVAL -83 DAY),
  'Hotel Essentials Pvt Ltd', 'CARD', 'EXP-1095', 13, DATE_ADD(CURDATE(), INTERVAL -83 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (96, 2, 'OTHER', 'other expense - Palm Bay Resort Goa', 40100.00, DATE_ADD(CURDATE(), INTERVAL -84 DAY),
  'Miscellaneous', 'CASH', 'EXP-1096', 13, DATE_ADD(CURDATE(), INTERVAL -84 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (97, 3, 'ELECTRICITY', 'electricity expense - Heritage Palace Jaipur', 184850.00, DATE_ADD(CURDATE(), INTERVAL -82 DAY),
  'Maharashtra State Electricity Board', 'CARD', 'EXP-1097', 13, DATE_ADD(CURDATE(), INTERVAL -82 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (98, 3, 'WATER', 'water expense - Heritage Palace Jaipur', 45500.00, DATE_ADD(CURDATE(), INTERVAL -72 DAY),
  'City Water Works', 'CASH', 'EXP-1098', 13, DATE_ADD(CURDATE(), INTERVAL -72 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (99, 3, 'MAINTENANCE', 'maintenance expense - Heritage Palace Jaipur', 23750.00, DATE_ADD(CURDATE(), INTERVAL -63 DAY),
  'TechFix Facilities', 'CARD', 'EXP-1099', 13, DATE_ADD(CURDATE(), INTERVAL -63 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (100, 3, 'SALARY', 'salary expense - Heritage Palace Jaipur', 820450.00, DATE_ADD(CURDATE(), INTERVAL -80 DAY),
  'Payroll', 'BANK_TRANSFER', 'EXP-1100', 13, DATE_ADD(CURDATE(), INTERVAL -80 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (101, 3, 'FOOD_SUPPLIES', 'food supplies expense - Heritage Palace Jaipur', 321150.00, DATE_ADD(CURDATE(), INTERVAL -82 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1101', 13, DATE_ADD(CURDATE(), INTERVAL -82 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (102, 3, 'LAUNDRY', 'laundry expense - Heritage Palace Jaipur', 12000.00, DATE_ADD(CURDATE(), INTERVAL -66 DAY),
  'CleanPro Laundry', 'UPI', 'EXP-1102', 13, DATE_ADD(CURDATE(), INTERVAL -66 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (103, 3, 'VENDOR', 'vendor expense - Heritage Palace Jaipur', 30350.00, DATE_ADD(CURDATE(), INTERVAL -68 DAY),
  'Hotel Essentials Pvt Ltd', 'CARD', 'EXP-1103', 13, DATE_ADD(CURDATE(), INTERVAL -68 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (104, 3, 'OTHER', 'other expense - Heritage Palace Jaipur', 33650.00, DATE_ADD(CURDATE(), INTERVAL -78 DAY),
  'Miscellaneous', 'UPI', 'EXP-1104', 13, DATE_ADD(CURDATE(), INTERVAL -78 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (105, 4, 'ELECTRICITY', 'electricity expense - Alpine Crest Manali', 266400.00, DATE_ADD(CURDATE(), INTERVAL -86 DAY),
  'Maharashtra State Electricity Board', 'UPI', 'EXP-1105', 13, DATE_ADD(CURDATE(), INTERVAL -86 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (106, 4, 'WATER', 'water expense - Alpine Crest Manali', 30650.00, DATE_ADD(CURDATE(), INTERVAL -74 DAY),
  'City Water Works', 'UPI', 'EXP-1106', 13, DATE_ADD(CURDATE(), INTERVAL -74 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (107, 4, 'MAINTENANCE', 'maintenance expense - Alpine Crest Manali', 72400.00, DATE_ADD(CURDATE(), INTERVAL -85 DAY),
  'TechFix Facilities', 'BANK_TRANSFER', 'EXP-1107', 13, DATE_ADD(CURDATE(), INTERVAL -85 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (108, 4, 'SALARY', 'salary expense - Alpine Crest Manali', 862300.00, DATE_ADD(CURDATE(), INTERVAL -81 DAY),
  'Payroll', 'CARD', 'EXP-1108', 13, DATE_ADD(CURDATE(), INTERVAL -81 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (109, 4, 'FOOD_SUPPLIES', 'food supplies expense - Alpine Crest Manali', 287450.00, DATE_ADD(CURDATE(), INTERVAL -65 DAY),
  'Fresh Farm Supplies', 'CARD', 'EXP-1109', 13, DATE_ADD(CURDATE(), INTERVAL -65 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (110, 4, 'LAUNDRY', 'laundry expense - Alpine Crest Manali', 56700.00, DATE_ADD(CURDATE(), INTERVAL -77 DAY),
  'CleanPro Laundry', 'BANK_TRANSFER', 'EXP-1110', 13, DATE_ADD(CURDATE(), INTERVAL -77 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (111, 4, 'VENDOR', 'vendor expense - Alpine Crest Manali', 26750.00, DATE_ADD(CURDATE(), INTERVAL -64 DAY),
  'Hotel Essentials Pvt Ltd', 'CASH', 'EXP-1111', 13, DATE_ADD(CURDATE(), INTERVAL -64 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (112, 4, 'OTHER', 'other expense - Alpine Crest Manali', 14300.00, DATE_ADD(CURDATE(), INTERVAL -65 DAY),
  'Miscellaneous', 'UPI', 'EXP-1112', 13, DATE_ADD(CURDATE(), INTERVAL -65 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (113, 5, 'ELECTRICITY', 'electricity expense - Urban Nest Pune', 168000.00, DATE_ADD(CURDATE(), INTERVAL -67 DAY),
  'Maharashtra State Electricity Board', 'UPI', 'EXP-1113', 13, DATE_ADD(CURDATE(), INTERVAL -67 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (114, 5, 'WATER', 'water expense - Urban Nest Pune', 72650.00, DATE_ADD(CURDATE(), INTERVAL -80 DAY),
  'City Water Works', 'CARD', 'EXP-1114', 13, DATE_ADD(CURDATE(), INTERVAL -80 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (115, 5, 'MAINTENANCE', 'maintenance expense - Urban Nest Pune', 62350.00, DATE_ADD(CURDATE(), INTERVAL -86 DAY),
  'TechFix Facilities', 'CASH', 'EXP-1115', 13, DATE_ADD(CURDATE(), INTERVAL -86 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (116, 5, 'SALARY', 'salary expense - Urban Nest Pune', 890600.00, DATE_ADD(CURDATE(), INTERVAL -75 DAY),
  'Payroll', 'UPI', 'EXP-1116', 13, DATE_ADD(CURDATE(), INTERVAL -75 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (117, 5, 'FOOD_SUPPLIES', 'food supplies expense - Urban Nest Pune', 324400.00, DATE_ADD(CURDATE(), INTERVAL -77 DAY),
  'Fresh Farm Supplies', 'UPI', 'EXP-1117', 13, DATE_ADD(CURDATE(), INTERVAL -77 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (118, 5, 'LAUNDRY', 'laundry expense - Urban Nest Pune', 39050.00, DATE_ADD(CURDATE(), INTERVAL -68 DAY),
  'CleanPro Laundry', 'BANK_TRANSFER', 'EXP-1118', 13, DATE_ADD(CURDATE(), INTERVAL -68 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (119, 5, 'VENDOR', 'vendor expense - Urban Nest Pune', 18300.00, DATE_ADD(CURDATE(), INTERVAL -83 DAY),
  'Hotel Essentials Pvt Ltd', 'CASH', 'EXP-1119', 13, DATE_ADD(CURDATE(), INTERVAL -83 DAY), @now);
INSERT INTO expenses (id, hotel_id, category, description, amount, expense_date, vendor, payment_method, reference_no, created_by, created_at, updated_at)
VALUES (120, 5, 'OTHER', 'other expense - Urban Nest Pune', 49150.00, DATE_ADD(CURDATE(), INTERVAL -81 DAY),
  'Miscellaneous', 'CASH', 'EXP-1120', 13, DATE_ADD(CURDATE(), INTERVAL -81 DAY), @now);

INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (1, 1, 1, 'DEEP_CLEAN', 'COMPLETED', 'HIGH', 10,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (2, 1, 4, 'CLEANING', 'IN_PROGRESS', 'NORMAL', 11,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (3, 1, 7, 'LINEN_CHANGE', 'PENDING', 'LOW', 12,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (4, 1, 10, 'DEEP_CLEAN', 'INSPECTED', 'NORMAL', 10,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL -2 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '11:15:00'), 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '12:00:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (5, 1, 13, 'LINEN_CHANGE', 'INSPECTED', 'HIGH', 11,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '11:15:00'), 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '12:00:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (6, 1, 16, 'CLEANING', 'COMPLETED', 'NORMAL', 12,
  'Pre-arrival inspection', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (7, 1, 19, 'INSPECTION', 'PENDING', 'NORMAL', 10,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (8, 2, 22, 'DEEP_CLEAN', 'COMPLETED', 'NORMAL', 11,
  'Pre-arrival inspection', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (9, 2, 25, 'INSPECTION', 'PENDING', 'NORMAL', 12,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (10, 2, 28, 'CLEANING', 'IN_PROGRESS', 'NORMAL', 10,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (11, 2, 31, 'LINEN_CHANGE', 'INSPECTED', 'NORMAL', 11,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '12:00:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (12, 2, 34, 'INSPECTION', 'COMPLETED', 'LOW', 12,
  'Pre-arrival inspection', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (13, 2, 37, 'INSPECTION', 'INSPECTED', 'NORMAL', 10,
  'Change linen and restock minibar', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '11:15:00'), 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '12:00:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (14, 2, 40, 'DEEP_CLEAN', 'INSPECTED', 'LOW', 11,
  'Change linen and restock minibar', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '12:00:00'), 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (15, 3, 43, 'CLEANING', 'PENDING', 'HIGH', 12,
  'Change linen and restock minibar', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (16, 3, 46, 'CLEANING', 'IN_PROGRESS', 'NORMAL', 10,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL -2 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (17, 3, 49, 'DEEP_CLEAN', 'IN_PROGRESS', 'NORMAL', 11,
  'Pre-arrival inspection', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (18, 3, 52, 'INSPECTION', 'PENDING', 'LOW', 12,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (19, 3, 55, 'INSPECTION', 'COMPLETED', 'NORMAL', 10,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (20, 3, 58, 'CLEANING', 'COMPLETED', 'HIGH', 11,
  'Deep clean bathroom and balcony', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (21, 4, 61, 'LINEN_CHANGE', 'PENDING', 'NORMAL', 12,
  'Pre-arrival inspection', DATE_ADD(CURDATE(), INTERVAL -2 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (22, 4, 64, 'INSPECTION', 'PENDING', 'HIGH', 10,
  'Pre-arrival inspection', DATE_ADD(CURDATE(), INTERVAL 0 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (23, 4, 67, 'DEEP_CLEAN', 'PENDING', 'HIGH', 11,
  'Change linen and restock minibar', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  NULL, NULL, NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);
INSERT INTO housekeeping_tasks (id, hotel_id, room_id, task_type, status, priority, assigned_to, notes, scheduled_date, started_at, completed_at, inspected_by, inspected_at, created_by, created_at, updated_at)
VALUES (24, 4, 70, 'LINEN_CHANGE', 'COMPLETED', 'HIGH', 12,
  'Check-out cleaning', DATE_ADD(CURDATE(), INTERVAL -1 DAY),
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '11:15:00'), NULL, NULL, 7, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:30:00'), @now);

INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (1, 1, 6, 'Broken balcony door lock',
  'Reported by housekeeping during routine inspection.', 'HVAC', 'HIGH', 'IN_PROGRESS',
  10, 11, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -8 DAY), '15:53:00'), NULL,
  NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (2, 1, 13, 'Leaking bathroom tap',
  'Reported by housekeeping during routine inspection.', 'GENERAL', 'LOW', 'RESOLVED',
  7, 10, 3143,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:07:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '15:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (3, 1, 20, 'Air conditioner not cooling',
  'Reported by housekeeping during routine inspection.', 'ELECTRICAL', 'HIGH', 'RESOLVED',
  10, 10, 517,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '11:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '16:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -16 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (4, 2, 27, 'Air conditioner not cooling',
  'Reported by housekeeping during routine inspection.', 'ELECTRICAL', 'HIGH', 'IN_PROGRESS',
  11, 12, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -19 DAY), '15:24:00'), NULL,
  NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -10 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (5, 2, 34, 'Water heater failure',
  'Reported by housekeeping during routine inspection.', 'GENERAL', 'LOW', 'RESOLVED',
  11, 12, 2347,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -17 DAY), '09:49:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '11:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (6, 3, 41, 'Broken balcony door lock',
  'Reported by housekeeping during routine inspection.', 'HVAC', 'HIGH', 'OPEN',
  11, 10, NULL,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '14:37:00'), NULL,
  NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (7, 3, 48, 'Broken balcony door lock',
  'Reported by housekeeping during routine inspection.', 'CARPENTRY', 'HIGH', 'RESOLVED',
  7, 10, 1848,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '11:46:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '16:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -17 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (8, 3, 55, 'Leaking bathroom tap',
  'Reported by housekeeping during routine inspection.', 'ELECTRICAL', 'LOW', 'RESOLVED',
  12, 12, 1361,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -11 DAY), '15:52:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '14:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (9, 4, 62, 'Leaking bathroom tap',
  'Reported by housekeeping during routine inspection.', 'HVAC', 'URGENT', 'CLOSED',
  10, 12, 3926,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -9 DAY), '11:19:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '14:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -18 DAY), '09:00:00'), @now);
INSERT INTO maintenance_requests (id, hotel_id, room_id, title, description, category, priority, status, reported_by, assigned_to, cost, reported_at, resolved_at, resolution_note, created_at, updated_at)
VALUES (10, 4, 69, 'Leaking bathroom tap',
  'Reported by housekeeping during routine inspection.', 'CARPENTRY', 'LOW', 'CLOSED',
  11, 11, 3761,
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -16 DAY), '17:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '15:30:00'),
  'Part replaced and tested by maintenance team.', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:00:00'), @now);

INSERT INTO lost_and_found (id, hotel_id, room_id, guest_id, item_description, found_by, found_at, status, storage_location, notes, created_at, updated_at) VALUES
 (1, 1, 4, 1, 'Black leather wallet with cards', 10, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '11:20:00'), 'RETURNED', 'Front office safe', 'Courier dispatched to guest', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '11:20:00'), @now),
 (2, 2, 26, 8, 'Blue iPhone 13 charger', 11, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:05:00'), 'STORED', 'Housekeeping store - bin B', NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '10:05:00'), @now),
 (3, 3, 56, NULL, 'Gold earrings, single pair', 10, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '12:40:00'), 'STORED', 'Manager safe', 'High value - verify ownership', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '12:40:00'), @now);

INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (1, 1, 2, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:34:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (2, 2, 3, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:24:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:35:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (3, 3, 4, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:38:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (4, 5, 6, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:04:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (5, 1, 7, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:29:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (6, 2, 8, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:01:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:40:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (7, 4, 8, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:14:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (8, 3, 9, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:24:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:35:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (9, 1, 10, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:08:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (10, 3, 10, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:11:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:05:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (11, 2, 11, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:36:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (12, 5, 12, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:19:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:07:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (13, 4, 12, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'LEAVE', 'Morning',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (14, 1, 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:05:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (15, 3, 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:44:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (16, 4, 13, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:09:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:10:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (17, 1, 14, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:28:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (18, 5, 14, DATE_ADD(CURDATE(), INTERVAL 0 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '09:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '18:38:00'), NULL, DATE_ADD(CURDATE(), INTERVAL 0 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (19, 2, 3, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:10:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (20, 3, 4, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (21, 4, 5, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:02:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (22, 5, 6, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:43:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (23, 1, 7, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:15:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (24, 4, 8, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'LEAVE', 'Evening',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (25, 3, 9, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'LEAVE', 'General',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (26, 2, 11, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:07:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (27, 5, 12, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:43:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (28, 4, 12, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:13:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (29, 1, 13, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:39:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (30, 2, 13, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:10:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (31, 3, 13, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:22:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:36:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (32, 4, 13, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:21:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (33, 5, 13, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (34, 1, 14, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:11:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:03:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (35, 5, 14, DATE_ADD(CURDATE(), INTERVAL -1 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:19:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -1 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (36, 1, 2, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:17:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (37, 2, 3, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:22:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (38, 3, 4, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:24:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:34:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (39, 4, 5, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:15:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:03:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (40, 5, 6, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:08:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:14:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (41, 1, 7, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (42, 2, 8, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:13:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (43, 4, 8, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:17:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:12:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (44, 3, 9, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:22:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:12:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (45, 1, 10, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:01:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:08:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (46, 3, 10, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:34:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (47, 2, 11, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:01:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:17:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (48, 5, 12, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:04:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (49, 4, 12, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:03:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (50, 1, 13, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:11:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (51, 2, 13, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (52, 3, 13, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:18:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:42:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (53, 4, 13, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:12:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:45:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (54, 5, 13, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:02:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:38:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (55, 1, 14, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:07:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:40:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (56, 5, 14, DATE_ADD(CURDATE(), INTERVAL -2 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:08:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '18:31:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -2 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (57, 1, 2, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:16:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:02:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (58, 2, 3, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:14:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:05:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (59, 3, 4, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:18:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (60, 4, 5, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:17:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:02:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (61, 5, 6, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:15:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (62, 1, 7, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'LEAVE', 'Evening',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (63, 2, 8, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'LEAVE', 'Night',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (64, 4, 8, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:02:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:45:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (65, 3, 10, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:13:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:10:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (66, 2, 11, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:16:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:26:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (67, 5, 12, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:01:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (68, 1, 13, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:16:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:14:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (69, 2, 13, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:23:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:15:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (70, 3, 13, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (71, 4, 13, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:12:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (72, 5, 13, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (73, 1, 14, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:07:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:09:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (74, 5, 14, DATE_ADD(CURDATE(), INTERVAL -3 DAY), 'HALF_DAY', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '09:23:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '18:28:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -3 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (75, 1, 2, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:29:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (76, 2, 3, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:12:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (77, 3, 4, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:23:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (78, 4, 5, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:00:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (79, 5, 6, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'LEAVE', 'Morning',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (80, 1, 7, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:08:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:27:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (81, 2, 8, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:43:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (82, 4, 8, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:00:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (83, 3, 9, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:31:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (84, 1, 10, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:10:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (85, 3, 10, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:31:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (86, 2, 11, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:06:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (87, 5, 12, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:09:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (88, 4, 12, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:40:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (89, 1, 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:00:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (90, 2, 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:18:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:17:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (91, 3, 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:44:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (92, 4, 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:34:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (93, 5, 13, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:07:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:38:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (94, 1, 14, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:13:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:23:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (95, 5, 14, DATE_ADD(CURDATE(), INTERVAL -4 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '09:15:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '18:19:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -4 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (96, 1, 2, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'LEAVE', 'General',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (97, 2, 3, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (98, 3, 4, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'HALF_DAY', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:14:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:15:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (99, 4, 5, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:11:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (100, 5, 6, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:13:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:16:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (101, 1, 7, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:27:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (102, 2, 8, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:16:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:16:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (103, 4, 8, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:14:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:12:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (104, 3, 9, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:25:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (105, 1, 10, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:17:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (106, 3, 10, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:01:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:24:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (107, 2, 11, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:30:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (108, 5, 12, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:09:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:10:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (109, 4, 12, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:17:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (110, 1, 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:44:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (111, 2, 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:22:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:07:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (112, 3, 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:33:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (113, 4, 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:04:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:06:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (114, 5, 13, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:05:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:21:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (115, 1, 14, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:07:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (116, 5, 14, DATE_ADD(CURDATE(), INTERVAL -5 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '09:25:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -5 DAY), '18:33:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -5 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (117, 1, 2, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:08:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:42:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (118, 2, 3, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:14:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:26:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (119, 3, 4, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'LEAVE', 'Evening',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (120, 4, 5, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:01:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (121, 1, 7, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:20:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:12:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (122, 2, 8, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:21:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:41:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (123, 3, 9, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'LEAVE', 'Night',
  NULL, NULL, NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (124, 1, 10, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:38:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (125, 3, 10, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:25:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:45:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (126, 2, 11, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:43:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (127, 5, 12, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (128, 4, 12, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'General',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:41:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (129, 1, 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:16:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:37:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (130, 2, 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Evening',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:10:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:06:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (131, 3, 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:24:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:16:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (132, 4, 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:14:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (133, 5, 13, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:12:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:20:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (134, 1, 14, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'HALF_DAY', 'Morning',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:15:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:34:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);
INSERT INTO staff_attendance (id, hotel_id, user_id, attendance_date, status, shift_name, check_in_time, check_out_time, notes, created_at, updated_at)
VALUES (135, 5, 14, DATE_ADD(CURDATE(), INTERVAL -6 DAY), 'PRESENT', 'Night',
  TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '09:15:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -6 DAY), '18:03:00'), NULL, DATE_ADD(CURDATE(), INTERVAL -6 DAY), @now);

INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (1, 5, 15, 83, 15, 'RESTAURANT', 'Dinner - Butter chicken, naan, dessert', 1200.00, 1,
  'DELIVERED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:29:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '13:09:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (2, 5, 15, 83, 15, 'MINIBAR', 'Minibar - beverages and snacks', 2850.00, 1,
  'DELIVERED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '12:56:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '20:24:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (3, 1, 16, 19, 16, 'RESTAURANT', 'Dinner - Butter chicken, naan, dessert', 1500.00, 1,
  'SERVED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '19:55:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '19:43:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (4, 1, 16, 19, 16, 'LAUNDRY', 'Express laundry - 4 items', 4200.00, 1,
  'DELIVERED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:44:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '17:45:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (5, 2, 17, 24, 17, 'ROOM_SERVICE', 'Club sandwich and coffee', 2700.00, 1,
  'BILLED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:33:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '22:07:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (6, 2, 17, 24, 17, 'MINIBAR', 'Minibar - beverages and snacks', 1950.00, 1,
  'BILLED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:08:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '22:23:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (7, 2, 17, 24, 17, 'RESTAURANT', 'Dinner - Butter chicken, naan, dessert', 750.00, 1,
  'BILLED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '16:03:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '11:28:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (8, 3, 18, 41, 18, 'ROOM_SERVICE', 'Club sandwich and coffee', 2400.00, 1,
  'PENDING', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '16:44:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:24:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (9, 4, 19, 68, 19, 'ROOM_SERVICE', 'Club sandwich and coffee', 2850.00, 1,
  'SERVED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:32:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:57:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (10, 4, 19, 68, 19, 'RESTAURANT', 'Dinner - Butter chicken, naan, dessert', 1650.00, 1,
  'SERVED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '16:06:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '20:42:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (11, 5, 20, 86, 20, 'MINIBAR', 'Minibar - beverages and snacks', 2100.00, 1,
  'PENDING', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '21:19:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '10:35:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);
INSERT INTO service_orders (id, hotel_id, booking_id, room_id, guest_id, order_type, description, amount, quantity, status, billed_to_room, ordered_at, delivered_at, created_by, created_at, updated_at)
VALUES (12, 4, 24, 74, 4, 'RESTAURANT', 'Dinner - Butter chicken, naan, dessert', 1200.00, 1,
  'SERVED', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '11:27:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '15:45:00'), 8, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '08:00:00'), @now);

INSERT INTO guest_feedback (id, hotel_id, guest_id, booking_id, type, rating, comments, status, resolution, resolved_by, resolved_at, created_at, updated_at) VALUES
 (1, 1, 1, 1, 'FEEDBACK', 5, 'Outstanding sea-view suite and very attentive staff. Will return.', 'RESOLVED', 'Thanked the guest and offered loyalty upgrade.', 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -40 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -43 DAY), '09:00:00'), @now),
 (2, 2, 4, 9, 'COMPLAINT', 2, 'Beach towels were not replaced on the second day and room service was slow.', 'RESOLVED', 'Housekeeping retrained, complimentary breakfast offered.', 3, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -8 DAY), '11:30:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -9 DAY), '18:00:00'), @now),
 (3, 3, 7, 13, 'FEEDBACK', 5, 'Heritage walk and palace dining were exceptional.', 'OPEN', NULL, NULL, NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -3 DAY), '12:00:00'), @now),
 (4, 4, 12, 17, 'COMPLAINT', 3, 'Heater in the room took a long time to warm up.', 'OPEN', NULL, NULL, NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '20:00:00'), @now),
 (5, 5, 3, 21, 'FEEDBACK', 4, 'Great location for business meetings, fast WiFi.', 'OPEN', NULL, NULL, NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '09:00:00'), @now),
 (6, 1, 14, 5, 'FEEDBACK', 5, 'Spa and rooftop pool were the highlight of our trip.', 'RESOLVED', 'Thanked guest with loyalty points.', 2, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -20 DAY), '10:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -22 DAY), '16:00:00'), @now);

INSERT INTO notifications (id, hotel_id, user_id, title, message, type, severity, link, is_read, read_at, created_at) VALUES
 (1, 1, 1, 'New booking confirmed', 'GV-24021 - Aarav Kapoor - Deluxe room for 2 nights.', 'BOOKING_CREATED', 'SUCCESS', '/bookings', b'0', NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:15:00')),
 (2, 2, NULL, 'Pending payment', 'HTS-GOA-24022 has INR 0 paid against a confirmed booking. Follow up with the guest.', 'PAYMENT_PENDING', 'WARNING', '/payments', b'0', NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:40:00')),
 (3, 1, NULL, 'Rooms awaiting cleaning', '4 rooms are marked dirty and need housekeeping attention before the 2 PM check-ins.', 'HOUSEKEEPING', 'INFO', '/housekeeping', b'0', NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '07:05:00')),
 (4, 3, NULL, 'Maintenance escalated', 'Air conditioner failure in room 320 is still open after 24 hours.', 'MAINTENANCE', 'CRITICAL', '/maintenance', b'0', NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '18:20:00')),
 (5, 5, NULL, 'Check-out due today', '3 departures are scheduled before 11 AM at Urban Nest Pune.', 'CHECKOUT_DUE', 'INFO', '/bookings', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '07:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '06:30:00')),
 (6, 4, NULL, 'Check-in due today', '2 arrivals expected at Alpine Crest Manali.', 'CHECKIN_DUE', 'INFO', '/bookings', b'0', NULL, TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '06:45:00')),
 (7, NULL, 1, 'Monthly report ready', 'October consolidated revenue and occupancy report is available.', 'SYSTEM', 'INFO', '/reports', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '09:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '08:00:00')),
 (8, 1, 13, 'Refund processed', 'Refund of INR 0 recorded for cancelled booking GV-24006.', 'PAYMENT_PENDING', 'INFO', '/payments', b'1', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '12:00:00'), TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -4 DAY), '11:30:00'));

INSERT INTO audit_logs (id, hotel_id, user_id, actor_email, action, entity_type, entity_id, description, ip_address, created_at) VALUES
 (1, 1, 1, 'owner@hotelgroup.com', 'LOGIN', 'User', 1, 'Owner signed in from Chrome on macOS', '103.21.58.4', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL 0 DAY), '08:02:00')),
 (2, 1, 7, 'reception.mumbai@hotelgroup.com', 'CHECK_IN', 'Booking', 15, 'Guest checked in - room 120', '103.21.58.11', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -2 DAY), '14:12:00')),
 (3, 2, 3, 'manager.goa@hotelgroup.com', 'BOOKING_CREATED', 'Booking', 9, 'Walk-in booking created for Emily Watson', '103.21.58.19', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -9 DAY), '15:30:00')),
 (4, 3, 13, 'accounts@hotelgroup.com', 'INVOICE_ISSUED', 'Invoice', 3, 'GST invoice INV-HP-10003 issued', '103.21.58.25', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -14 DAY), '11:00:00')),
 (5, 5, 6, 'manager.pune@hotelgroup.com', 'ROOM_UPDATED', 'Room', 81, 'Room 410 moved to MAINTENANCE', '103.21.58.31', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -1 DAY), '16:45:00')),
 (6, 1, 1, 'owner@hotelgroup.com', 'STAFF_CREATED', 'User', 12, 'Housekeeping attendant account created', '103.21.58.4', TIMESTAMP(DATE_ADD(CURDATE(), INTERVAL -30 DAY), '10:20:00'));

-- keep AUTO_INCREMENT ahead of the explicitly seeded ids
ALTER TABLE roles AUTO_INCREMENT = 1;
ALTER TABLE permissions AUTO_INCREMENT = 1;
ALTER TABLE users AUTO_INCREMENT = 1;
ALTER TABLE hotels AUTO_INCREMENT = 1;
ALTER TABLE hotel_staff AUTO_INCREMENT = 1;
ALTER TABLE room_categories AUTO_INCREMENT = 1;
ALTER TABLE rooms AUTO_INCREMENT = 1;
ALTER TABLE room_pricing AUTO_INCREMENT = 1;
ALTER TABLE coupons AUTO_INCREMENT = 1;
ALTER TABLE guests AUTO_INCREMENT = 1;
ALTER TABLE bookings AUTO_INCREMENT = 1;
ALTER TABLE booking_rooms AUTO_INCREMENT = 1;
ALTER TABLE booking_guests AUTO_INCREMENT = 1;
ALTER TABLE invoices AUTO_INCREMENT = 1;
ALTER TABLE invoice_lines AUTO_INCREMENT = 1;
ALTER TABLE payments AUTO_INCREMENT = 1;
ALTER TABLE refunds AUTO_INCREMENT = 1;
ALTER TABLE expenses AUTO_INCREMENT = 1;
ALTER TABLE housekeeping_tasks AUTO_INCREMENT = 1;
ALTER TABLE maintenance_requests AUTO_INCREMENT = 1;
ALTER TABLE lost_and_found AUTO_INCREMENT = 1;
ALTER TABLE staff_attendance AUTO_INCREMENT = 1;
ALTER TABLE service_orders AUTO_INCREMENT = 1;
ALTER TABLE guest_feedback AUTO_INCREMENT = 1;
ALTER TABLE notifications AUTO_INCREMENT = 1;
ALTER TABLE audit_logs AUTO_INCREMENT = 1;
