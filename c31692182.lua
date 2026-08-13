--コアキメイル・フルバリア
-- 效果：
-- 从手卡让1张「核成兽的钢核」回到卡组最上面发动。直到下次的自己回合的准备阶段时，名字带有「核成」的怪兽以外的场上表侧表示存在的效果怪兽的效果无效化。
function c31692182.initial_effect(c)
	-- 将该卡效果文本中提到的卡「核成兽的钢核」（卡号36623431）登记到代码列表，用于后续的卡名关联处理与提示。
	aux.AddCodeList(c,36623431)
	-- 从手卡让1张「核成兽的钢核」回到卡组最上面发动。直到下次的自己回合的准备阶段时，名字带有「核成」的怪兽以外的场上表侧表示存在的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31692182,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c31692182.cost)
	e1:SetOperation(c31692182.operation)
	c:RegisterEffect(e1)
end
-- 定义代价筛选条件：手牌中的「核成兽的钢核」，并且可以作为代价返回卡组。
function c31692182.cfilter(c)
	return c:IsCode(36623431) and c:IsAbleToDeckAsCost()
end
-- 发动代价的处理：选择手牌中1张「核成兽的钢核」返回卡组最顶端，作为发动本效果的代价。
function c31692182.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查阶段：确认手牌中是否存在至少1张满足条件的「核成兽的钢核」可供返回卡组。
	if chk==0 then return Duel.IsExistingMatchingCard(c31692182.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 显示选择提示，提示玩家选择要返回卡组的卡（HINTMSG_TODECK）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手牌选择1张满足cfilter条件的「核成兽的钢核」作为代价。
	local g=Duel.SelectMatchingCard(tp,c31692182.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡以代价形式返回持有者卡组最顶端（SEQ_DECKTOP）。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 定义无效化对象筛选：场上的效果怪兽，且不属于「核成」系列（SetCard 0x1d）。
function c31692182.filter(e,c)
	return c:IsType(TYPE_EFFECT) and not c:IsSetCard(0x1d)
end
-- 效果处理：创建一个持续到下次自己回合准备阶段的领域效果，使场上非「核成」系列的效果怪兽效果无效化。
function c31692182.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 直到下次的自己回合的准备阶段时，名字带有「核成」的怪兽以外的场上表侧表示存在的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c31692182.filter)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
	-- 将生成的无效化效果注册到场上，使其开始适用。
	Duel.RegisterEffect(e1,tp)
end
