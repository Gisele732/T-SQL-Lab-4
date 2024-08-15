USE WattsALoan
GO

-- Declare all the variables
DECLARE @paymentdate DATE;
DECLARE @employeeid INT;
DECLARE @loanallocationid INT;
DECLARE @paymentamount MONEY;
DECLARE @loanamount MONEY;
DECLARE @balance MONEY;

-- Assign the known values to the variables
SET @paymentdate = '03/25/2004';
SET @employeeid = 2;
SET @loanallocationid = 5;
SET @paymentamount = 249.08;

-- Get the amount that was lent to the customer
SELECT @loanamount = (SELECT FutureValue 
					  FROM LoanAllocations
					  WHERE CustomerID = (SELECT CustomerID 
										  FROM LoanAllocations 
										  WHERE LoanAllocationID = @loanallocationid));

-- Debug: Print the loan amount
PRINT 'Loan Amount: ' + CAST(@loanamount AS NVARCHAR(50));

-- If the customer has already made 1 payment, get current balance and sub the current payment from previous balance

SELECT @balance = MIN(Balance)
	FROM Payments
	WHERE LoanAllocationID = @loanallocationid;

IF @balance IS NULL
BEGIN
	SET @balance = @loanamount - @paymentamount;

-- Debug: Print the updated balance
PRINT 'Updated Balance (NULL condition): ' + CAST(@balance AS NVARCHAR(50));
END

ELSE 
BEGIN
	SET @balance = @balance - @paymentamount;
-- Debug: Print the updated balance
PRINT 'Updated Balance (ELSE condition): ' + CAST(@balance - @paymentamount AS NVARCHAR(50));
END

--Insert the calculated values into the table
INSERT INTO Payments (PaymentDate, EmployeeID, LoanAllocationID, PaymentAmount, Balance)
	VALUES (@paymentdate, @employeeid, @loanallocationid, @paymentamount, @balance);

SELECT * FROM Payments
