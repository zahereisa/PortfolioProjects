/*

Cleaning Data in SQL Queries

*/

Select SaleDateConverted, convert(Date,SaleDate)
	From PortfolioProject..NashvilleHousing$

Update NashvilleHousing$
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing$
Add SaleDateConverted Date;

Update NashvilleHousing$
Set SaleDateConverted = Convert(Date,SaleDate)

--Populate Property Address data

Select *
	From PortfolioProject..NashvilleHousing$
	--where propertyaddress is null
	order by ParcelID

--We self join table to itself. IF common ParcelID shared then we can use that address to populate PropertyAddress where its null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --If its null we want to populate
	From PortfolioProject..NashvilleHousing$ a
	Join PortfolioProject..NashvilleHousing$ b
		on a.ParcelID=b.ParcelID
		And a.[UniqueID ]<>b.[UniqueID ] 
		Where a.PropertyAddress is null --UniqueID not equal. its not the same row

--Write our update for new column populated. it removes nulls in update

Update a
	Set PropertyAddress= ISNULL(a.PropertyAddress, b.PropertyAddress)
		From PortfolioProject..NashvilleHousing$ a
	Join PortfolioProject..NashvilleHousing$ b
		on a.ParcelID=b.ParcelID
		And a.[UniqueID ]<>b.[UniqueID ] 
	where a.PropertyAddress is null

--Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
	From PortfolioProject..NashvilleHousing$
	--where propertyaddress is null
	--order by ParcelID

--USe substring to separate by comma
Select --look at position 1, search for value charindex('tom') then where we are looking "PropertyAddress" we can put -1 to remove comma
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address --starts after comma instead of position 1

From portfolioproject..NashvilleHousing$

Alter Table PortfolioProject..NashvilleHousing$
Add PropertySplitAddress Nvarchar (255);

Update PortfolioProject..NashvilleHousing$
Set PropertySplitAddress =Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

Alter Table PortfolioProject..NashvilleHousing$
add PropertySplitCity Nvarchar (255);

Update PortfolioProject..NashvilleHousing$
Set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 

--Check our newly created columns 
Select * 
From PortfolioProject..NashvilleHousing$

--looking at Owner Address to separate city and state

Select OwnerAddress	
	from PortfolioProject..NashvilleHousing$


Select OwnerAddress	
	from PortfolioProject..NashvilleHousing$
Select
PARSENAME(Replace(OwnerAddress,',','.'),3) --separates everything for us
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)
	From PortfolioProject..NashvilleHousing$

Alter Table PortfolioProject..NashvilleHousing$
Add OwnerSplitAddress Nvarchar (255);

Update PortfolioProject..NashvilleHousing$
Set OwnerSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'),3)

Alter Table PortfolioProject..NashvilleHousing$
add OwnerSplitCity Nvarchar (255);

Update PortfolioProject..NashvilleHousing$
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table PortfolioProject..NashvilleHousing$
Add OwnerSplitState Nvarchar (255);

Update PortfolioProject..NashvilleHousing$
Set OwnerSplitState =PARSENAME(Replace(OwnerAddress,',','.'),1)

--Looking at our newly created columns
select *
	from PortfolioProject..NashvilleHousing$

--Change Y and N to Yes and No in "Sold as Vacant" column

Select Distinct (SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing$
Group by SoldAsVacant
order by 2  --We have 52 Y, 399 N, 4623 Yes and 51403 No

Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End
From PortfolioProject..NashvilleHousing$


Update PortfolioProject..NashvilleHousing$
Set SoldASVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		End

--Remove Duplicates
Select * , 
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
	from PortfolioProject..NashvilleHousing$
	Order by ParcelID


---Include CTE
With RowNumCTE As(
Select * , 
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID) row_num
	from PortfolioProject..NashvilleHousing$
	--Order by ParcelID
	)
--Select * 
	--Delete 
	Select *
	From RowNumCTE
	where row_num>1

	order by PropertyAddress
--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing$

Alter Table portfolioProject..NashvilleHousing$
Drop Column OwnerAddress,TaxDistrict, PropertyAddress

Alter Table portfolioProject..NashvilleHousing$
Drop Column SaleDate