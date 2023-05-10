from ovmsclient import make_grpc_client

MODEL_URL = "20.82.217.204:80"
MODEL_NAME = "inception-resnet"

class TestCallingModel:
    """Class for defining acceptance tests of being able to call model being deployed on infrastructure defined."""

    def test_ok_response_returned_from_deployed_model(self):
        """Should get OK response for valid request to model."""

        # Arrange
        sut = make_grpc_client(MODEL_URL)

        with open("tests/acceptance/data/dog.jpeg", "rb") as f:
            test_data = f.read()

        payload = {"input": test_data}

        with open("tests/acceptance/data/labels.txt") as f:
            labels = f.readlines()
        
        expected_image_label = "Saint Bernard"


        # Act
        actual_response = sut.predict(inputs=payload, model_name=MODEL_NAME)
        actual_predicted_image_label = labels[actual_response[0].argmax()].strip().replace("\n", "")


        # Assert
        assert expected_image_label == actual_predicted_image_label