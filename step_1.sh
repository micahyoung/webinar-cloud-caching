#!/bin/bash

cat > src/main/java/com/example/demo/DemoApplication.java <<END
package com.example.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
@EnableCaching
public class DemoApplication {

    @Bean
    CachedBigData bigData() {
        return new CachedBigData();
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }

}
END

cat > src/main/java/com/example/demo/MathController.java <<END
package com.example.demo;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class MathController {

    @Autowired
    IBigData bigData;

    @RequestMapping("/")
    public String get(@RequestParam(value="c", defaultValue="1") int candidate) {
        return candidate + " = " + bigData.isPrime(candidate);
    }
}
END

cat > src/main/java/com/example/demo/CachedBigData.java <<END
package com.example.demo;

import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Component;

@Component
public class CachedBigData implements IBigData {

    @Cacheable(value="isPrime")
    public boolean isPrime(int candidate) {
        for(int i = 2; i < candidate; i++){
            if(candidate % i == 0){
                return false;
            }
        }
        return true;
    }
}
END

cat > src/main/java/com/example/demo/IBigData.java <<END
package com.example.demo;

public interface IBigData {

    boolean isPrime(int candidate);

}
END

read  -n 1 -p "Continue: " mainmenuinput

set -x

mvn clean verify package -DskipTests

cf push cache-demo -p target/demo-0.0.1-SNAPSHOT.jar
