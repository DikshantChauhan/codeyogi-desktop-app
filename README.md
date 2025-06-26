# desktop_app

// Prerequireties
1. Download the "vs code 2022" for preview desktop app (make sure to include c++ workload while installing) (only required to compile windows component, you can continue developing on cursor)

2. flutter config --enable-windows-desktop

3. flutter run -d windows


# TO GENERATE THE CONTENT

1. cd data_transformer

2. npm i

3. copy the data.pathway data folder with the folder name as "data" (this folder must contain pathway.ts, steps, _assignments)

4. npm run generate-data

5. The above commant will generate the "_data" folder, paste that folder as "codeyogi-desktop-app/assets/_data"