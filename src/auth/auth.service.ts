import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { compare, hash } from 'bcrypt';
import { UsersService } from 'src/users/users.service';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async register(email: string, password: string) {
    const hashed = await hash(password, 10);
    return this.usersService.createUser(email, hashed);
  }

  async login(email: string, password: string) {
    const user = await this.usersService.findByEmail(email);
    if (!user || !(await compare(password, user?.password))) {
      throw new UnauthorizedException('Invalid Credentials');
    }

    const payload = { sub: user.id, email: user.email, isAdmin: user.isAdmin };
    console.log('Login - User from DB:', user);
    console.log('Login - JWT Payload being created:', payload);
    const token = this.jwtService.sign(payload);
    console.log('Login - Decoded token:', this.jwtService.decode(token));

    return { acces_token: token };
  }
}
