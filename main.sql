DELIMITER //

CREATE PROCEDURE ReconcileStockAndSales(IN p_prod_id INT)
BEGIN
    DECLARE v_actual_sales INT;
    DECLARE v_inventory_stock INT;
    DECLARE v_diff INT;

    SELECT SUM(quantity) INTO v_actual_sales 
    FROM OrderDetails 
    WHERE prod_id = p_prod_id;

    SELECT stock_quantity INTO v_inventory_stock 
    FROM Products 
    WHERE prod_id = p_prod_id;

    SET v_diff = v_inventory_stock - IFNULL(v_actual_sales, 0);

    IF v_diff < 0 THEN
        INSERT INTO SystemLogs (event_type, description, severity)
        VALUES ('STOCK_ERROR', CONCAT('Product ID ', p_prod_id, ' has negative mismatch: ', v_diff), 'CRITICAL');
    ELSE
        UPDATE Products 
        SET stock_quantity = v_diff 
        WHERE prod_id = p_prod_id;
        
        INSERT INTO SystemLogs (event_type, description, severity)
        VALUES ('STOCK_SYNC', CONCAT('Product ID ', p_prod_id, ' successfully reconciled.'), 'INFO');
    END IF;
END //

DELIMITER ;
