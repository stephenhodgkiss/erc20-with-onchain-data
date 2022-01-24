import { Test, TestingModule } from '@nestjs/testing';
import { HealthCheckService, HttpHealthIndicator } from '@nestjs/terminus';
import { TokensService } from '../tokens/tokens.service';
import { HealthController } from './health.controller';

describe('HealthController', () => {
  let controller: HealthController;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide:HealthCheckService,
          useValue: jest.fn()
        },
        {
          provide: HttpHealthIndicator,
          useValue: jest.fn(),
        },
        {
          provide: TokensService,
          useValue: jest.fn(),
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });
});
