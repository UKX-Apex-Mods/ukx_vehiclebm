// JavaScript to handle page navigation
function showPage(pageId) {
    // Hide all pages
    const pages = document.querySelectorAll('div');
    pages.forEach(page => page.style.display = 'none');
    // Show the selected page
    document.getElementById(pageId).style.display = 'block';

    // Initialize the chart on the info page
    if (pageId === 'infoPage') {
        initializeChart();
    }
}

// Function to initialize the chart
function initializeChart() {
    const ctx = document.getElementById('statsChart').getContext('2d');
    new Chart(ctx, {
        type: 'line',
        data: {
            labels: ['Speed', 'Acceleration', 'Braking', 'Handling', 'Overall'],
            datasets: [{
                label: 'Vehicle Statistics',
                data: [89.07, 56.00, 30.67, 100.00, 68.93], // This data is hardcoded for now, but will be taken from the database in the future
                borderColor: '#00FF00',
                backgroundColor: 'rgba(0, 255, 0, 0.1)',
                pointBackgroundColor: '#B9FF66',
                pointBorderColor: '#FFFFFF',
                pointHoverBackgroundColor: '#FFFFFF',
                pointHoverBorderColor: '#00FF00',
                borderWidth: 2,
                tension: 0.3,
            }]
        },
        options: {
            plugins: {
                legend: {
                    labels: {
                        color: '#B9FF66'
                    }
                }
            },
            scales: {
                x: {
                    ticks: {
                        color: '#B9FF66'
                    },
                    grid: {
                        color: '#00FF00'
                    }
                },
                y: {
                    ticks: {
                        color: '#B9FF66'
                    },
                    grid: {
                        color: '#00FF00'
                    }
                }
            }
        }
    });
}

// Function to load vehicle categories
function loadCategories(categories) {
    const categoryContainer = document.getElementById('categories');
    categoryContainer.innerHTML = '';
    categories.forEach(category => {
        const button = document.createElement('button');
        button.textContent = category;
        button.onclick = () => loadVehicles(category);
        categoryContainer.appendChild(button);
    });
}

// Function to load vehicles for a specific category
function loadVehicles(category) {
    // Fetch vehicles from the server
    fetch(`https://yourresource/getVehicles?category=${category}`)
        .then(response => response.json())
        .then(data => {
            const vehicleContainer = document.getElementById('vehicles');
            vehicleContainer.innerHTML = '';
            data.vehicles.forEach(vehicle => {
                const button = document.createElement('button');
                button.textContent = vehicle.name;
                button.onclick = () => showVehicleInfo(vehicle);
                vehicleContainer.appendChild(button);
            });
            document.getElementById('categoryTitle').textContent = `Buy ${category}`;
            showPage('categoryPage');
        });
}

// Function to show vehicle info
function showVehicleInfo(vehicle) {
    document.getElementById('vehicleBrand').textContent = vehicle.brand;
    document.getElementById('vehicleName').textContent = vehicle.name;
    document.getElementById('vehicleType').textContent = vehicle.type;
    document.getElementById('vehiclePrice').textContent = `$${vehicle.price}`;
    showPage('infoPage');
}

// Function to test drive a vehicle
function testDriveVehicle() {
    const vehicleName = document.getElementById('vehicleName').textContent;
    fetch(`https://yourresource/testDrive`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ vehicle: vehicleName })
    });
}

// Function to buy a vehicle
function buyVehicle() {
    const vehicleName = document.getElementById('vehicleName').textContent;
    fetch(`https://yourresource/buyVehicle`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({ vehicle: vehicleName })
    });
}
