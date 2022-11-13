#import <UIKit/UIKit.h>

@protocol WFCloudKitItem
@end

@protocol WFLoggableObject
@end

@protocol WFNaming
@end

@interface WFRecord : NSObject <NSCopying>
@end

@interface WFWorkflowRecord : WFRecord <WFNaming>
@property (copy, nonatomic) NSArray *actions; // ivar: _actions
@property (copy, nonatomic) NSString *minimumClientVersion; // ivar: _minimumClientVersion
@end

@interface WFSharedShortcut : NSObject <WFCloudKitItem, WFLoggableObject>
@property (retain, nonatomic) WFWorkflowRecord *workflowRecord; // ivar: _workflowRecord
-(id)workflowRecord;
@end

%hook WFSharedShortcut
-(id)workflowRecord {
    id rettype = %orig;
    NSArray *origShortcutActions = (NSArray *)[rettype actions];
    NSMutableArray *newMutableShortcutActions = [origShortcutActions mutableCopy];
    NSMutableDictionary *conditionalList = [[NSMutableDictionary alloc]init];
    int shortcutActionsObjectIndex = 0;
    
    for (id shortcutActionsObject in origShortcutActions) {
        if ([shortcutActionsObject isKindOfClass:[NSDictionary class]]){
            if ([shortcutActionsObject objectForKey:@"WFWorkflowActionIdentifier"]) {
            if ([[shortcutActionsObject valueForKey:@"WFWorkflowActionIdentifier"] isEqual:@"is.workflow.actions.conditional"]) {
            if ([shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]) {
                if ([[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]) {
                if ([conditionalList objectForKey:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]]) {
                    //GroupingIdentifier in conditionalList already
                    //check the WFControlFlowMode, if @"2" after endif so remove conditional, @"1" needs WFControlFlowMode to be 2, if @"0" needs WFControlFlowMode to be 1 or 2
                    if ([[conditionalList objectForKey:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]]integerValue] == 0) {
                        if (([[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"WFControlFlowMode"]integerValue] == 1) || ([[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"WFControlFlowMode"]integerValue] == 2)) {
                            [conditionalList setObject:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"WFControlFlowMode"] forKey:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]];
                        } else {
                            [newMutableShortcutActions removeObjectAtIndex:shortcutActionsObjectIndex];
                            shortcutActionsObjectIndex--;
                        }
                    } else if ([[conditionalList objectForKey:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]]integerValue] == 1) {
                        if ([[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"WFControlFlowMode"]integerValue] == 2) {
                            [conditionalList setObject:@"2" forKey:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]];
                        } else {
                            [newMutableShortcutActions removeObjectAtIndex:shortcutActionsObjectIndex];
                            shortcutActionsObjectIndex--;
                        }
                    } else {
                        //if @"2" or anything else remove
                        [newMutableShortcutActions removeObjectAtIndex:shortcutActionsObjectIndex];
                        shortcutActionsObjectIndex--;
                    }
                } else {
                    //check WFControlFlowMode and add if's GroupingIdentifier if no exist
                    if ([[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"WFControlFlowMode"]integerValue] == 0) {
                        [conditionalList setObject:@"0" forKey:[[shortcutActionsObject objectForKey:@"WFWorkflowActionParameters"]objectForKey:@"GroupingIdentifier"]];
                    } else {
                        //strip conditional action from shortcut if bad WFControlFlowMode
                        [newMutableShortcutActions removeObjectAtIndex:shortcutActionsObjectIndex];
                        shortcutActionsObjectIndex--;
                    }
                }
                }
            }
            
            }
            }
        }
        shortcutActionsObjectIndex++;
    }
    
    shortcutActionsObjectIndex = 0;

    [rettype setActions:newMutableShortcutActions];
    return rettype;
}
%end
