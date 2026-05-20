--黒羽を狩る者
-- 效果：
-- 对方场上有表侧表示怪兽2只以上存在，那些怪兽的种族全部相同的场合，可以把1张手卡送去墓地选择对方场上表侧表示存在的1只怪兽破坏。
function c73018302.initial_effect(c)
	-- 对方场上有表侧表示怪兽2只以上存在，那些怪兽的种族全部相同的场合，可以把1张手卡送去墓地选择对方场上表侧表示存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73018302,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c73018302.descon)
	e1:SetCost(c73018302.descost)
	e1:SetTarget(c73018302.destg)
	e1:SetOperation(c73018302.desop)
	c:RegisterEffect(e1)
end
-- 检查对方场上是否存在2只以上且种族全部相同的表侧表示怪兽
function c73018302.check(tp)
	-- 获取对方场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()<2 then return false end
	local rac=g:GetFirst():GetRace()
	local tc=g:GetNext()
	while tc do
		if tc:GetRace()~=rac then return false end
		tc=g:GetNext()
	end
	return true
end
-- 发动条件：对方场上有2只以上表侧表示怪兽存在且种族全部相同
function c73018302.descon(e,tp,eg,ep,ev,re,r,rp)
	return c73018302.check(tp)
end
-- 发动代价：将1张手牌送去墓地
function c73018302.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择1张手牌作为代价送去墓地
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 过滤条件：表侧表示的卡
function c73018302.filter(c)
	return c:IsFaceup()
end
-- 发动目标：选择对方场上1只表侧表示的怪兽为对象
function c73018302.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c73018302.filter(chkc) end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c73018302.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73018302.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏该怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若对象怪兽仍表侧表示存在且满足种族相同的条件，则将其破坏
function c73018302.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and c73018302.check(tp) then
		-- 破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
