
# load packages -----------------------------------------------------------


library(tidyverse)
library(ggrepel)


# read data ---------------------------------------------------------------



file_url<-"https://esajournals.onlinelibrary.wiley.com/action/downloadSupplement?doi=10.1002%2Fecy.2647&file=ecy2647-sup-0001-DataS1.zip"
file_name <- basename(file_url)

if (!dir.exists("bird_data")) dir.create("bird_data")

#if (!file.exists(file_name))

download.file(file_url, destfile = "bird_data/bird_data.zip", mode = "wb")
unzip("bird_data/bird_data.zip", overwrite = TRUE, exdir = "bird_data")

#reading and renaming data

bird_data<-read_csv("bird_data/ATLANTIC_BIRD_TRAITS_completed_2018_11_d05.csv")


# clean up data -----------------------------------------------------------


#renaming variables 

bird_data <- rename(bird_data, 
                    body_mass_g = Body_mass.g., 
                    body_length_mm = Body_length.mm., 
                    altitude = Altitude, 
                    wing_length_mm = Wing_length.mm.,
                    order = Order, 
                    family = Family, 
                    genus = Genus, 
                    species = Species
                    )

#new variable

bird_data <- mutate(bird_data, 
                         lm_ratio = body_length_mm / body_mass_g)

#selecting important variables 

bird_data_cut <- select(bird_data, body_mass_g, body_length_mm, altitude,
                        order, family, genus, species, lm_ratio)

# plotting data -------------------------------------------------------------------

#testing for normal distribution of lm_ratio

ggplot(data = bird_data) +
  geom_histogram(mapping = aes(
    x = lm_ratio), 
    bins = 50, 
    boundary = 0) +
  labs(x = "Length Mass Ratio",
       y = "Number of Birds")
ggsave("graphs/fig_1.png", 
       units="in", 
       height=6, 
       width=8, 
       dpi = 300)
 

#ggplot lm_ratio vs altitude

ggplot(data = bird_data) +
  geom_point(mapping = aes(
    y = lm_ratio, 
    x = altitude))+
  labs(y = "Length Mass Ratio",
       x = "Altitude")


#ggplot Length Mass Ratio vs altitude (color) 

ggplot(data = bird_data) +
  geom_point(mapping = aes(
    y = lm_ratio, 
    x = altitude, 
    color = order), 
    alpha = 0.1) +
  labs(y = "Length Mass Ratio",
       x = "Altitude")

#facet wrap graph by order

ggplot(data = bird_data) +
  geom_point(mapping = aes(
    x = lm_ratio, 
    y = altitude))+
  facet_wrap(~order) +
  labs(x = "Length Mass Ratio",
       y = "Altitude")


# manipulating data ----------------------------------------------------------

#log of lm_ratio to correct right skew 

bird_data <- mutate(bird_data, ln_lmr = log(lm_ratio))
bird_data_cut <- mutate(bird_data, ln_lmr = log(lm_ratio))

#testing for normal distribution of ln_ratio

ggplot(data = bird_data) +
  geom_histogram(mapping = aes(
    x = ln_lmr), 
    bins = 100) +
  labs(x = "ln of Length Mass Ratio",
       y = "Number of Birds")

#testing for normal distribution of lm_ratio by order

ggplot(data = bird_data) +
  geom_histogram(mapping = aes(
    x = ln_lmr), bins = 100) + 
  facet_wrap(~order,scales = "free_y") +
  labs(y = "Number of Birds",
       x = "ln of Length Mass Ratio")


# graphing data ---------------------------------------------------

#ln_lmr vs altitude for Passeriformes with regression line

bird_data %>% 
  filter(order=="Passeriformes") %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "loess") +
  labs(y = "ln Length Mass Ratio",
       x = "Altitude")

#fit line with altitude > 1000 Passeriformes by family

bird_data %>% 
  filter(order=="Passeriformes",
         altitude >= 1000) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point(mapping = aes(color = family)) +
  geom_smooth(method = "loess") +
  geom_text_repel(
    mapping = aes(label = family), 
    data = bird_data %>% 
      filter(order=="Passeriformes",
             altitude >= 2000)) +
  labs(y = "ln Length Mass Ratio",
       x = "Altitude")

