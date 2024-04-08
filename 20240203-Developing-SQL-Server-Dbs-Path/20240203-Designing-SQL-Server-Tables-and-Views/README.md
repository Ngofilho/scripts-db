
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

###### Credit(s)/Other(s)/Reference(s)/Source(s)</summary>  

Paper: A relational model of data for large shared data bansk (Codd, Edgar Frank)

</details>