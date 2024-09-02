/**
 * @property {string} id
 * @property {string} name
 * @property {string} startDate
 * @property {string} endDate
 * @property {string} location
 * @property {string} description
 */
class CalendarEvent {
    constructor(eventData) {
        this.id = eventData.uid;
        this.name = eventData.summary;
        this.startDate = eventData.start;
        this.endDate = eventData.end
        this.location = eventData.location;
        if (eventData['ALT-DESC'] != null) {
            this.description = eventData['ALT-DESC'].val.replace(/<(?:.|\n)*?>/g, '');
        } else {
            this.description = null;
        }
    }
}

module.exports = {
    CalendarEvent: CalendarEvent
};