#fit line of passeriformes: furnariidea altitude >1000 

bird_data %>% 
  filter(
    order=="Passeriformes",
    family=="Furnariidae",
    altitude > 1000
  ) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(y = "ln Length Mass Ratio",
       x = "Altitude")

# frequency distribution of mean ln_lmr in passeriformes

bird_data %>% 
  filter(order == "Passeriformes")%>% 
  group_by(order, family, genus, species) %>% 
  summarize(ln_lmr = mean(ln_lmr),
            altitude = mean(altitude)) %>% 
  ggplot() +
  geom_histogram(aes(x = ln_lmr)) +
  labs(y = "Mean Species Length Mass Ratio",
       x = "ln Length Mass Ratio")

#mean of ln_lmr for species vs altitude

bird_data %>% 
  group_by(order, family, genus, species) %>% 
  summarize(ln_lmr = mean(ln_lmr),
            altitude = mean(altitude)) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point() +
  geom_smooth(method = "lm") +
  labs(y = "Mean ln Length Mass Ratio",
       x = "Altitude")

#mean of ln_lmr vs altitude for genus Turdus

bird_data %>% 
  filter(genus == "Turdus") %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude,
    color = species)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlim(c(0,1700)) +
  labs(y = "ln Length Mass Ratio",
       x = "Altitude")

#mean of ln_lmr vs altitude for genus Turdus: flavipes 

bird_data %>% 
  filter(species == "flavipes") %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude,
    color = species)) +
  geom_point() +
  geom_smooth(method = "lm") +
  xlim(c(0,1700)) +
  labs(y = "ln Length Mass Ratio",
       x = "Altitude")
ggsave("graphs/fig_11.png", 
       units="in", 
       height=6, 
       width=8, 
       dpi = 300)


#mean ln_lmr by species vs altitude genus Turdus

bird_data %>% 
  filter(genus == "Turdus") %>% 
  group_by(species) %>% 
  summarize(ln_lmr = mean(lm_ratio, na.rm=TRUE),
            altitude = mean(altitude, na.rm=TRUE)) %>% 
  ggplot(mapping = aes(
    y = ln_lmr, 
    x = altitude)) +
  geom_point(aes(color = species), size=5) +
  geom_smooth(method = "lm") +
  labs(title = "Genus Turdus",
       y = "Mean Species ln Length Mass Ratio",
       x = "Altitude")

# t-tests -----------------------------------------------------------------

#table of mean_ln_lmr and mean_altitude passeriformes

passeriformes_means<-
  bird_data %>% 
  filter(!is.na(altitude), !is.na(ln_lmr)) %>% 
  group_by(order, family, genus, species) %>% 
  summarize(
    ln_lmr = mean(ln_lmr),
    altitude = mean(altitude)
  ) %>% 
  print()

#filter smaller and larger means

mean_hilo <-
  passeriformes_means %>% 
  mutate(hilo = ifelse(altitude>1000, "Above 1000 m", "Below 1000 m")) %>% 
  group_by(hilo) %>% 
  summarize(
    mean = mean(ln_lmr),
    # sd = sd(ln_lmr, na.rm = TRUE),
    # sem = sd(ln_lmr)/sqrt(n()),
    # upper = ln_lmr + 2*sem,
    # lower = ln_lmr - 2*sem
    )

# mean of passeriformes found over and under 1000 m

passeriformes_means %>% 
  mutate(hilo = ifelse(altitude>1000, "Above 1000 m", "Below 1000 m")) %>%
  ggplot(aes(x = ln_lmr)) +
  geom_histogram() +
  geom_vline(aes(xintercept = mean), data = mean_hilo,
             linetype = "dashed", size = 2, color = "red") +
  facet_wrap(~ hilo, ncol = 1, scales = "free_y") +
  labs( title = "Passeriformes", 
        x = "Mean ln Length Mass Ratio",
        y = "Number of Means")

# t test for passeriformes means

passeriformes_means %>% 
  mutate(hilo = ifelse(altitude>1000, "Above 1000 m", "Below 1000 m")) %>% 
  t.test(ln_lmr ~ hilo, data = .)

# antilog of means --------------------------------------------------------

#antilog of hi
exp(2.067247)

#antilog of low
exp(1.647261)


