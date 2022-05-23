describe('api_test', () => {
    it('GET', () => {
        cy.request('GET', 'https://uirb3uoyjh.execute-api.us-east-1.amazonaws.com/prod/resume_counter').then((response) => {
            expect(response).to.have.property('status', 200)
            expect(response.body).to.not.be.null
            expect(response.body).to.be.a('number')
        })        
    })
})