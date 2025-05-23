import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { JwtPayload } from '../types/jwt-payload.type';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET || 'super-secret-key',
    });
  }

  validate(payload: JwtPayload) {
    console.log('JWT payload:', payload);
    const user = {
      id: payload.sub,
      email: payload.email,
      isAdmin: payload.isAdmin,
    };
    console.log('JWT strategy returning user:', user);
    return user;
  }
}
