// --- Fungsi Generator Angka Random ---
function Rnum(length) {
    let result = '';
    const numbers = '0123456789';
    for (let i = 0; i < length; i++) {
        result += numbers.charAt(Math.floor(Math.random() * numbers.length));
    }
    return result;
}

// --- Fungsi Generator String Random (Opsional/Bawaan) ---
function Rstr(length) {
    let result = '';
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    const charactersLength = characters.length;
    let counter = 0;
    while (counter < length) {
      result += characters.charAt(Math.floor(Math.random() * charactersLength));
      counter += 1;
    }
    return result;
}

function Rand(min, max) { return Math.floor(Math.random() * (max - min) ) + min; }

// --- Fungsi untuk Trigger Event React/DOM ---
function set(obj, callback) {
    if (!obj) return; // Guard jika elemen tidak ditemukan
    callback(obj);
 
    for (let [k, v] of Object.entries(obj)) {
        if (k.includes('reactProps') && v.onChange) {
            v.onChange({target: obj});
        }
    }
}

// --- Fungsi Utama Signup ---
function signup() {
    // Format Username: PAWxTLN + 2 angka random (Contoh: PAWxTLN42)
    let user = "PAWxTLN" + Rnum(2); 
    let pass = "Login666@";
    
    let userElem = document.getElementById('signup-username');
    let passElem = document.getElementById('signup-password');
    let sb = document.getElementById('signup-button');

    if (userElem && passElem) {
        set(userElem, obj => obj.value = user);
        set(passElem, obj => obj.value = pass);
    }
 
    if (sb) {
        if (sb.disabled) {
            console.log("Tombol masih disabled, mencoba lagi...");
            return setTimeout(signup, 1500);
        }
        sb.click();
    }
}

// --- Inisialisasi Data Dropdown (Tanggal Lahir) ---
set(document.getElementById('MonthDropdown'), obj => obj.options[Rand(1, 12)].selected = true);
set(document.getElementById('DayDropdown'), obj => obj.options[Rand(1, 28)].selected = true);
set(document.getElementById('YearDropdown'), obj => obj.options[Rand(19, 25)].selected = true);

// --- Pemilihan Gender ---
let gndr = document.getElementById(Math.random() > 0.5 ? 'MaleButton' : 'FemaleButton');
if (gndr && gndr.firstChild && !gndr.firstChild.classList.contains('gender-selected')) { 
    gndr.click(); 
}

// --- Jalankan Proses Signup ---
setTimeout(signup, 100);
