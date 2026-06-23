--魔導獣 マスターケルベロス
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从卡组把1只7星以下的「魔导兽」效果怪兽加入手卡。
-- 【怪兽效果】
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
-- ②：自己场上有魔力指示物4个以上存在的场合，这张卡不会被效果破坏。
-- ③：1回合1次，把自己场上4个魔力指示物取除，以对方场上1只怪兽为对象才能发动。那只怪兽除外。这张卡的攻击力直到对方回合结束时上升除外的那只怪兽的原本攻击力数值。
function c53842431.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性（灵摆召唤，灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- ①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从卡组把1只7星以下的「魔导兽」效果怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53842431,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,53842431)
	e1:SetCondition(c53842431.thcon)
	e1:SetTarget(c53842431.thtg)
	e1:SetOperation(c53842431.thop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在场上存在
	e2:SetOperation(aux.chainreg)
	c:RegisterEffect(e2)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c53842431.acop)
	c:RegisterEffect(e3)
	-- ②：自己场上有魔力指示物4个以上存在的场合，这张卡不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c53842431.incon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ③：1回合1次，把自己场上4个魔力指示物取除，以对方场上1只怪兽为对象才能发动。那只怪兽除外。这张卡的攻击力直到对方回合结束时上升除外的那只怪兽的原本攻击力数值。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(53842431,1))
	e5:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_REMOVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCost(c53842431.rmcost)
	e5:SetTarget(c53842431.rmtg)
	e5:SetOperation(c53842431.rmop)
	c:RegisterEffect(e5)
end
-- 判断另一边的自己的灵摆区域是否没有卡存在
function c53842431.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 另一边的自己的灵摆区域没有卡存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 定义灵摆效果中用于检索的卡牌过滤条件（7星以下的魔导兽效果怪兽）
function c53842431.thfilter(c)
	return c:IsSetCard(0x10d) and c:IsLevelBelow(7)
		and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 设置灵摆效果的目标和操作信息（破坏自身并检索手牌）
function c53842431.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查灵摆效果是否可以发动（自身可破坏且卡组存在符合条件的怪兽）
	if chk==0 then return c:IsDestructable() and Duel.IsExistingMatchingCard(c53842431.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将自身破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：从卡组检索1只符合条件的怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行灵摆效果的操作（破坏自身并检索手牌）
function c53842431.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否在场上且可被破坏
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的卡牌
		local g=Duel.SelectMatchingCard(tp,c53842431.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡牌送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看了送入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 处理连锁时的效果（当发动魔法卡时给自身放置2个魔力指示物）
function c53842431.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 判断自身是否拥有4个或以上魔力指示物
function c53842431.incon(e)
	-- 拥有4个或以上魔力指示物
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x1)>=4
end
-- 设置效果的费用（移除4个魔力指示物）
function c53842431.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以移除4个魔力指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,4,REASON_COST) end
	-- 移除4个魔力指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x1,4,REASON_COST)
end
-- 定义用于除外怪兽的过滤条件（可除外）
function c53842431.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 设置效果的目标和操作信息（选择对方场上一只怪兽除外）
function c53842431.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53842431.rmfilter(chkc) end
	-- 检查是否可以除外对方场上的一只怪兽
	if chk==0 then return Duel.IsExistingTarget(c53842431.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上一只怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c53842431.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将目标怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 执行效果操作（除外对方怪兽并提升攻击力）
function c53842431.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且可被除外，自身是否在场上且有效
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 提升自身攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
