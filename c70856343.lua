--契珖のヴルーレセンス
-- 效果：
-- ①：对方场上有怪兽存在，这张卡召唤成功时，丢弃1张手卡才能发动。从卡组把「契珖之荧光亚龙」任意数量送去墓地。
-- ②：1回合1次，这张卡在墓地存在的场合才能发动。墓地的这张卡直到回合结束时变成暗属性。
function c70856343.initial_effect(c)
	-- ①：对方场上有怪兽存在，这张卡召唤成功时，丢弃1张手卡才能发动。从卡组把「契珖之荧光亚龙」任意数量送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70856343,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c70856343.tgcon)
	e1:SetCost(c70856343.tgcost)
	e1:SetTarget(c70856343.tgtg)
	e1:SetOperation(c70856343.tgop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡在墓地存在的场合才能发动。墓地的这张卡直到回合结束时变成暗属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70856343,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c70856343.atttg)
	e2:SetOperation(c70856343.attop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c70856343.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 效果①的发动代价处理函数
function c70856343.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中卡名为「契珖之荧光亚龙」且能送去墓地的卡片
function c70856343.filter(c)
	return c:IsCode(70856343) and c:IsAbleToGrave()
end
-- 效果①的发动目标判定与操作信息设置函数
function c70856343.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查卡组中是否存在至少1张「契珖之荧光亚龙」
	if chk==0 then return Duel.IsExistingMatchingCard(c70856343.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息为：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数
function c70856343.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中满足条件的「契珖之荧光亚龙」的数量
	local ct=Duel.GetMatchingGroupCount(c70856343.filter,tp,LOCATION_DECK,0,nil)
	if ct<=0 then return end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择任意数量（1到ct张）的「契珖之荧光亚龙」
	local g=Duel.SelectMatchingCard(tp,c70856343.filter,tp,LOCATION_DECK,0,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动目标判定与操作信息设置函数
function c70856343.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsAttribute(ATTRIBUTE_DARK) end
	-- 设置效果处理信息为：墓地的这张卡涉及墓地相关的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理函数
function c70856343.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 墓地的这张卡直到回合结束时变成暗属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(ATTRIBUTE_DARK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
