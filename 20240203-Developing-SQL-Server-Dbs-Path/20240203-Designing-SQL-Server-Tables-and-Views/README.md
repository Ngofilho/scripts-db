
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

### Constraints
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

=====Organizar daqui pra baixo
Demo 4 - Using CHECK Constraints
Here I've put a few CHECK constraints on our tables, starting with the Salutations table. A salutation is useless if it is blank. So I've got a CHECK constraint to prevent that. Note the name I used. It explicitly states the rule being checked. Now let me try to violate it. See the error message. It includes the name of the constraint being violated. Now let me do that again using a system-generated name. Just how useful is that error message? You'd have to dig in to the table definition to find out what's really wrong. Now let me try a table constraint. Bob just told me that the stock item description must be different from the SKU. Here's one way I could do that. I need to use a table constraint since two columns are involved. And if I try to violate that constraint, SQL Server stops me. Next, let's pretend that Bob is really picky about his customers. He only accepts customers from the US, the UK, and Canada. To control that, I can use this CHECK constraint, which tests membership using an IN clause. For the last example, I'll pretend that in order to validate an order, I have to do some fancy date checks. To do that, I've created a scalar function that returns a 1 or a 0 to represent true or false. In this case, true means the dates pass the test. My new CHECK constraint calls the function and checks the result. Let me try to violate it. Foiled again. So CHECK constraints work with functions too. A scalar function can do a lot, including querying other tables. A word or two of caution is in order though. The first caution is about performance. If a scalar function used in a CHECK constraint uses queries that involve large tables or complex joins, don't be surprised if the time to insert or update a row increases. That doesn't mean don't use functions or functions with long queries. After all, if you did the same work in your application logic, it could run just as long. The second caution is this. If you use a function in a CHECK constraint, and you later change the function so that it returns different results, SQL Server will not automatically reject the constraint. You need to do that manually. There's an ALTER TABLE command for that that tells SQL Server to explicitly CHECK a constraint. Here's an example. The challenge may be that you have a helper function used in CHECK constraints in many table definitions. If that helper function changes, you'll need to find all the places it is referenced to recheck the constraints and verify that the change to the function does not break anything. Now there are lots of opportunities to add CHECK constraints to the tables in Bob's Shoes order system. This would be a great time to pause this video and write some of your own. Some things you might want to check. Can the number of items ordered be less than 1? Can a delivery date precede the OrderDate? Can you write a CHECK constraint to verify shoe sizes for the Stock table. Or how about a constraint to verify country names using current world ISO standards? And can a price or discount be negative? Well, give those a shot, and I'll see you later.

Options for Defining CHECK Constraints
To complete this look at constraints, let's review the major statements you will need. You can add constraints when you create a table. They can be specified at either the column level or the table level. Remember to use a table constraint if two or more columns are involved. You can have multiple constraints per column or table in either location. The only exceptions are FOREIGN KEY constraints, which cannot be used with temporary tables or table variables. You can add new constraints at any time using the ALTER TABLE ADD CONSTRAINT command. Both column and table constraints can be added this way. By default, SQL Server will check the table against the newly added constraint. The optional parameter with no check will add the constraint without checking the table. The default is to check that there are no constraint violations and issue an error message if any are found. If you no longer need a constraint, you can remove it using the ALTER TABLE DROP CONSTRAINT command. You also need this to change a constraint since there is no ALTER CONSTRAINT command. Changing constraints always means dropping and re-creating them. By the way, if you drop a key constraint backed by a clustered index, the table becomes a heap. If you need to temporarily disable a constraint, use the ALTER TABLE NOCHECK CONSTRAINT. You might do this, for example, when bulk inserting data known to be good, and the constraint slows down the INSERT operation enough to be a problem. Note that you can only disable FOREIGN KEY and CHECK constraints, not other constraint types. You can re-enable or disable a constraint with the ALTER TABLE CHECK CONSTRAINT command. If you want to also reject the constraint, add the WITH CHECK option to the command. For example, you might use WITH CHECK after modifying a function used in a check constraint or to verify FOREIGN KEY constraints. The ALTER commands all need a constraint name, but you can also use the keyword ALL to perform the action to all constraints at once.

Summary
In this module, we look at the six types of constraints available out of the box in SQL Server. I first reviewed the NULL and NOT NULL constraints, when to use them, and a little about the controversies regarding THEM. I typically use the NULL constraint only on columns where the data may not be available until a later time and no suitable default exists. The DEFAULT constraint is perfect for nullable columns where there is a suitable default. Note that all tables should have a PRIMARY KEY constraint. Otherwise, your database is not in third normal form, considered the baseline for good database design. I also showed you the UNIQUE constraint and how that can be used to ensure uniqueness on a business key if the primary key is a surrogate key. But, of course, there are many other uses. The section on FOREIGN KEY constraints showed different methods to handle FOREIGN KEY references when corresponding parent rows are deleted or updated. Cascade and update are perhaps the most used options. Finally, I showed you the CHECK constraint and how you can use it to enhance data integrity while reducing application code. Well, for this course, we finished with table definitions. However, I have not covered all table types and options. In fact, some of them deserve courses on their own. What I have covered, however, is enough for the bulk of what a typical database developer will need for table and database design. In the next module, I'm going to start talking about a related topic, Views, which are projections of existing tables. See you there!

Designing View to Meet Business Requirements
Introducing Views
</details>

<details><summary>

###### Credit(s)/Other(s)/Reference(s)/Source(s)</summary>  

Paper: A relational model of data for large shared data bansk (Codd, Edgar Frank)

</details>
