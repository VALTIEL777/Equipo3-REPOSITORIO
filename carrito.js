function addToCart(productName, price) {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    cart.push({ productName, price });
    localStorage.setItem('cart', JSON.stringify(cart));
    alert(`${productName} ha sido agregado al carrito.`);
    updateCartDisplay(); // Actualizar visualización del carrito
}

function loadCart() {
    let cart = JSON.parse(localStorage.getItem('cart')) || [];
    const cartElement = document.getElementById('cart');
    const totalElement = document.getElementById('total');
    let total = 0;

    cartElement.innerHTML = '';
    cart.forEach(item => {
        const li = document.createElement('li');
        li.textContent = `${item.productName} - $${item.price}`;
        cartElement.appendChild(li);
        total += item.price;
    });

    totalElement.textContent = total.toFixed(2);
}

function updateCartDisplay() {
    loadCart();
}

function comprar(){
    alert("Compra Realizada\n Gracias por comprar en Abarrotes La Tiendita ;)");
}

function enviar(){
    alert("Gracias por sus comentarios!!\n Los tomaremos en cuenta");
}
