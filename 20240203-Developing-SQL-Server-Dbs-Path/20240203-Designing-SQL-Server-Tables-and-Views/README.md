
<details><summary>

## Designing and Implementing Tables</summary>

Schema is similar a namespace. `dbo` is the default schema. If the schema it's not especified, the `dbo` will be the schema.  

Table requires a name. There is no table without column. Column requires names and data types. There are constraints.  
- Primary Key - Used to define the primary key which must be unique over all the rows the table will hold.  
- Nullability - The nullability constraint indicates whether it is acceptable for a column to ever have null value for some row. Since there are at least four names required, let's see what SQL Server names can be.  


Names in Sql Server should follow 4 rules for regular identifiers  
- Must begin with a *Letter*, *Underscore (_)*, *At sign (@) has special meaning* or *Number sign (#) has special meaning*.  
- After the first letter, it could contain *Letter*, *Decimal numbers* or *@,$,# or _*.   
- Regular identifiers must not be a T-SQL reserved word.  
- May not contain embedded spaces or special characters.  

Exception rules  
- Rule breakers enclosed in brackets *[]*.  
- An identifier cannot be longer than 128 characters.  


<details><summary> 

### Data Types
</summary>

### Textual Data  

|Type|Length|Data|Uses|  
|-|-|-|-|  
|char(n)|n = 1...8000 - Fixed Length|Non-unicode|This data type always takes n bytes per row. Use it if most of your columns will have the same or mostly the same length or if the length is less than 3. Doing so will ensure less wasted space when compared to the next type.|  
|varchar(n)|n = 1...8000 - Variable Length varchar(max)|Non-Unicode|This is an efficient data type for highly variable data only using the actual data length per row. Names and addresses usually fall into this category. varchar(max) can hold up to 2 GB per column. However, this data type can use more disk space leading to extra I/O. Use it sparingly|  
|nchar(n)| n = 1...4000 - Fixed Length| Unicode|The storage size used is two times n bytes. Use for uniform length or short length character data that requires Unicode. Most systems that store text in multiple languages need Unicode for example.|  
|nvarchar(n)| n = 1...4000 - Variable Length| Unicode|Use it as you would varchar(n) but for circumstances that require Unicode. Nvarchar(max) is similar to varchar(max) and can hold up to 1 GB of characters, since with Unicode data, 2 bytes are used for each character.|  
|text| | | |
|ntext| | | |

### Integer Data

|Type|Length|Usage|
|-|-|-|
|tinyint|0 to 255 1byte| They are handy when you know you have a small set of integer values to store.|
|smallint|-2^15 to 2^15 - 1 2bytes|A value of about -32k to +32k|
|int| -2^31 to 2^31 - 1 4bytes|A value of approximately plus or minus 2.1billion in English System.|
|bigint| -2^63 to 2^63 -1 8bytes|A value approximately of 9.2 sextillion in the English system.|


### Decimal Data

|Type|Length|Comment|
|-|-|-|
|decimal[(p,s)] and numeric[(p,s)]| -10^38 + 1 to 10^38 -1 5 to 17bytes| p = precision is the total number of digits that will be stored ignoring the decimal point s = scale is the number of digits that will be stored to the right of the decimal point. They are optional. The default is p = 18 and s = 0. Decimal and Numeric are synonyms|
|money| 4 decimal places -922337203685477,5808 to 922337203685477,5807 8bytes|SQL Server stores the numeric value only, not the currency symbol|
|smallmoney| 4 decimal places -214748,3648 to 214748,3647 4bytes|Same as money but with a precision of 10. Money types are unique to SQL Server|


### Date Data

|Type|Length|Comments|
|-|-|-|
|date|0001-01-01 to 9999-12-31 3bytes||
|time[(n)]|n = 0 to 7 5bytes|Store times of the day. n = number of fractional seconds to be stored. The default is 7, which stores times as precise as 100 nano seconds. Regardless of the fractional seconds, this type takes 5 bytes to store.|
|datetime|Jan 1, 1753 to Dec 31, 9999 8bytes|is an older data type in SQL Server with definite limits. The date part cannot hold any date before January 1, 1753, and the time part is in 1/1000 of a second, but due to rounding is not stored exactly at that precision. The system stored values are always rounded to increments of .0, .003, or .007 seconds.|
|smalldatetime|Jan 1, 1900 to Jun 6, 2079 4bytes|Does not store fractional seconds|
|datetime2(n)|0001-01-01 to 9999-12-31 6 to 8bytes|Is like the date type combined with the time type. And as with the time type, you can specify the precision of fractional seconds with a default of 7 digits or 100 nanoseconds. And depending on the precision, 6, 7, or 8 bytes are required to store this type.|
|datetimeoffset(n)|0001-01-01 to 9999-12-31 10bytes|Combines datetime2 with a time zone. The ranges of dates and times are the same as for the datetime2 type, and this type always takes 10 bytes to store.|



### Binary strings Types
- binary  
- varbinary  
- image  

### Other data types
- cursor  
- geography (spatial type)   
- geometry (spatial type)  
- hierarchyid  
- json  
- rowversion  
- sql_variant  
- table  
- uniqueidentifier  
- xml  

</details>

### Creating Table

Script to create the database
```sql
CREATE DATABASE <Database name>
GO
```

Show the entry for BobsShoes in the system tables
```sql
SELECT * FROM sys.databases WHERE name = 'BobsShoes';
```


Another thing creating a database does is put files in the file system. The system stored procedure sp_helpfile will display them. This script below will show the filegroup. 
```sql
-- Show the layout of the files for the database
EXEC sp_helpfile;
GO
```
You can see that two files were created, one for data and one for the log. Also note the filegroup names. `PRIMARY` is the default filegroup created If you don't specify one explicitly. 
 
 
Using schemas for user tables is a good practice. Apart from the convenience of having the extra namespaces schemas provide, they're also great for managing security and granting and restricting access. 
```sql
-- Create schema for Bobs Orders
CREATE SCHEMA Orders 
    AUTHORIZATION dbo;
GO
```
 

Now you can create multiple filegroups and put multiple files in each one. The best practice is to put the data in log files on separate drives. The reason is simple. Separating them reduces contention on any one drive and spreads the load around. These commands will do that and set up separate files for data and logs. 
Note that there are actually three names at play here. The first is the name of the filegroup. The second is the logical name of the file as SQL Server refers to it. Think of it as a nickname for the file. And, lastly, the physical name of the file as it exists on the file system. Note the difference between the file types; `.mdf` is used for data files, and `.ldf` is used for log files. And if you have multiple data files, then they would take the file type `.ndf`. Keeping the names in sync is not required.  
```sql
-- Create new filegroups for data and logs

ALTER DATABASE BobsShoes
    ADD FILEGROUP BobsData;
ALTER DATABASE BobsShoes
    ADD FILE (
       NAME = BobsData,
       FILENAME = 'C:\SQLFiles\BobsShoes\BobsData.mdf'
    )
    TO FILEGROUP BobsData;
 
ALTER DATABASE BobsShoes
    ADD LOG FILE ( 
        NAME = BobsLogs,
        FILENAME = 'D:\SQLFiles\BobsShoes\BobsLog.ldf'
    );

GO 
```
Still for standard environments, keeping names in correspondence is a good practice. A filegroup can also have more than one file in it, which can also be helpful for performance tuning in some environments. As well, I could create a separate filegroup for any indexes using similar commands. 
 
 
The next thing to do is create the order tracking table itself. Putting together the needed columns with the data types we want, I can construct a CREATE TABLE statement. From the top, the `USE` command enters the context of the database we just created, BobsShoes. The `GO` command is called a batch separator. Basically commands you write are not sent to the server until a GO command is reached or the end of the input, whichever comes first. 
This begins with the command `CREATE TABLE`, followed by the new table name. Then in parenthesis the list of columns to be created is written. Most of these are the result of the data requirements and types I just reviewed, although there are a couple of new things.  
`IDENTITY`, This property means that whenever a new row is inserted into this table, a new order ID is created. SQL Server tracks the current value of an IDENTITY column in its metadata for the table, and there can be only one such column per table. The values in parentheses are the seed or start value and an increment value. In this case, the start value is set to 1 as is the increment. Because these are the defaults, I can actually leave them out. However, I believe that explicit is better than implicit, so I've included them here.   
`NOT NULL` on most of the columns and NULL on a few of them. This is actually a constraint. Columns marked as NOT NULL must always hold a value. An attempt to insert or update rows with NULL values for these columns will cause an error. And `NULL`, on the other hand, means that NULL values are okay. The delivery date is not known until delivery, so a NULL is permitted. The TotalPrice column is defined using an expression. This is called a `computed column`. Also, this column as defined here is not stored in the database. It is computed every time it is selected. You can force the expression result to be stored by adding a keyword `PERSISTED`, which I've commented out for this example. And the data type for a completed column is inferred from the expression.     
I mentioned that I wanted to use BobsData as the filegroup to hold the data for the order tracking table. Also, I've added a table option for `DATA_COMPRESSION` I recommend you compress most tables and have a good reason if you choose not to. While it does cost CPU cycles to compress and decompress the data, it saves on I/O and the CPU cycles needed to handle that extra I/O. The trade-off is almost always worth it. Here I've specified PAGE level compression. ROW level compression is also available. And note that before SQL Server 2016, data compression was only available in the enterprise edition.
```sql
USE BobsShoes;
GO

CREATE TABLE Orders.OrderTracking (
    OrderId int IDENTITY (1,1) NOT NULL,
    OrderDate datetime2(0) NOT NULL,
    RequestedDate datetime2(0) NOT NULL,
    DeliveryDate datetime2(0) NULL,
    CustName nvarchar(200) NOT NULL,
    CustAddress nvarchar(200) NOT NULL,
    ShoeStyle varchar(200) NOT NULL,
    ShoeSize varchar(10) NOT NULL,
    SKU char(8) NOT NULL,
    UnitPrice numeric(7, 2) NOT NULL,
    Quantity smallint NOT NULL,
    Discount numeric(4, 2) NOT NULL,
    IsExpedited bit NOT NULL,
    TotalPrice AS (Quantity * UnitPrice * (1.0 - Discount)), -- PERSISTED
) 
ON BobsData 
WITH (DATA_COMPRESSION = PAGE);
GO
```

First, it enters the context of the target database, BobsShoes. Then using the ALTER TABLE command, a constraint is added. PK_OrderTracking_OrderId is the name of the constraint. It is defined as a PRIMARY KEY constraint on the OrderId column. I like to use a convention for constraint names where the first two characters are the type of the constraint, so PK for PRIMARY KEY, followed by the name of the table, followed by the columns in the constraint. Note that like table names, constraint and index names must be unique in the database schema. With this constraint in place, SQL Server will stop any attempt to overwrite the OrderId column with a duplicate value. 
This also ensures that the table is a proper relation since at least one column is unique for every row in the table. **Sometimes there's a little confusion around key constraints and indexes**. A key constraint is implemented by SQL Server by creating a matching or backing index. This makes checking the constraint efficient. Also, I could've put an ordinary index on the same column in this table, but it would not have been a constraint. **Constraints and indexes are not the same thing**, but they can support each other. A backing index is always built to support a key constraint. There are more options that can be specified for columns than I've shown here. Some I'll cover later in the modules on normalization and constraints. One, I think worth covering at this point, is collation. Let's look at that.
```sql
USE BobsShoes;
GO

ALTER TABLE Orders.OrderTracking 
ADD CONSTRAINT PK_OrderTracking_OrderId
    PRIMARY KEY (OrderId)
        ON [BobsData];
GO
```

`Collations` Specifies the bit patterns that represent each character in the data set. Collations also determine the rules that sort and compare data. You can specify collations at the instance, database, column, and expression level. SQL Server stores character data as either Unicode or non-Unicode. These map to the data types nchar and varchar and char/varchar respectively. If not specified at the column level, it uses the database collation. If not specified at the database level, it is inherited from the instance, and the instance collation is defined during setup. You can also specify collation on an expression, for example, when doing a comparison. Collations provide sorting rules, case sensitivity, and accent sensitivity properties. For non-Unicode types like char and varchar, collation also dictates the code page to be used and the set of characters available. Now let's go back to Data Studio and explore the collations in the BobsShoes database.

```sql
-- Show the collation configured on the instance
SELECT SERVERPROPERTY('collation') AS DefaultInstanceCollationName;

--SQL_Latin1_General_CP1_CI_AS -> CI_AS = Case Insensitive and Ascent Sensitive

-- Show the collation configured on the database
SELECT DATABASEPROPERTYEX(DB_NAME(), 'collation') AS DatabaseCollationName;

-- Show the collation for all the columns in the OrderTracking table
SELECT name AS ColumnName, collation_name AS ColumnCollation
    FROM sys.columns 
    WHERE object_id = OBJECT_ID(N'Orders.OrderTracking'); 

-- Show the description for the collation
SELECT name, description 
    FROM sys.fn_helpcollations()
    WHERE name = N'SQL_Latin1_General_CP1_CI_AS'; 

-- Show SQL collations not containing 'LATIN'
SELECT name, description 
    FROM sys.fn_helpcollations()
    WHERE name LIKE N'SQL_%' AND name not like N'SQL_Latin%';     

-- Change the customer column to a Scandinavian collation.
ALTER TABLE Orders.OrderTracking
    ALTER COLUMN CustName nvarchar(200) 
        COLLATE  SQL_Scandinavian_CP850_CI_AS 
        NOT NULL;
```

</details>

<details><summary>

## Improving Table Design Through Normalization  
</summary>

##### Normalization is the process of organizing a database to reduce redundancy and improve data integrity.   
https://database.guide/what-is-normalization/  

##### Objetives  for Data Normalization  
- Eliminate Anomalies.  
- Reduce the need for restructuring tables as new requirements or data are added.  
- Make the relational model provide more information to users.  
- Make the tables in the database less sensitive to statistics from queries, especially when those statistics are liable to change.   


##### 1NF  
Has 3 simple rules.  
- There must be only one value per table cell where is the intersection of a row and a column. 
- There must be one table per set of related data.  
- Each row must be unique. Usually attained by introducing a primary key, which enforces uniqueness. A primary key must be unique and not null.    

An `IDENTITY` column is guaranteed to be unique for the table, which will help satisfy rule three. To fully satisfy rule three, tables have a PRIMARY KEY defined.
A `PRIMARY KEY` is a type of constraint and simply means no duplicates. A PRIMARY KEY is a constraint. In general, `constraints` are used by SQL Server to preserve data and referential integrity by prohibiting operations that will violate the constraints.  
The indexes created for PRIMARY KEY constraints are sometimes called backing indexes. They are not strictly required for rule three, but make it faster for SQL Server to check for duplicates since the alternative would be to read the entire table every time you had to insert a new row just to be sure there are no duplicates.
The `clustered` property, says that the table data is ordered by the clustering key. Since table data can only be ordered one way, there can only be one clustered index. There is another type of index called `nonclustered` that does not impose any order to the table data.

##### 2NF   
Builds upon the first.  
- The database must be in first normal form or 1NF
- The second rule states that only single column primary keys are allowed. Well, actually the requirement is stated like this, no non-key attributes should be dependent on any proper subset of the key. Although it's possible to satisfy this rule with a composite key, if there are no composite keys, then the only proper subset is the empty set. That implies a single column primary key, which is the standard approach to this problem. And this will mean a change to the Stock table we just built since its composite key is comprised of two columns, the SKU and the Size. But if I change that, I will also have to change the OrderItems table, which refers to the Stock table by those same two column. Let's see that in the next demo.

##### 3NF  
- The database must be in second normal form or 2NF. The second rule states that column values should only depend upon the key. This also implies that for any table in 3NF, an update to one column should not cause an update to another column unless that other column is a key. A memorable way to describe 3NF is captured in this quote from Bill Kent, who wrote a guide to normal forms back in 1983. He said, "Every non-key must provide a fact about the key, the whole key, and nothing but the key. " Any column in the table that is not part of the table key is a non-key. These are usually called attributes in relational language. So there should be no column that is not dependent on the key.

##### Other Normal Forms  
BCNF - Boyce Codd normal form (3.5)  
4NF  
5NF  
6NF  

</details>


<details><summary>

## Constraints
</summary>

Ensuring Data Integrity with Constraints


Using `NULL` and `DEFAULT` Constraints
Part of E. F. Codd's original work on relational databases included a special marker for the absence of a value. We call that marker `null`. A value may be absent because it is unavailable or because it is inapplicable. ***Tony Hoare's billion-dollar mistake***
A `DEFAULT` constraint is used to provide a default value for a column. The default value will be added to all new records if no other value is specified. This can help when a column has a NOT NULL constraint. If a DEFAULT constraint is also specified, and if you don't know the value of that column when a new row is inserted, the default will be used instead. Defaults can be constants like strings or numbers and can also be function calls, which can be quite useful.   

Demo 1 - NULL and DEFAULT Constraints
It begins with the ALTER TABLE command and specifies the table to be changed. Then there is an ADD CONSTRAINT subcommand. This command takes an optional constraint name. I highly recommend that you give proper names to all your constraints, including default constraints. If you don't, SQL Server will assign one with a random number on the end. I name them similar to the way I name key constraints. Start with DF, then add the table and column name and a brief hint as to what the default will be, a call to the Getdate function in this case. 
```sql
-- Add default constraint for the OrderDate

ALTER TABLE Orders.Orders
    ADD CONSTRAINT DF_Orders_OrderDate_Getdate 
        DEFAULT GETDATE() FOR OrderDate;
```
The next section indicates what the type of the constraint is, hence the word DEFAULT. That is followed by the default value, a call to the GETDATE function in this case. Finally, we identify the call in the constraint will be applied to. That's what `FOR OrderDate` means. In fact, you cannot alter a constraint. You have to drop it and recreated it, like this.
And that is the rule for all constraints, not just default constraints.
```sql
 -- Alter a default constraint, this instruction won't work

 ALTER TABLE Orders.Orders
    ALTER CONSTRAINT DF_Orders_OrderDate_Getdate 
        DEFAULT GETDATE()+1 FOR OrderDate;

-- Alter a default constraint, the right way

ALTER TABLE Orders.Orders
    DROP CONSTRAINT DF_Orders_OrderDate_Getdate;

 ALTER TABLE Orders.Orders
    ADD CONSTRAINT DF_Orders_OrderDate_Getdate_Plus_1
        DEFAULT GETDATE()+1 FOR OrderDate;
```

Implementing the PRIMARY KEY Constraint
SQL Server implements the PRIMARY KEY constraint with a backing index. And therein lie a few choices. The first choice is an important one. Since the primary key is backed by an index, what kind of index should that be? There are two choices--`clustered` and `nonclustered`.
Clustered indexes sort and store data rows in the table based on their key values. These are the columns included in the index definition. These keys are stored in a special structure called a B-tree that enables SQL Server to find the row or rows associated with the key values quickly and efficiently. There can be only one clustered index per table, however, because the data rows themselves can be stored in only one order. 
If a table has no clustered index, it is called a heap. Data rows are stored wherever they fit in no particular order. This is why we say that a table is either a clustered index or a heap. It has to be one or the other. Now if your primary key is an identity column on a clustered index, like I've been using for Bob's Shoes order system, this means that new rows, which get new ever-increasing identity values, will always be inserted at the end of the data and that the data is always in order of the ID. Since SQL Server maintains a clustered index in sorted order, it means less I/O when inserting new rows and when reading the table in the order of the identity column. On the other hand, if your application mainly reads from a table in a different order other than that of the identity column, this can mean more jumping around the disk to get the rows you want. For example, if you're producing a report of customers, chances are you want to keep that report in the order of the customers' names, not their IDs. So before you just take the default and use a clustered index for your primary key, take a look at the alternative.

Using Index Types and the UNIQUE Constraint
Nonclustered indexes have a structure separate from the data rows. A nonclustered index contains the nonclustered index key values, and each key value entry has a pointer to the data row that contains the key-value. That data row may be part of a clustered index or a heap. Like clustered indexes, the nonclustered index structure is stored as a B-tree for efficient retrieval. Nonclustered indexes do not affect data rows when changes happen to the index. Only the index structure is affected, and usually that is a small fraction of the size of the data rows. And nonclustered indexes might also include some of the data columns. This option can reduce I/O for columns that are frequently accessed using the nonclustered index. 

A `UNIQUE` constraint makes sure that there are no duplicate values of a column or columns independently of the primary key. One difference with primary keys is that the UNIQUE constraints allow for the value null. However, since this constraint enforces uniqueness, there can be only one null value per index column. UNIQUE constraints are ideal for business keys in tables where the primary key is a surrogate key such as an integer column with the IDENTITY property. A UNIQUE constraint can also be referenced by a foreign key. And like primary keys, UNIQUE constraints are backed by an index. That means you need to decide if that should be a clustered or nonclustered index.


Mixing up the PRIMARY and UNIQUE constraints with the two index types, clustered and nonclustered. It has just two columns, an ID and the salutation itself. Here I've modified the definition we had by adding a UNIQUE constraint. Notice that it looks like a PRIMARY KEY constraint. And you should give it a name. I'm using the prefix UQ here to identify my constraint as a UNIQUE constraint, then the keyword UNIQUE followed by the type of index. If the type of index is not specified, a UNIQUE constraint defaults to a nonclustered index and a primary key to a clustered index unless there is already a clustered index, in which case a primary key will be backed by a nonclustered index.
You may be worried about putting a UNIQUE constraint on the IDENTITY column since UNIQUE constraints allow nulls. However, this also has the NOT NULL constraint so that property is still enforced. Also, SQL Server will never generate a null for a new identity value. In the Customers table definition that follows, a FOREIGN KEY reference does not care whether the reference is the PRIMARY KEY or UNIQUE constraint. Either will do. 

```sql
-- "Normal" primary key and unique constraints

CREATE TABLE Orders.Salutations (
    SalutationID int IDENTITY(1,1) NOT NULL                             
        CONSTRAINT PK_Salutations_SalutationID  -- Defaults to system-generated name
            PRIMARY KEY CLUSTERED,             
    Salutation varchar(5) NOT NULL
        CONSTRAINT UQ_Salutations_Salutation    -- Defaults to system-generated name
            UNIQUE NONCLUSTERED                 
);

-- Switching the index types

DROP TABLE IF EXISTS Orders.Salutations;
CREATE TABLE Orders.Salutations (
    SalutationID int IDENTITY(1,1) NOT NULL
        CONSTRAINT UQ_Salutations_SalutationID 
            UNIQUE CLUSTERED,
    Salutation varchar(5) NOT NULL
        CONSTRAINT PK_Salutations_Salutation 
            PRIMARY KEY NONCLUSTERED
);
```

Added a unique index on that (StockSKU and StockSize) as a new table constraint. It must be done this way since two columns are involved.  
This is an example of a index (UQ_Stock_StockSku_StockSize) not being the primay key in fact, but is still a index though. And the primary key is a surrogate column (StockId)
```sql
CREATE TABLE Orders.Stock (
    StockID int IDENTITY(1,1) NOT NULL -- Surrogate column
        CONSTRAINT PK_Stock_StockID PRIMARY KEY CLUSTERED, 
    StockSKU char(8) NOT NULL,
    StockSize varchar(10) NOT NULL,
    StockName varchar(100) NOT NULL,
    StockPrice numeric(7, 2) NOT NULL, 
        CONSTRAINT UQ_Stock_StockSKU_StockSize 
            UNIQUE NONCLUSTERED (StockSKU, StockSize) -- Business Key    
);

```



More About Foreign Key Constraints
A foreign key works by building and enforcing a link between two tables. This link controls the data that can be stored in the foreign key table. The link is controlled by referencing a primary or unique key in a base table from a referencing table with the same columns as the key in the base table. The OrderItems table references the Orders table by including the OrderId, and the OrderItems table refers to the Stock table by another foreign key.  
Foreign key definitions on those columns enforce the links. Foreign keys help preserve referential integrity. For example, in the OrderItems table, I cannot add a new row referencing a nonexistent OrderId. Also, I cannot delete or update the key in the base table since it is bound by the FOREIGN KEY constraint, but this can be a problem in some situations. For example, suppose Bob's Shoes stopped carrying brown sandals in size 17. No problem, you say. Just delete that row from the Stock table. Well, suppose there is an existing order for just that shoe in just that size. There are a few options. Issue an error message and stop the deletion leaving an order for a discontinued product, delete the OrderItems that match that Stock item, or perhaps replace the FOREIGN KEY reference in the OrderItems table with a null. The rules for handling this situation and others like it are known as cascading referential integrity. 
```sql
CREATE TABLE Orders.Orders (  
    OrderID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Orders_OrderID PRIMARY KEY,
    OrderDate date NOT NULL,
    OrderRequestedDate date NOT NULL,
    OrderDeliveryDate datetime2(0) NULL,
    CustID int NOT NULL
        CONSTRAINT FK_Orders_CustID_Customers_CustID 
            FOREIGN KEY REFERENCES Orders.Customers (CustID),
    OrderIsExpedited bit NOT NULL
 );

CREATE TABLE Orders.OrderItems (
    OrderItemID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_OrderItems_OrderItemID PRIMARY KEY,
    OrderID int NOT NULL
        CONSTRAINT FK_OrderItems_OrderID_Orders_OrderID
            FOREIGN KEY REFERENCES Orders.Orders (OrderID),
    StockID int NOT NULL
        CONSTRAINT FK_OrderItems_StockID_Stock_StockID
            FOREIGN KEY REFERENCES Orders.Stock (StockID),
    Quantity smallint NOT NULL,
    Discount numeric(4, 2) NOT NULL
);

```

Options of FOREIGN KEY Constraints when deleting the foreign key
- Cascade Option - Means to update any referencing tables with the changes made to the referenced table.   
- NO ACTION - Means do not allow the delete or update, which means throw an error and leave things as they are. This is the default setting.   
- SET NULL - Means set the foreign key values to null if the corresponding row in the base table is updated or deleted. For this constraint to execute, the foreign key columns must be nullable.  
- SET DEFAULT as the name implies sets the foreign key values to their default values when the corresponding row of the base table is updated or deleted. If no default is defined and the column is nullable, the value is set to null. One difference between primary keys and foreign keys is that with foreign keys, the backing index is not automatically created. However, creating such an index is recommended in many situations.

Introducing CHECK Constraints
A CHECK constraint is a way of declaring limits and validations on data inserted to or updated in a table. Since the CHECK constraint is part of the table definition, it is automatically performed by SQL Server.  Can be defined at the column and table levels. And you can have as many as you need or want. Internally all CHECK constraints are table constraints, but SQL Server accepts simplified syntax when CHECK constraints are defined at the column level. The basic parts of a CHECK constraint are its name and the condition to be checked. The condition must evaluate to a Boolean expression, true or false. The expression can be any valid T-SQL expression including comparisons, membership tests using IN, function calls, and anything else you can dream up as long as it evaluates to true or false. One type of expression not supported by SQL Server or by the majority of commercial databases is a query, that is, your check condition cannot contain a SELECT statement even though that is included in the ANSI SQL standard. However, you could call a function that does contain a SELECT statement.  

Using CHECK Constraints   
Starting with the Salutations table. A salutation is useless if it is blank. So I've got a CHECK constraint to prevent that. Note the name used.
```sql
DROP TABLE IF EXISTS Orders.Salutations;
CREATE TABLE Orders.Salutations (
    SalutationID int IDENTITY(1,1) NOT NULL                             -- PRIMARY KEY -- system-generated name
        CONSTRAINT PK_Salutations_SalutationID PRIMARY KEY CLUSTERED,
    Salutation varchar(5) NOT NULL                                      -- UNIQUE -- system-generated name
        CONSTRAINT UQ_Salutations_Salutation UNIQUE NONCLUSTERED
        CONSTRAINT CK_Salutations_Salutation_must_not_be_empty CHECK (Salutation <> '')
)
```
The error message of this check will include the name of the constraint being violated.

Example of the use of scalar function used on the check.  
```sql

-- Create a user function to check dates
GO
CREATE OR ALTER FUNCTION Orders.CheckDates 
    (@OrderDate date, @RequestedDate date)
    RETURNS BIT
    AS BEGIN
        RETURN (IIF(@RequestedDate > @OrderDate, 1, 0))
    END
GO

-- Define a table constraint to use the function
DROP TABLE IF EXISTS Orders.Orders;
CREATE TABLE Orders.Orders (  
    OrderID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_Orders_OrderID PRIMARY KEY,
    OrderDate date NOT NULL,
    OrderRequestedDate date NOT NULL,
    OrderDeliveryDate datetime2(0) NULL,
    CustID int NOT NULL
        CONSTRAINT FK_Orders_CustID_Customers_CustID 
            FOREIGN KEY REFERENCES Orders.Customers (CustID),
    OrderIsExpedited bit NOT NULL,
    CONSTRAINT CK_Orders_RequestedDate_must_follow_OrderDate
        CHECK (1 = Orders.CheckDates(OrderDate, OrderRequestedDate))
 );
```

If you use a function in a CHECK constraint, and you later change the function so that it returns different results, SQL Server will not automatically reject the constraint. You need to do that manually. There's an ALTER TABLE command for that that tells SQL Server to explicitly CHECK a constraint.
```sql
 -- Validate the table against the check constraint
 ALTER TABLE Orders.Orders 
    WITH CHECK CHECK CONSTRAINT 
        CK_Orders_RequestedDate_must_follow_OrderDate;
```
If that helper function changes, you'll need to find all the places it is referenced to recheck the constraints and verify that the change to the function does not break anything.



Options for Defining CHECK Constraints
You can add constraints when you create a table. They can be specified at either the column level or the table level. Remember to use a table constraint if two or more columns are involved. You can have multiple constraints per column or table in either location. The only exceptions are `FOREIGN KEY` constraints, which ***cannot be used with temporary tables or table variables***. You can add new constraints at any time using the ALTER TABLE ADD CONSTRAINT command. Both column and table constraints can be added this way.  
By default, SQL Server will check the table against the newly added constraint. The optional parameter `with no check` will add the constraint without checking the table. The default is to check that there are no constraint violations and issue an error message if any are found. If you no longer need a constraint, you can remove it using the `ALTER TABLE DROP CONSTRAINT` command. You also need this to change a constraint since there is no ALTER CONSTRAINT command. Changing constraints always means dropping and re-creating them. By the way, if you drop a key constraint backed by a clustered index, the table becomes a heap. If you need to temporarily disable a constraint, use the `ALTER TABLE NOCHECK CONSTRAINT`. You might do this, for example, when bulk inserting data known to be good, and the constraint slows down the INSERT operation enough to be a problem. Note that you can only disable FOREIGN KEY and CHECK constraints, not other constraint types. You can re-enable or disable a constraint with the ALTER TABLE CHECK CONSTRAINT command. If you want to also reject the constraint, add the WITH CHECK option to the command. For example, you might use `WITH CHECK` after modifying a function used in a check constraint or to verify FOREIGN KEY constraints. The ALTER commands all need a constraint name, but you can also use the keyword ALL to perform the action to all constraints at once.

</details>

<details><summary>

## Views
</summary>

Three types of views basic, partition, and indexed.  
A developer can write, test, and optimize a query for general use. That query can then be encapsulated in a view, which can be used instead of the bare query.
`David Parnas` came up with the idea of `information hiding` back in 1972. Then it was in the context of object oriented program design. The principle is that `of segregating the design decisions that may change or are likely to change`. 
It applies here since the tables underlying a view may change their schema or column names, but an application program, which may be just another piece of T-SQL code, can use the view as an interface to the base tables. Let's hide the base tables in this view. To do that, I'll simply alias the columns from the original tables. This ALTER statement does that. Now when I select from the view, the schemas of the base tables are hidden. I've achieved the desired segregation that information hiding offers.

```sql
-- alter the view to add column aliases
CREATE OR ALTER VIEW Orders.CustomerList 
AS
  SELECT 
    cust.CustName             AS Name, 
    sal.Salutation            AS Salutation,
    cust.CustStreet           AS Street, 
    city.CityStateCity        AS City, 
    city.CityStateProv        AS StateProv,
    city.CityStatePostalCode  AS PostalCode,
    city.CityStateCountry     AS Country
  FROM orders.Customers cust
    INNER JOIN Orders.CityState city
      ON cust.CityStateID = city.CityStateID
    INNER JOIN Orders.Salutations sal
      ON cust.SalutationID = sal.SalutationID;
GO

SELECT 
  cl.Salutation,
  cl.Name,
  cl.Street,
  cl.City,
  cl.StateProv,
  cl.PostalCode,
  cl.Country

FROM Orders.CustomerList cl;
```

Using WITH SCHEMABINDING
There's a problem with the view I just defined. It's not obvious at first, so let me show you. Here I have a script to illustrate the problem. First, I create a test table with just two columns, an integer and a float. I populate that table with some sample values. Next, I create a view on that test table. I can easily query the view and get the table contents. Now I'll drop the table. SQL Server does not complain. But what if I query the view again? Boom! It throws an exception unsurprising. But that's a problem. Any application program including other T-SQL code will now break if it tries to query the view. How about something more subtle? I'll redefine the table but with a twist. I've switched the meaning and datatypes of the two columns. The view seems to work again, but does it work as expected? It does not. The first column was supposed to be an integer, and the second a float, not the other way around. Again, application code using this view will break. What can I do? Well, let's go back to the top of this script. This time I'll add an option to the view, WITH SCHEMABINDING. 

When you use the option WITH SCHEMABINDING in a view, three rules apply.
- First, the tables the view references cannot be changed without modifying or dropping the view first. The tables can neither be altered nor dropped. This protects application code against such attempts.
- Second, any SELECT statement in the view must use two-part names, that is, the schema name plus the object name, for any tables' functions and other views referenced. And this rule also implies the third rule,
- Third, all referenced objects must be in the same database. In other words, three- or four-part names are not permitted. As a general rule, use WITH SCHEMABINDING whenever you can.
  
```sql
-- Example of a view using SCHEMABINDING  
-- Create test table
DROP TABLE IF EXISTS foo;
CREATE TABLE foo (a int, b float);
INSERT INTO FOO (a, b) VALUES (42, 3.14159);
GO

-- Create a view on the test table
CREATE OR ALTER VIEW bar
WITH SCHEMABINDING
AS
    SELECT 
        a AS an_integer, 
        b as a_float 
    FROM dbo.foo;
GO

```

Like tables, views can be updated, subject to certain restrictions. That means that you can insert, delete, and update rows in A table through view. but in order for this to work, SQL Server has to know what table to update.
Restriction. 
- Any modifications, including UPDATE, INSERT, and DELETE statements, must reference columns from only one base table. That means that if your view joins two or more tables, you can update only one of those tables through the view.
- The second restriction is that the columns being modified must directly reference the data in the base table so the columns cannot be derived, which excludes aggregate functions like sum or average, computed columns and columns from set operators like union and intercept.
-  The third rule says that the columns being modified must not be affected by GROUP BY, HAVING, DISTINCT, PIVOT, or UNPIVOT clauses. This rule and the previous one are consequences of the first rule. Also, your view cannot use TOP or an OFFSET clause together with the WITH CHECK OPTION clause. It forces all data modification statements executed against the view to follow the conditions in the SELECT statement by making sure that the data remains visible through the view after the modification is committed.

```sql
CREATE OR ALTER VIEW Orders.CustomerList 
WITH SCHEMABINDING
AS
  SELECT 
    cust.CustName             AS Name, 
    sal.Salutation            AS Salutation,
    cust.CustStreet           AS Street, 
    city.CityStateCity        AS City, 
    city.CityStateProv        AS StateProv,
    city.CityStatePostalCode  AS PostalCode,
    city.CityStateCountry     AS Country
  FROM orders.Customers cust
    INNER JOIN Orders.CityState city
      ON cust.CityStateID = city.CityStateID
    INNER JOIN Orders.Salutations sal
      ON cust.SalutationID = sal.SalutationID;
GO

UPDATE Orders.CustomerList
SET name = 'Trillian Dent', Salutation = 'Mrs.'
WHERE name = 'Trillian Astra';
GO
```

#### Indexed Views

Putting one or more indexes on a view can speed up your queries.
Most of the requirements stem from the fact that a view must be deterministic.
An indexed view is a persisted object stored in the database in the same way that table indexes are stored.
Another word sometimes used is materialized. That means that the index is written to disk. So, while the underlying view is still a virtual table, any index on it is no longer virtual. It is stored in physical form just like an ordinary table index.
Now the query optimizer may use indexed views to speed up the query execution. The view does not have to be referenced in the query for the optimizer to consider it for substitution, and that last part is worth repeating. The view does not have to be referenced in the query for the optimizer to consider that view for a substitution. You can get performance gains from an indexed view without even referencing it or using it by name on purpose. SQL Server knows that it is there and will use it if it thinks it will speed things up. clustered indexes define the order in which database pages are stored so that the table becomes a clustered index as opposed to a heap. Non-clustered indexes are separate objects that point to table pages whether the table is a clustered index or a heap. Indexed views are only slightly different in that they are never stored as heaps. That means there must always be a clustered index on a view, and that's a great segue into the general requirements.

Requirements for Indexed Views
The first requirement for an indexed view is that the first index must be a unique clustered index. After the unique clustered index has been created, you can create one or more non-clustered indexes. Creating a unique clustered index on a view improves query performance because the view is stored in the database in the same way a table with a clustered index is stored.
Indexed views require that certain SET options be in effect at creation time. 
The view upon which you want to create an index must be deterministic.
Any view that you create an index on must have been created using the WITH SCHEMABINDING option. Also, any functions referenced by the view must have, likewise, been created using this option.

There is a list of T-SQL elements that may not be used in the SELECT statement in the view definition upon which you wish to place an index. The list is long, and these are the important ones. 

And note that if a view contains a GROUP BY clause, the key of the unique clustered index can reference only the columns specified in that clause. To make sure that indexed views can be maintained correctly and return consistent results, they require fixed values for several SET options. This is another way of saying that the view must be deterministic. 
And this table shows those options. There are seven SET options with the required settings given in the second column labeled Required. Note that the required values are the same as the Server Default settings. However, you cannot generally count on the defaults being in effect. The rule, Explicit is better than implicit, applies here. And note that the defaults for OLEDB/ODBC and DB-library are different from the requirements and the server defaults. Also, if you set ANSI warnings to ON, that action implicitly sets ARITHABORT on as well. When you set them to OFF, an arithmetic overflow or divide by 0 does not cause an error, and null is returned instead. 
|SET option|Required|Server Default|OLEDB/ODBC Default|DB-library Default|
|-|-|-|-|-|
|ANSI_NULLS|ON|ON|ON|OFF|
|ANSI_PADDING|ON|ON|ON|OFF|
|ANSI_WARNINGS*|ON|ON|ON|OFF|
|ARITHABORT|ON|ON|OFF|OFF|
|CONCAT_NULL_YIELDS_NULL|ON|ON|ON|OFF|
|NUMERIC_ROUNDABORT|OFF|OFF|OFF|OFF|
|QUOTED_IDENTIFIER|ON|ON|ON|OFF|

The definition of an indexed view must be `deterministic`. That means that all expressions, including those in the WHERE and GROUP BY clauses and the ON clauses of joins must always return the same result when evaluated with the same argument values. An example of a deterministic function is DATEADD since it always returns the same result with the same inputs.
One of the properties of every column is the `IsDeterministic` property. You can query this with the `COLUMNPROPERTY` function. Now floating-point data is a special problem since the exact result of an expression with floating-point numbers may depend on the processor or microcode versions in use. Such expressions cannot be in the key columns of an indexed view. Deterministic expressions that do not contain float expressions are called precise, and that is what you need for key columns and for WHERE, GROUP BY, and the ON clauses of indexed views. The COLUMNPROPERTY function will also show you if a computed column is precise. 

Determining Determinism
Here I have a script that tries to create an indexed view where at least one column is not deterministic and precise. First, I drop any existing view of the same name. Then I create the view WITH SCHEMABINDING as required. The view has two computed columns. The first is just A concatenation of an OrderId and an OrderItemId. But the second uses a floating-point number in its computation.
```sql
USE BobsShoes;
GO

DROP VIEW IF EXISTS foo;
GO

-- Create a test view using computed columns
CREATE VIEW foo
WITH SCHEMABINDING
AS
SELECT 
    CONCAT(oi.OrderID, oi.OrderItemID) AS One, 
    oi.Discount * cast(.90 as [float]) AS Two
FROM Orders.OrderItems oi;
GO
```
 Now having created this view, I can query the COLUMNPROPERTIES. Note that the first column, the concatenation of Order and ItemIds, is both deterministic and precise. But the second column, while deterministic, is not precise since it involves a floating-point number. Now let me try to create an index on this view. It fails. Note the error message. Column 2 is the problem.
```sql
-- Query to show if columns are deterministic and precise
SELECT 
    COLUMNPROPERTY(OBJECT_ID(N'foo'), 'One', 'IsDeterministic') AS OneIsDeterministic,
    COLUMNPROPERTY(OBJECT_ID(N'foo'), 'One', 'IsPrecise') AS OneIsPrecise,
    COLUMNPROPERTY(OBJECT_ID(N'foo'), 'Two', 'IsDeterministic') AS TwoIsDeterministic,
    COLUMNPROPERTY(OBJECT_ID(N'foo'), 'Two', 'IsPrecise') AS TwoIsPrecise;

-- Try to index the view
DROP INDEX IF EXISTS ix_foo ON foo;
CREATE UNIQUE CLUSTERED INDEX ix_foo ON foo(One, Two);

DROP VIEW IF EXISTS foo;
```

YMIVR - Yet More Indexed View Requirements
There are a number of other requirements placed on indexed views, so many that it would be a little tedious to go over each one, but let me highlight a few of the forbidden T-SQL elements: COUNT, ROWSETs, OUTER JOINS, derived tables, self-joins, sub-queries, DISTINCT, TOP, ORDER BY, UNION, EXCEPT, INTERSECT, MIN, MAX, PIVOT, UNPIVOT, and many more. See the official documentation for full details. At the time of writing, this bit.ly link opened up the page. Or you can simply search for Create Indexed Views in SQL Server. One other problem area concerns date literals. Look at the expression at the top. What is that date? Well, it depends on the locale setting. Some locales read this as the 12th of January, and others as the 1st of December. The ISO format, however, is always read as year, month, day, so January 12, 2020, in this example. It is deterministic. If you use date literals in your indexed views, the recommendation is to explicitly convert them to the type you want. The CAST and CONVERT functions have format styles that are deterministic. Use those. 

Demo 2 - Indexing the Customer List View
To create any index on a view, there must be a unique clustered index. Customer names are not unique, even if you include all the other attributes in the view. But the CustomerID is unique, since that is generated by SQL Server. 
```sql
USE BobsShoes;
GO 

-- Customer List view
CREATE OR ALTER VIEW Orders.CustomerList 
WITH SCHEMABINDING
AS
  SELECT
    cust.CustID               AS CustomerID,
    cust.CustName             AS Name, 
    sal.Salutation            AS Salutation,
    cust.CustStreet           AS Street, 
    city.CityStateCity        AS City, 
    city.CityStateProv        AS StateProv,
    city.CityStatePostalCode  AS PostalCode,
    city.CityStateCountry     AS Country
  FROM orders.Customers cust
    INNER JOIN Orders.CityState city
      ON cust.CityStateID = city.CityStateID
    INNER JOIN Orders.Salutations sal
      ON cust.SalutationID = sal.SalutationID;
GO
```
Now that I have a new view, I'll put the first index on it. Here I will create the unique clustered index. 
```sql
-- Create a Unique, clustered index on the view
DROP INDEX IF EXISTS UQ_CustomerList_CustomerID ON Orders.CustomerList;
CREATE UNIQUE CLUSTERED INDEX UQ_CustomerList_CustomerID
    ON Orders.CustomerList(CustomerID);
GO
```

I can select from the view as before, and now SQL Server has the option of using the new index in its execution plans. I'm working with a very small data set, however, so the new index may not be chosen. Notice the one option I've commented out, EXPAND VIEWS. This tells SQL Server to ignore any index on the view and expand the view into queries on the underlying tables. If I uncomment this line and run the query, the execution plan shows this in action. All the tables referenced in the view are queried directly. In other words, the view was expanded as the name of the option implies.
```sql
-- Query the view
SELECT CustomerID, Name, Salutation, City
    FROM Orders.CustomerList 
    WHERE CustomerID = 1
    -- OPTION (EXPAND VIEWS);
GO
```

Adding a Nonclustered Index and Views with Aggregates
Now let me also put a non-clustered index on this view, this time using the Name and PostalCode columns. There, the query works fine, and here I can also use the option EXPAND VIEWS if I want to.
```sql
-- Create a non clustered index on the view
DROP INDEX IF EXISTS IX_CustomerList_Name_PostalCode ON Orders.CustomerList;
CREATE NONCLUSTERED INDEX IX_CustomerList_Name_PostalCode  
    ON Orders.CustomerList(Name, PostalCode);
GO

-- Query the view
SELECT Name, PostalCode
    FROM Orders.CustomerList
    -- OPTION (EXPAND VIEWS);
GO
```

Here's another view, the OrderSummary view. 
```sql
USE BobsShoes;
GO

-- Create the View
CREATE OR ALTER View Orders.OrderSummary
WITH SCHEMABINDING 
AS 
    SELECT 
        o.OrderID,
        o.OrderDate,
        IIF(o.OrderIsExpedited = 1, 'YES', 'NO') AS Expedited, -- Comment
        -- o.OrderIsExpedited,   -- Add
        c.CustName, 
        SUM(i.Quantity) TotalQuantity
        -- ,COUNT_BIG(*) AS cb      -- Add

    FROM Orders.Orders o
    JOIN Orders.Customers c 
      ON o.CustID = c.CustID
    JOIN Orders.OrderItems i
      ON o.OrderID = i.OrderID
    GROUP BY o.OrderID, o.OrderDate, o.OrderIsExpedited, c.CustName
GO

-- Create the first index
CREATE UNIQUE CLUSTERED INDEX UQ_OrderSummary_OrderID
  ON Orders.OrderSummary (OrderID);
GO

SELECT *
FROM Orders.OrderSummary;
```
Let's index that. Oops! I got an error. It seems I need to use the COUNT_BIG function here. In fact, the full rule is that if there is a GROUP BY, there must also be a COUNT_BIG. so let's put that in. Second try. Oops! Another error. The view contains an expression on the result of an aggregate function or grouping column. In this case, the problem is the in-line IF expression on the IsExpedited column. I'll remove that. Note that since an in-line IF is syntactic sugar for a CASE expression, using CASE here would not be any better.
The index is successfully created. Since the view contains an aggregated column, the sum of the quantities, the index then persists that aggregate. For querying, this means that SQL Server no longer has to process the base tables to get those values. They are part of the view's clustered index and can give a nice performance boost. This is not without a cost however, since if Orders or OrderItems are inserted or updated or deleted, then part of the index view will also have to be updated. Like so many things in database design, it's required to weigh the cost against the benefits. For example, if you know that the view will be queried many more times than the base tables are updated, the index is probably worth it. The best approach is to get a baseline of current performance, then decide if the savings of having an index on a view is worth the cost of updating it when the base tables change.

Summary     
Since views in many respects can be thought of as virtual tables, the idea of indexing them is not unexpected. What can be unexpected, though, is the long list of requirements and restrictions placed on indexed views. When you create an indexed view, it is persisted to permanent storage just like an index on a table. This can lead to an increase in performance since SQL Server now has another option for satisfying a query. And depending on the edition of SQL Server you are running, the database engine will look at indexed views even if not specified in a query. Unlike table indexes, however, the first such index must be a unique clustered index. There is no such thing as an indexed view stored as a heap. Also, you cannot put a primary key on an indexed view. A primary key is a constraint, and that belongs on a base table. Second and subsequent indexes are non-clustered since there can be only one clustered index per object. A view that is indexed may contain certain aggregations, sum, for example. And, finally, as with all indexes, indexed views must be maintained as the base tables change. This can be costly, and that cost needs to be weighed against any perceived performance gains.

====== Organizar daqui pra baixo
#### Partitioned Views


Outlining a Partitioned View
Generally a partitioned view is defined like this. It begins like any other CREATE VIEW statement, and you SELECT the data from the first table. That is followed by a UNION ALL operator and a SELECT statement for the data from the second table. If there is a third table, there is another UNION ALL and a SELECT statement for that data. This can be continued if you have additional tables with no built-in limit to the number of member tables in the partitioned view. The requirement for UNION ALL for partitioned views and the proscription against the UNION operator for indexed views implies that partitioned views cannot be indexed. However, there are some other requirements and conditions. Let's look at those. The SELECT statements in a partitioned view should contain all columns in the underlying base tables. And columns in the same position in each SELECT list should be of the same type, not just types that can be implicitly converted, but the same actual types. Though not explicitly stated, generally you want to ensure that the columns also have the same semantic contents, such as dates, names, and quantities. At least one column in the same position across all the SELECT statements should have a CHECK constraint. That constraint has to be defined so that only one base table in the view can satisfy the constraint. That is, the member tables cannot have any overlapping intervals with respect to the constraint. This column is called the partitioning column and can have different names in each of the tables if required. In practice, though, keep column names the same across the member tables if at all possible to avoid confusion. Such column names are also called conformant. And, finally, a column can appear only once in each SELECT list.

Requirements and Restrictions
Requirements for partitioning columns.
- First, the column needs to be part of the primary key of the table. This helps SQL Server ensure that any queries against the partition view only have to scan one table in the view if the partitioning column is specified in the query. Of course, if the partitioning column is not specified in a query to the view, all tables will be involved.
- Second, the partitioning column cannot be computed or have the IDENTITY property or have a default value, nor may it be a timestamp column, also known as a row version column, the official documentation contains a full discussion with examples.
- Third, there can be only one partitioning constraint defined on this column. Otherwise, the definition is considered to be ambiguous.
- Fourth, there are no restrictions on the updateability of the partitioning column, at least not from the perspective of the partitioned view. Naturally any constraint on the column still applies to inserts and updates. The tables participating in a partitioned view are called member tables. They may be on the same instance as the partitioned view or on different instances including remote servers referenced through four-part names or open data source or open row set table names. If one or more of the tables is remote, the view is called a distributed partitioned view and has even more restrictions that you can find in the official docs. A member table can appear only one time in the set of tables combined with the UNION ALL statement. And no member table may have an index on a computed column whether persisted or not. All member tables should have similar primary keys. Practically, this means that the corresponding columns in each table should be of the same type and in the same order and that there should be the same number of columns in the primary keys of each member table. This means that the only things that can differ are the column names.
- Finally, member tables must all have the same ANSI padding settings. This controls the way the column stores values shorter than the defined size of the column and the way the column stores values that have trailing blanks in char, varchar, binary, and varbinary data. The recommendation is that this option always be set to On. Don't change it without properly understanding all the implications, not just those for partitioned views. 

```sql
USE BobsShoes;
GO

-- Drop any existing order tables and views
DROP VIEW IF EXISTS Orders.PartitionedOrders, Orders.OrderSummary, Orders.TotalOrderItems;
DROP TABLE IF EXISTS Orders.OrderItems, Orders.Orders, Orders.Orders2018;

CREATE TABLE Orders.Orders (  
    OrderID int IDENTITY(1,1) NOT NULL,                -- Was primary key
    OrderYear smallint NOT NULL                        -- New partitioning column
        CONSTRAINT CK_Orders_Current 
            CHECK (OrderYear >= 2019 AND OrderYear < 2020), -- Check constraint to create disjoint sets
    OrderDate date NOT NULL,                                
    OrderRequestedDate date NOT NULL,
    OrderDeliveryDate datetime2(0) NULL,
    CustID int NOT NULL
        CONSTRAINT FK_Orders_CustID_Customers_CustID 
            FOREIGN KEY REFERENCES Orders.Customers (CustID),
    OrderIsExpedited bit NOT NULL
        CONSTRAINT DF_Orders_OrderIsExpedited_False DEFAULT (0),
    CONSTRAINT CK_Orders_RequestedDate_GE_OrderDate
        CHECK (OrderRequestedDate >= OrderDate),
    CONSTRAINT CK_Orders_DeliveryDate_GE_OrderDate
        CHECK (OrderDeliveryDate >= OrderDate),
    CONSTRAINT PK_Orders_OrderYear_OrderID 
        PRIMARY KEY (OrderYear, OrderID)                    -- New Primary Key
);

-- Order items table
DROP TABLE IF EXISTS Orders.OrderItems
CREATE TABLE Orders.OrderItems (
    OrderItemID int IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_OrderItems_OrderItemID PRIMARY KEY,
    OrderID int NOT NULL,
    OrderYear smallint NOT NULL,                        -- New column for Foreign Key
    StockID int NOT NULL
        CONSTRAINT FK_OrderItems_StockID_Stock_StockID
            FOREIGN KEY REFERENCES Orders.Stock (StockID),
    Quantity smallint NOT NULL
        CONSTRAINT DF_OrderItems_Quantity_1 DEFAULT (1)
        CONSTRAINT CK_OrderItems_Quantity_GT_zero
            CHECK (Quantity > 0),
    Discount numeric(4, 2) NOT NULL
        CONSTRAINT CK_OrderItems_Discount_GE_zero
            CHECK (Discount >= 0.0),
    CONSTRAINT FK_OrderItems_OrderYear_OrderId_Orders   -- New Foreign Key constraint
        FOREIGN KEY (OrderYear, OrderId)
        REFERENCES Orders.Orders (OrderYear, OrderId)
);

-- Orders for the year 2018
CREATE TABLE Orders.Orders2018 (  
    OrderID int IDENTITY(1,1) NOT NULL,
    OrderYear smallint NOT NULL
        CONSTRAINT CK_Orders2018_Current 
            CHECK (OrderYear >= 2018 AND OrderYear < 2019),     -- Check constraint to create disjoint sets    
    OrderDate date NOT NULL,
    OrderRequestedDate date NOT NULL,
    OrderDeliveryDate datetime2(0) NULL,
    CustID int NOT NULL
        CONSTRAINT FK_Orders2018_CustID_Customers_CustID 
            FOREIGN KEY REFERENCES Orders.Customers (CustID),
    OrderIsExpedited bit NOT NULL
        CONSTRAINT DF_Orders2018_OrderIsExpedited_False DEFAULT (0),
    CONSTRAINT CK_Orders2018_RequestedDate_GE_OrderDate
        CHECK (OrderRequestedDate >= OrderDate),
    CONSTRAINT CK_Orders2018_DeliveryDate_GE_OrderDate
        CHECK (OrderDeliveryDate >= OrderDate),
    CONSTRAINT PK_Orders2018_OrderYear_OrderID PRIMARY KEY (OrderYear, OrderID)
);
RETURN;
GO

-- Create partitioned view
CREATE VIEW Orders.PartitionedOrders
WITH SCHEMABINDING
AS
    SELECT OrderID, OrderYear, OrderDate, OrderRequestedDate, OrderDeliveryDate, CustID, OrderIsExpedited
    FROM Orders.Orders
    UNION ALL
    SELECT OrderID, OrderYear, OrderDate, OrderRequestedDate, OrderDeliveryDate, CustID, OrderIsExpedited
    FROM Orders.Orders2018
GO
```

Table and View Partition Caveats
You can't partition a table across servers the same way you can with views. Also, maintenance of partitioned tables is really no simpler than that for partitioned views, though the two are quite different.
But what about updating partitioned views? You can update partitioned views with INSERT, UPDATE, and DELETE statements, but several conditions apply. An INSERT statement must supply values for all the columns in the view even if the underlying tables have columns with defaults specified. If you are inserting or updating data, you cannot use the default keyword for a column value, even if the column has a default value defined in the corresponding member table. It may seem redundant to say this, but any values supplied for the partitioning column must satisfy one of the constraints. And since the constraints need to identify disjoint sets, such a value cannot satisfy more than one constraint. When updating a partitioned view, you cannot update an identity or a timestamp column. There are a few other minor conditions that you may actually never encounter involving triggers and bulk inserts. See the official documentation for all the detail.

Partitioned views can be distributed among several servers, quite a powerful concept. 

</details>

<details><summary>

###### Credit(s)/Example(s)/Other(s)/Reference(s)/Source(s)</summary>  

Paper: A relational model of data for large shared data bansk (Codd, Edgar Frank)

Done Between 2024-02-03 and 2024-07-28
</details>
