--復活の聖刻印
-- 效果：
-- 对方回合1次，可以从卡组把1只名字带有「圣刻」的怪兽送去墓地。此外，自己回合1次，可以选择从游戏中除外的1只自己的名字带有「圣刻」的怪兽回到墓地。场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「圣刻」的怪兽特殊召唤。
function c53670497.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 对方回合1次，可以从卡组把1只名字带有「圣刻」的怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53670497,0))  --"是否现在使用「复活之圣刻印」的效果？"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53670497.condition1)
	e2:SetTarget(c53670497.target1)
	e2:SetOperation(c53670497.activate1)
	c:RegisterEffect(e2)
	-- 此外，自己回合1次，可以选择从游戏中除外的1只自己的名字带有「圣刻」的怪兽回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53670497,1))  --"送去墓地"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(c53670497.condition2)
	e3:SetTarget(c53670497.target2)
	e3:SetOperation(c53670497.activate2)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「圣刻」的怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53670497,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c53670497.spcon)
	e4:SetTarget(c53670497.sptg)
	e4:SetOperation(c53670497.spop)
	c:RegisterEffect(e4)
end
-- 效果1的发动条件判断：必须是在对方的回合才能发动。
function c53670497.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为效果发动者的对手，即仅在对方回合时条件成立。
	return Duel.IsTurnPlayer(1-tp)
end
-- 定义效果1的筛选条件：字段为「圣刻」的怪兽且可以被送去墓地。
function c53670497.filter1(c)
	return c:IsSetCard(0x69) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 效果1的目标选择函数：发动时检查卡组中是否存在符合条件的「圣刻」怪兽，并设置送去墓地的操作信息。
function c53670497.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果1发动的合法性初检：卡组中存在至少1只满足filter1的「圣刻」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c53670497.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息为『从卡组把1张卡送去墓地』，供后续效果交互检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果1的发动处理函数：从卡组选择1只符合条件的「圣刻」怪兽并送去墓地。
function c53670497.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组选择1张满足filter1的「圣刻」怪兽。
	local g=Duel.SelectMatchingCard(tp,c53670497.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将所选的卡以效果原因送去墓地。
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 效果2的发动条件判断：必须是在自己的回合才能发动。
function c53670497.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为效果发动者自己，即仅在自己回合时条件成立。
	return Duel.IsTurnPlayer(tp)
end
-- 定义效果2的筛选条件：除外区中表侧表示的名字带有「圣刻」的怪兽。
function c53670497.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x69) and c:IsType(TYPE_MONSTER)
end
-- 效果2的目标选择函数：检查并选择自己除外区的1只「圣刻」怪兽作为对象，并设置送回墓地的操作信息。
function c53670497.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c53670497.filter2(chkc) end
	-- 效果2发动的合法性初检：自己的除外区存在至少1只满足filter2的「圣刻」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c53670497.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示选择提示，用于选择除外区的「圣刻」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53670497,3))  --"特殊召唤"
	-- 选择自己除外区的1只满足filter2的「圣刻」怪兽作为效果对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c53670497.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置本次连锁的操作信息为『将1只对象卡送去墓地』，对象为已选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果2的发动处理函数：将选择的对象卡送去墓地。
function c53670497.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果2发动时选择的那1只对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象卡送去墓地，原因同时包含『效果』和『回到墓地』，以对应‘回到墓地’的规则含义。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
-- 效果3的诱发条件判断：这张卡在场上表侧表示的状态下被送去墓地。
function c53670497.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义效果3的筛选条件：自己墓地中名字带有「圣刻」的怪兽，且能够被效果特殊召唤。
function c53670497.filter(c,e,tp)
	return c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果3目标选择函数的合法性检查部分：处理连锁对象合法性，并确认场上是否有空位、墓地是否有可特殊召唤的「圣刻」怪兽。
function c53670497.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53670497.filter(chkc,e,tp) end
	-- 效果3发动初检条件之一：自己场上存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果3发动初检条件之二：墓地存在至少1只满足filter的可特殊召唤「圣刻」怪兽。
		and Duel.IsExistingTarget(c53670497.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中的1只满足条件的「圣刻」怪兽作为特殊召唤对象（取对象）。
	local g=Duel.SelectTarget(tp,c53670497.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息为『将1只对象怪兽特殊召唤』。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果3的发动处理函数：若所选对象仍与效果相关联，则将其特殊召唤到自己的场上。
function c53670497.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果3发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
