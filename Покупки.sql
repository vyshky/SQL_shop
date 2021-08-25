CREATE TABLE tab_products
(
    id    INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    name  VARCHAR(50) NOT NULL,
    price INT         NOT NULL CHECK ( price < 0 )
);

CREATE TABLE tab_products_stock
(
    id         INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    count      INT NOT NULL CHECK ( count < 0 ),

    FOREIGN KEY (product_id)
        REFERENCES tab_products (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE tab_people
(
    id         INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(75) NOT NULL,
    phone      VARCHAR(20) NOT NULL
);

CREATE TABLE tab_discounts
(
    id       INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    type     VARCHAR(15) NOT NULL,
    discount INT         NOT NULL
);

CREATE TABLE tab_buyers
(
    id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    people_id   INT NOT NULL,
    discount_id INT NOT NULL,

    FOREIGN KEY (people_id)
        REFERENCES tab_people (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (discount_id)
        REFERENCES tab_discounts (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE tab_positions
(
    id       INT         NOT NULL PRIMARY KEY AUTO_INCREMENT,
    position VARCHAR(20) NOT NULL
);

CREATE TABLE tab_sellers
(
    id          INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    people_id   INT NOT NULL,
    position_id INT NOT NULL,

    FOREIGN KEY (people_id)
        REFERENCES tab_people (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (position_id)
        REFERENCES tab_positions (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

CREATE TABLE tab_orders
(
    id          INT      NOT NULL PRIMARY KEY AUTO_INCREMENT,
    buyer_id    INT      NOT NULL,
    seller_id   INT      NOT NULL,
    date        DATETIME NOT NULL,
    product_id  INT      NOT NULL,
    amount      INT      NOT NULL CHECK ( amount < 0 ),
    total_price INT      NOT NULL,

    FOREIGN KEY (buyer_id)
        REFERENCES tab_buyers (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (seller_id)
        REFERENCES tab_sellers (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    FOREIGN KEY (product_id)
        REFERENCES tab_products (id)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);


#1. Создайте обновляемое представление, которое отображает
#информацию о всех продавцах

SELECT first_name,last_name
FROM tab_sellers
JOIN tab_people ON tab_people.id=tab_sellers.people_id;

#2. Создайте обновляемое представление, которое отображает
#информацию о всех покупателях

SELECT first_name,last_name
FROM tab_buyers
JOIN tab_people tp on tab_buyers.people_id = tp.id;

#3. Создайте обновляемое представление, которое отображает
#информацию о всех продажах конкретного товара. Напри-
#мер, яблок

CREATE VIEW  view_products AS
    SELECT product_id AS 'ID',name
FROM tab_orders
JOIN tab_products tp on tab_orders.product_id = tp.id
WHERE name = 'Phone'
WITH CHECK OPTION;

DROP VIEW view_products;

#4. Создайте представление, отображающее все осуществлен-
#ные сделки

CREATE VIEW view_orders AS
SELECT CONCAT(first_name,' ',last_name) AS 'Покупатель',name AS 'Купил',amount AS 'Количество',price * amount AS 'К оплате',date
FROM tab_orders
JOIN tab_people
    JOIN tab_buyers tb on tab_orders.buyer_id = tb.id and tab_people.id = tb.people_id
JOIN tab_products tp on tab_orders.product_id = tp.id;

DROP VIEW view_orders;


#5. Создайте представление, отображающее информацию о са-
#мом активном продавце. Определяем самого активного
#продавца по максимальной общей сумме продаж

CREATE VIEW view_top_seller AS
SELECT CONCAT(first_name,' ',last_name) AS 'Продавец',price * amount AS 'Продал на сумму'
FROM tab_orders
JOIN tab_people
    JOIN tab_sellers ts on tab_orders.seller_id = ts.id and tab_people.id = ts.people_id
JOIN tab_products tp on tab_orders.product_id = tp.id
ORDER BY price * amount DESC
;

DROP VIEW view_top_seller;

#6. Создайте представление, отображающее информацию о са-
#мом активном покупателе. Определяем самого активного
#покупателя по максимальной общей сумме покупок.

CREATE VIEW view_top_buyer AS
SELECT CONCAT(first_name,' ',last_name) AS 'ТОП Покупатель',price * amount AS 'Купил на сумму'
FROM tab_orders
JOIN tab_people
    JOIN tab_buyers tb on tab_orders.buyer_id = tb.id and tab_people.id = tb.people_id
JOIN tab_products tp on tab_orders.product_id = tp.id
ORDER BY price * amount DESC;

DROP VIEW view_top_buyer;

#Используйте опции CHECK OPTION, SCHEMABINDING,
#ENCRYPTION там, где это необходимо или полезно.


# WITH CHECK OPTION - Это WITH CHECK OPTION необязательный пункт CREATE VIEW инструкции.
# WITH CHECK OPTION НЕ позволяет представлению обновлять или вставлять строки, которые не видны через него.
# Другими словами, всякий раз, когда вы обновляете или вставляете строку базовых таблиц через представление,
# MySQL гарантирует, что операция вставки или обновления соответствует определению представления.

# WITH SCHEMABINDING - это специальная опция, которая не допускает изменения в таких объектах, на которые
# ссылается объект, связанный схемой. Например, представления могут быть привязаны к схеме, что означает,
# что все объекты(например, таблицы), на которые ссылается это представление, не могут быть изменены или изменены
# (например, вы не можете удалить из них столбец, на который есть ссылка, но добавление нового столбца разрешено,
# хотя и не рекомендуется). Иногда, например, при создании индексов для представлений, параметр SHEMABOUND является обязательным

#MySQL ENCRYPT () шифрует строку с помощью системного вызова Unix crypt (). Функция возвращает двоичную строку.
#Поскольку функция основана на системном вызове Unix crypt (), в системах Windows она вернет NULL.
#Синтаксис:
#ШИФРОВАТЬ (строка, соль)
#SELECT ENCRYPT('w3resource', 'encode');
#Аргументы
#Имя	Описание
#нить	Строка, которую необходимо зашифровать.
#поваренная соль	Строка не менее двух символов. Если значение соли меньше двух символов, функция вернет NULL. Если этот аргумент не установлен, функция использует случайное значение для шифрования.



