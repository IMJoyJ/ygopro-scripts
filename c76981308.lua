--メルフィーとにらめっこ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡1只兽族怪兽给对方观看才能发动。和那只怪兽卡名不同的1只「童话动物」怪兽从自己的卡组·墓地加入手卡，给人观看的怪兽回到卡组最下面。
-- ②：对方战斗阶段开始时才能发动。手卡的「童话动物」怪兽任意数量给对方观看，只在战斗阶段内公开。
-- ③：对方场上的怪兽的攻击力下降这张卡的②的效果公开中的怪兽的攻击力·守备力的合计数值。
function c76981308.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：把手卡1只兽族怪兽给对方观看才能发动。和那只怪兽卡名不同的1只「童话动物」怪兽从自己的卡组·墓地加入手卡，给人观看的怪兽回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,76981308)
	e1:SetCost(c76981308.cost)
	e1:SetTarget(c76981308.target)
	e1:SetOperation(c76981308.operation)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段开始时才能发动。手卡的「童话动物」怪兽任意数量给对方观看，只在战斗阶段内公开。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76981308,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,76981309)
	e2:SetCondition(c76981308.atkcon)
	e2:SetTarget(c76981308.atktg)
	e2:SetOperation(c76981308.atkop)
	c:RegisterEffect(e2)
	-- ③：对方场上的怪兽的攻击力下降这张卡的②的效果公开中的怪兽的攻击力·守备力的合计数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetValue(c76981308.atkval)
	c:RegisterEffect(e3)
	e3:SetLabelObject(e2)
end
-- 过滤手牌中未公开、且卡组或墓地存在与其卡名不同的「童话动物」怪兽的兽族怪兽
function c76981308.cfilter(c,tp)
	return not c:IsPublic() and c:IsRace(RACE_BEAST) and c:IsAbleToDeck()
		-- 检查自己的卡组或墓地是否存在满足cfilter2过滤条件的卡片（即与展示怪兽卡名不同的「童话动物」怪兽）
		and Duel.IsExistingMatchingCard(c76981308.cfilter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c)
end
-- 过滤卡组或墓地中与展示怪兽卡名不同、且可以加入手牌的「童话动物」怪兽卡
function c76981308.cfilter2(c,oc)
	return not c:IsCode(oc:GetCode()) and c:IsAbleToHand() and c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER)
end
-- 效果①的Cost：将手牌中1只满足条件的兽族怪兽给对方观看，并将其暂存为LabelObject
function c76981308.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(1)
		-- 检查手牌中是否存在可以作为Cost展示的兽族怪兽
		return Duel.IsExistingMatchingCard(c76981308.cfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要返回卡组的卡片（此处实际对应展示的卡片）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择手牌中1只满足条件的兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c76981308.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	-- 给对方玩家确认展示的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自身手牌
	Duel.ShuffleHand(tp)
	e:SetLabelObject(g:GetFirst())
end
-- 效果①的Target：建立展示怪兽与效果的关系，并设置返回卡组和检索的操作信息
function c76981308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local b=e:GetLabel()
		e:SetLabel(0)
		return b==1
	end
	e:GetLabelObject():CreateEffectRelation(e)
	-- 设置操作信息：将1张卡（展示的怪兽）送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetLabelObject(),1,0,0)
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation：从卡组或墓地将1只卡名不同的「童话动物」怪兽加入手牌，然后将展示的怪兽回到卡组最下面
function c76981308.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张与展示怪兽卡名不同的「童话动物」怪兽（受王家之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c76981308.cfilter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc)
	-- 若成功将选择的怪兽加入手牌
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 将展示的怪兽送回持有者卡组最下面
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方的战斗阶段开始时
function c76981308.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方玩家
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤手牌中未公开的「童话动物」怪兽卡
function c76981308.atkfilter(c)
	return not c:IsPublic() and c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER)
end
-- 效果②的Target：检查手牌中是否存在可公开的「童话动物」怪兽
function c76981308.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只未公开的「童话动物」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76981308.atkfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- 效果②的Operation：让玩家选择任意数量手牌中的「童话动物」怪兽，在战斗阶段内持续公开，并保存这些怪兽的卡片组
function c76981308.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要公开的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(76981308,2))  --"请选择要公开的怪兽"
	-- 让玩家选择手牌中任意数量（1-99张）的「童话动物」怪兽
	local g=Duel.SelectMatchingCard(tp,c76981308.atkfilter,tp,LOCATION_HAND,0,1,99,nil)
	if #g==0 then return end
	-- 遍历所有被选择公开的怪兽
	for tc in aux.Next(g) do
		-- 只在战斗阶段内公开。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetDescription(66)
		e1:SetCode(EFFECT_PUBLIC)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(76981308,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
	end
	g:KeepAlive()
	local g2=e:GetLabelObject()
	if g2 then g2:DeleteGroup() end
	e:SetLabelObject(g)
end
-- 计算带有此卡效果标记的怪兽的攻击力与守备力合计数值
function c76981308.sum(c)
	if c:GetFlagEffect(76981308)==0 then return 0 end
	return c:GetAttack()+c:GetDefense()
end
-- 计算对方场上怪兽攻击力下降的数值（即所有公开中怪兽的攻守合计值之和的负值）
function c76981308.atkval(e,c)
	local g=e:GetLabelObject():GetLabelObject()
	if g and #g>0 then
		return -g:GetSum(c76981308.sum)
	end
	return 0
end
