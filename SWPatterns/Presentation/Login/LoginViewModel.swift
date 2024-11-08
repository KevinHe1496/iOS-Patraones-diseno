import Foundation

// Definimos los posibles estados del login.
enum LoginState {
    case success // Estado que indica que el login fue exitoso.
    case error(reason: String) // Estado cuando ocurre un error, con una razón específica.
    case loading // Estado mientras el login está en proceso (cargando).
}

// ViewModel que maneja la lógica del login.
final class LoginViewModel {
    // `onStateChanged` es una propiedad que usa una clase `Binding` para notificar cambios de estado.
    // Se utiliza para enlazar cambios en el estado del login con la interfaz de usuario.
    let onStateChanged = Binding<LoginState>()
    
    // `useCase` es una referencia al contrato que define la lógica de negocio para ejecutar el login.
    // Aquí se sigue el principio de inyección de dependencias, permitiendo que el caso de uso se pase desde fuera.
    private let useCase: LoginUseCaseContract
    
    // Inicializador del ViewModel. Recibe un `useCase` que sigue el protocolo `LoginUseCaseContract`,
    // el cual contiene la lógica para ejecutar el login.
    init(useCase: LoginUseCaseContract) {
        self.useCase = useCase
    }
    
    // Función `signIn` que realiza el proceso de login.
    // Recibe dos parámetros opcionales: el nombre de usuario (`username`) y la contraseña (`password`).
    func signIn(_ username: String?, _ password: String?) {
        guard let username else {
            return onStateChanged.update(newValue: .error(reason: "Invalid Username"))
        }
        
        guard let password else {
            return onStateChanged.update(newValue: .error(reason: "Invalid Password"))
        }
        // Actualizamos el estado a 'loading' para notificar a la interfaz de que el proceso de login ha comenzado.
        onStateChanged.update(newValue: .loading)
        
        // Creamos un objeto `Credentials` con los datos proporcionados. Si `username` o `password` son nulos,
        // se reemplazan por una cadena vacía.
        let credentials = Credentials(username: username, password: password)
        
        // Ejecutamos el caso de uso con las credenciales. Esto realiza la llamada de login (generalmente asincrónica).
        useCase.execute(credentials: credentials) { [weak self] result in
            // Usamos un bloque `do-catch` para manejar el resultado del login.
            // El método `result.get()` devuelve el valor en caso de éxito, o lanza un error en caso de fallo.
            do {
                try result.get() // Si este llamado no lanza un error, significa que el login fue exitoso.
                
                // Si el login fue exitoso, esperamos 3 segundos antes de notificar a la interfaz
                DispatchQueue.global().asyncAfter(deadline: .now() + 3) { [weak self] in
                    // Actualizamos el estado a `success` después del retraso.
                    self?.onStateChanged.update(newValue: .success)
                }
               
            } catch let error as LoginUseCaseError {
                // Si ocurre un error específico del caso de uso (por ejemplo, credenciales incorrectas),
                // capturamos el error y actualizamos el estado a `error`, pasando la razón del fallo.
                self?.onStateChanged.update(newValue: .error(reason: error.reason))
            } catch {
                // Si ocurre cualquier otro tipo de error, actualizamos el estado con un mensaje genérico.
                self?.onStateChanged.update(newValue: .error(reason: "Something has happened"))
            }
        }
    }
}
