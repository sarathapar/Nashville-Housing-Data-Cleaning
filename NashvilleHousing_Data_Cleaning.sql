-- Data Cleaning 

--Add a new column for new SaleDate with a proper date format

Select * 
from [Portfolio Project].dbo.NashvilleHousing

Select SaleDateConverted, CONVERT(Date,SaleDate)
from [Portfolio Project].dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--Property Address Cleaning

Select *
from [Portfolio Project].dbo.NashvilleHousing
Where PropertyAddress is Null
Order by ParcelID;

Select A.ParcelID,A.PropertyAddress,B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing A
JOIN [Portfolio Project].dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From [Portfolio Project].dbo.NashvilleHousing A
JOIN [Portfolio Project].dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null;

--Splitting Property Address

Select *
from [Portfolio Project].dbo.NashvilleHousing

SELECT 
SUBSTRING (PropertyAddress, 1,CHARINDEX(',', PropertyAddress)) as Address
FROM [Portfolio Project].dbo.NashvilleHousing;

SELECT
SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM [Portfolio Project].dbo.NashvilleHousing;

--Add column AddressStreetConverted

ALTER TABLE NashvilleHousing
ADD AddressStreetConverted Nvarchar(255);

--Update Street Address

UPDATE NashvilleHousing
SET AddressStreetConverted = SUBSTRING (PropertyAddress, 1,CHARINDEX(',',PropertyAddress) -1);

ALTER TABLE NashvilleHousing
ADD AddressCityConverted Nvarchar(255);

UPDATE NashvilleHousing
SET AddressCityConverted = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));

--Splitting Owner Address

Select *
from [Portfolio Project].dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio Project].dbo.NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerAddressStreetConverted Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerAddressCityConverted Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD OwnerAddressStateConverted Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressStreetConverted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE NashvilleHousing
SET OwnerAddressCityConverted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE NashvilleHousing
SET OwnerAddressStateConverted = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


--Change Sold As Vacant Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio Project].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Portfolio Project].dbo.NashvilleHousing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
							When SoldAsVacant = 'N' THEN 'No'
							ELSE SoldAsVacant
							END

--Remove Duplicates

WITH RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SaleDate,
				SalePrice,LegalReference
				ORDER BY
					UniqueID
					) row_num
From [Portfolio Project].dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num >1
--Order by PropertyAddress;

--Delete unused columns

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate


--Change column names for Property Street and Porperty City columns as old names did not indicate that it was Property Address.

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
  ADD PropertyStreetAddressSplit Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyStreetAddressSplit = AddressStreetConverted

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
  ADD PropertyCityAddressSplit Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityAddressSplit = AddressCityConverted

--Delete Address Street and Address City columns

ALTER TABLE [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN AddressStreetConverted, AddressCityConverted