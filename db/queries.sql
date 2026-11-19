USE Shaurma21;

SELECT * FROM categories ORDER BY id;
SELECT * FROM manufacturers ORDER BY id;
SELECT * FROM suppliers ORDER BY id;
SELECT * FROM roles ORDER BY id;
SELECT * FROM orderstatus ORDER BY id;

SELECT 
    p.id,
    p.article,
    p.name AS product_name,
    p.unit,
    p.price,
    p.discount,
    ROUND(p.price * (1 - p.discount / 100), 2) AS final_price,
    p.stock_qty,
    c.name AS category,
    m.name AS manufacturer,
    s.name AS supplier
FROM products p
JOIN categories c ON p.category_id = c.id
JOIN manufacturers m ON p.manufacturer_id = m.id
JOIN suppliers s ON p.supplier_id = s.id
ORDER BY p.id;

SELECT 
    u.id,
    u.full_name,
    u.login,
    r.name AS role
FROM users u
JOIN roles r ON u.role_id = r.id
ORDER BY u.id;

SELECT 
    o.id AS order_id,
    o.order_date,
    o.delivery_date,
    u.full_name AS client,
    st.name AS status,
    CONCAT(pvz.city, ', ул. ', pvz.street, ', ', IFNULL(pvz.house, 'б/н')) AS pvz_address,
    o.receive_code
FROM orders o
JOIN users u ON o.user_id = u.id
JOIN orderstatus st ON o.status_id = st.id
JOIN pvz ON o.pvz_id = pvz.id
ORDER BY o.id;

SELECT 
    po.id,
    po.order_id,
    p.article,
    p.name AS product,
    p.price,
    po.qty,
    ROUND(p.price * (1 - p.discount / 100) * po.qty, 2) AS line_total
FROM prodorders po
JOIN products p ON po.product_id = p.id
ORDER BY po.order_id, po.id;

SELECT 
    o.id AS order_id,
    o.order_date,
    COUNT(po.id) AS positions_count,
    SUM(po.qty) AS total_items,
    ROUND(SUM(p.price * (1 - p.discount / 100) * po.qty), 2) AS order_total
FROM orders o
JOIN prodorders po ON o.id = po.order_id
JOIN products p ON po.product_id = p.id
GROUP BY o.id, o.order_date
ORDER BY o.id;

SELECT 
    st.name AS status,
    COUNT(o.id) AS orders_count
FROM orderstatus st
LEFT JOIN orders o ON st.id = o.status_id
GROUP BY st.id, st.name
ORDER BY orders_count DESC;

SELECT 
    p.article,
    p.name AS product,
    SUM(po.qty) AS total_sold
FROM prodorders po
JOIN products p ON po.product_id = p.id
GROUP BY p.id, p.article, p.name
ORDER BY total_sold DESC
LIMIT 5;

SELECT 
    p.article,
    p.name,
    p.price,
    c.name AS category
FROM products p
JOIN categories c ON p.category_id = c.id
WHERE c.name = 'Женская обувь'
  AND p.price <= 5000
  AND p.stock_qty > 0
ORDER BY p.price ASC;

SELECT 'products -> categories' AS check_name, COUNT(*) AS broken_rows
FROM products p LEFT JOIN categories c ON p.category_id = c.id
WHERE c.id IS NULL
UNION ALL
SELECT 'products -> manufacturers', COUNT(*)
FROM products p LEFT JOIN manufacturers m ON p.manufacturer_id = m.id
WHERE m.id IS NULL
UNION ALL
SELECT 'products -> suppliers', COUNT(*)
FROM products p LEFT JOIN suppliers s ON p.supplier_id = s.id
WHERE s.id IS NULL
UNION ALL
SELECT 'orders -> users', COUNT(*)
FROM orders o LEFT JOIN users u ON o.user_id = u.id
WHERE u.id IS NULL
UNION ALL
SELECT 'orders -> pvz', COUNT(*)
FROM orders o LEFT JOIN pvz ON o.pvz_id = pvz.id
WHERE pvz.id IS NULL
UNION ALL
SELECT 'orders -> orderstatus', COUNT(*)
FROM orders o LEFT JOIN orderstatus st ON o.status_id = st.id
WHERE st.id IS NULL
UNION ALL
SELECT 'prodorders -> orders', COUNT(*)
FROM prodorders po LEFT JOIN orders o ON po.order_id = o.id
WHERE o.id IS NULL
UNION ALL
SELECT 'prodorders -> products', COUNT(*)
FROM prodorders po LEFT JOIN products p ON po.product_id = p.id
WHERE p.id IS NULL;