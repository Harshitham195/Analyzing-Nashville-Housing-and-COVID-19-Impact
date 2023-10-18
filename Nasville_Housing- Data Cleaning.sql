/* Cleaning Data in SQL Queries */
SELECT 
    *
FROM
    nashville_housing;

-- Standardize date fromat
SELECT 
    SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y')
FROM
    nashville_housing;


-- adding null to blank fields
UPDATE nashville_housing 
SET 
    PropertyAddress = NULL
WHERE
    LENGTH(PropertyAddress) = 0;

-- Populate property address data
UPDATE nashville_housing a
        JOIN
    nashville_housing b ON a.ParcelID = b.ParcelID
        AND a.UniqueID <> b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;

SELECT 
    *
FROM
    nashville_housing
WHERE
    PropertyAddress IS NULL;

-- Breaking out Address into individual columns (Address,City,State)
SELECT 
    PropertyAddress,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 1),
                ' ',
                4)) AS Address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 1),
                ' ',
                - 1)) AS City,
    TRIM(SUBSTRING_INDEX(PropertyAddress, ',', - 1)) AS State
FROM
    nashville_housing;

Alter table nashville_housing
add PropertysplitAddress Nvarchar(255);

UPDATE nashville_housing 
SET 
    PropertysplitAddress = TRIM(SUBSTRING_INDEX(PropertyAddress, ',', 1));

Alter table nashville_housing
add Propertysplitcity Nvarchar(255);

UPDATE nashville_housing 
SET 
    Propertysplitcity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(PropertyAddress, ',', 1),
                ' ',
                - 1));
 
SELECT 
    *
FROM
    nashville_housing;

-- Change Y and N to Yes and No in 'SoldAsVacant' 

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    nashville_housing
GROUP BY SoldAsVacant;

UPDATE nashville_housing 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-- remove duplicates

With RownumCTE AS( 
select *, 
Row_Number() over (
Partition By ParcelID,
				PropertyAddress,
                SalePrice,
                SaleDate,
                Legalreference
                order By uniqueID
) row_num
from nashville_housing)
select * from RownumCTE
where row_num > 1
order by PropertyAddress;

--  Delete Unused Columns

Alter table nashville_housing
drop OwnerAddress;

SELECT 
    *
FROM
    nashville_housing;

