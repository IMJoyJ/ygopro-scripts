--ヴォルカニック・リボルバー
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以让卡组的1只名字带有「火山」的怪兽在卡组最上面放置。
function c81020140.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以让卡组的1只名字带有「火山」的怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81020140,0))  --"检索"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c81020140.condition)
	e1:SetTarget(c81020140.target)
	e1:SetOperation(c81020140.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：自身是否被战斗破坏并送去墓地
function c81020140.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：名字带有「火山」的怪兽
function c81020140.filter(c)
	return c:IsSetCard(0x32) and c:IsType(TYPE_MONSTER)
end
-- 效果发动时的目标选择与合法性检查
function c81020140.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81020140.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：洗切卡组，并将选中的「火山」怪兽放置在卡组最上方
function c81020140.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示信息，提示玩家选择要在卡组最上方放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(81020140,1))  --"请选择要在卡组最上方放置的卡"
	-- 从卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c81020140.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的怪兽移动到卡组最上方
		Duel.MoveSequence(g:GetFirst(),SEQ_DECKTOP)
		-- 确认（展示）卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
