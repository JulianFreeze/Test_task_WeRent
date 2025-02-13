-- DROP TABLES ------------------------------------------------
DROP TABLE IF EXISTS Order_Statistics;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Categories;

-- CREATE TABLES ----------------------------------------------
CREATE TABLE Categories (
    cat_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE Products (
    prod_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    cat_id int REFERENCES Categories (cat_id) NOT NULL
);

CREATE TABLE Orders (
    ord_id SERIAL PRIMARY KEY,
    prod_id int REFERENCES Products (prod_id),
    prod_amount int DEFAULT 1 CHECK (prod_amount > 0),
    order_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Order_Statistics (
    stat_id SERIAL PRIMARY KEY,
    cat_id int REFERENCES Categories (cat_id),
    prod_amount int DEFAULT 1 CHECK (prod_amount > 0),
    stat_date date NOT NULL
);

-- SET TRIGGER ----------------------------------------------

-- Function for forming statistics
CREATE FUNCTION prepare_statistics() RETURNS TRIGGER AS $stat_trigger$
DECLARE
    tempRow record;
    statDay date;
BEGIN
    -- Day of statistics
    statDay = date_trunc('day', NEW.order_time);
    -- Clear statistics for this date
    DELETE FROM Order_Statistics as st WHERE st.stat_date = statDay; 
  
    -- Form statistics
    FOR tempRow IN (
        SELECT Prod.cat_id, SUM(Ord.prod_amount) as summ_amount FROM Orders as Ord
        LEFT JOIN Products as Prod ON Prod.prod_id = Ord.prod_id
        WHERE date_trunc('day', Ord.order_time) = statDay
        GROUP BY Prod.cat_id
    )
    LOOP
        INSERT INTO Order_Statistics (cat_id, prod_amount, stat_date) VALUES (tempRow.cat_id, tempRow.summ_amount, statDay);
    END LOOP;
  
    RETURN NEW;
END
$stat_trigger$ LANGUAGE plpgsql;

-- Trigger on Orders
CREATE TRIGGER stat_trigger AFTER INSERT ON Orders
FOR EACH ROW EXECUTE FUNCTION prepare_statistics();

-- FILL DATA ----------------------------------------------

-- Function to get random int in range
CREATE OR REPLACE FUNCTION get_random_integer(i integer) RETURNS integer AS $$
    BEGIN
        RETURN floor(random() * i + 1)::int;
    END;
$$ LANGUAGE plpgsql;


-- Filling Products, Catigories and Orders tables
DO $$
DECLARE
    catAmount integer;
    prodAmount integer;
    ordersAmount integer;
BEGIN
    -- Set amount of rows to fill
    SELECT 5 INTO catAmount;
    SELECT 10 INTO prodAmount;
    SELECT 8 INTO ordersAmount;

    -- Fill Categories table
    FOR i IN 1 .. catAmount LOOP
        INSERT INTO Categories (name) VALUES ('Category ' || i);
    END LOOP;
  
    -- Fill Products table
    FOR i IN 1 .. prodAmount LOOP
        INSERT INTO Products (name, cat_id) VALUES ('Product ' || i, get_random_integer(catAmount));
    END LOOP;
  
    -- Fill Orders table
    FOR i IN 1 .. ordersAmount LOOP
        INSERT INTO Orders (prod_id, prod_amount) VALUES (get_random_integer(prodAmount), get_random_integer(10));
    END LOOP;
END;
$$;