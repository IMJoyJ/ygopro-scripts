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
	-- 为这张卡添加灵摆怪兽属性（可进行灵摆召唤、作为灵摆卡在灵摆区域发动）
	aux.EnablePendulumAttribute(c)
	c:EnableCounterPermit(0x1)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：另一边的自己的灵摆区域没有卡存在的场合才能发动。这张卡破坏，从卡组把1只7星以下的「魔导兽」效果怪兽加入手卡。
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
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- 记录连锁发生时这张卡在怪兽区域存在，供后续放置魔力指示物的处理判定
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
c53842431.mentioned_counter={
	[0x1]=true,
}
-- 灵摆效果①的发动条件：检查另一边的自己的灵摆区域没有卡存在
function c53842431.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的灵摆区域除这张卡以外没有其他卡存在，即另一边的灵摆区域没有卡存在
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 检索过滤条件：7星以下的「魔导兽」效果怪兽且可以加入手卡
function c53842431.thfilter(c)
	return c:IsSetCard(0x10d) and c:IsLevelBelow(7)
		and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 灵摆效果①的目标处理：检查能否破坏这张卡且卡组有可检索的卡，并设置破坏和检索的操作信息
function c53842431.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果可发动检测：这张卡可以被效果破坏，且卡组存在至少1只7星以下的「魔导兽」效果怪兽
	if chk==0 then return c:IsDestructable() and Duel.IsExistingMatchingCard(c53842431.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：连锁处理时将把这张卡破坏1张
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置操作信息：连锁处理时将从自己卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果①的效果处理：破坏这张卡，成功后从卡组选1只7星以下的「魔导兽」效果怪兽加入手卡并向对方展示
function c53842431.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡仍与效果关联且以效果原因成功破坏这张卡的场合，继续后续检索处理
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 向玩家提示「请选择要加入手卡的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己卡组选择1只满足条件的7星以下的「魔导兽」效果怪兽
		local g=Duel.SelectMatchingCard(tp,c53842431.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡以效果原因加入持有者的手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的那张卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 怪兽效果①的处理：自己或对方把魔法卡发动的场合（卡的发动且为魔法卡、这张卡在连锁发生时存在于场上），给这张卡放置2个魔力指示物
function c53842431.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 怪兽效果②的适用条件：自己场上有4个以上魔力指示物存在
function c53842431.incon(e)
	-- 检查自己场上存在的魔力指示物数量是否在4个以上
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x1)>=4
end
-- 怪兽效果③的发动代价：检查并把自己场上4个魔力指示物取除
function c53842431.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否可以取除4个魔力指示物作为代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,4,REASON_COST) end
	-- 作为发动代价把自己场上4个魔力指示物取除
	Duel.RemoveCounter(tp,1,0,0x1,4,REASON_COST)
end
-- 对象过滤条件：可以除外的卡
function c53842431.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 怪兽效果③的目标选择：以对方场上1只可以除外的怪兽为对象，并设置除外的操作信息
function c53842431.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53842431.rmfilter(chkc) end
	-- 检查对方场上是否存在至少1只可以除外且能成为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53842431.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示「请选择要除外的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择对方场上1只可以除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53842431.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：连锁处理时将把作为对象的1只怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 怪兽效果③的效果处理：把作为对象的对方怪兽除外，这张卡的攻击力直到对方回合结束时上升那只怪兽的原本攻击力数值
function c53842431.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁作为对象的1只怪兽
	local tc=Duel.GetFirstTarget()
	-- 对象怪兽仍与效果关联且成功将其表侧表示除外，且这张卡在场上表侧表示存在并仍与效果关联的场合，继续攻击力上升处理
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 这张卡的攻击力直到对方回合结束时上升除外的那只怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
