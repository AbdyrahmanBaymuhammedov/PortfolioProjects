-- Cleaning data with queries
SELECT *
FROM NashvilleHousing


-- Standardize date format
SELECT SaledateConverted, CONVERT(DATE, Saledate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(DATE, Saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE, Saledate)


-- Populate property address data
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress,
ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.parcelid = n2.parcelid
	AND n1.uniqueid <> n2.uniqueid
WHERE n1.PropertyAddress IS NULL

UPDATE n1
SET PropertyAddress = ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousing n1
JOIN NashvilleHousing n2
	ON n1.parcelid = n2.parcelid
	AND n1.uniqueid <> n2.uniqueid
WHERE n1.PropertyAddress IS NULL


-- Breaking out Address into individual columns (address, city, state)
SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1)) AS Address,
SUBSTRING(PropertyAddress, ((CHARINDEX(',', PropertyAddress)+1)), LEN(PropertyAddress) ) AS City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress varchar(255)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity varchar(255)


UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, (CHARINDEX(',', PropertyAddress)-1))


UPDATE NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, ((CHARINDEX(',', PropertyAddress)+1)), LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


SELECT OwnerAddress
FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress varchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity varchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState varchar(255)

UPDATE NashvilleHousing 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold as vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
	END


-- Remove duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER 
	(PARTITION BY	ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID) AS row_num
FROM NashvilleHousing
--ORDER BY ParcelID
)
--DELETE
--FROM RowNumCTE
--WHERE row_num >1
SELECT *
FROM RowNumCTE
WHERE row_num >1


-- Deleting Unused Columns
SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN Saledate