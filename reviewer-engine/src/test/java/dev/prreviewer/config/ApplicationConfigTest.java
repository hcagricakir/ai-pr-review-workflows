package dev.prreviewer.config;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class ApplicationConfigTest {

    @Test
    void reviewRuntimeConfigShouldExposeConfigDrivenRuntimeFields() {
        ApplicationConfig.ReviewRuntimeConfig runtimeConfig = new ApplicationConfig.ReviewRuntimeConfig(
                null,
                null,
                null,
                "config/runtime/github-pr-review.yml",
                true,
                null,
                null,
                null,
                null
        );

        assertThat(runtimeConfig.provider()).isEqualTo("mock");
        assertThat(runtimeConfig.outputFormat()).isEqualTo("markdown");
        assertThat(runtimeConfig.extraRulesFile()).isEqualTo("config/runtime/github-pr-review.yml");
        assertThat(runtimeConfig.publishGitHubReviewComments()).isTrue();
    }

    @Test
    void reviewRuntimeConfigShouldDefaultOptionalRuntimeFields() {
        ApplicationConfig.ReviewRuntimeConfig runtimeConfig = ApplicationConfig.ReviewRuntimeConfig.defaults();

        assertThat(runtimeConfig.extraRulesFile()).isNull();
        assertThat(runtimeConfig.publishGitHubReviewComments()).isFalse();
    }
}
