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
	-- 为当前卡片启用灵摆怪兽属性，使其可以进行灵摆召唤和发动灵摆卡。
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
	-- 创建一个持续性场上效果，用于在连锁发生时注册当前卡片的存在。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	-- aux.chainreg 函数用于记录连锁发生时这张卡在场上存在，以便后续的效果可以正确触发。
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
	-- 创建一个单次效果，当满足一定条件时（场上有4个或以上魔力指示物），使当前卡片不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c53842431.incon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- ①：1回合1次，把自己场上4个魔力指示物取除，以对方场上1只怪兽为对象才能发动。那只怪兽除外。这张卡的攻击力直到对方回合结束时上升除外的那只怪兽的原本攻击力数值。
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
-- 定义一个条件函数，用于判断另一侧灵摆区域是否为空，作为灵摆效果发动的条件。
function c53842431.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一侧的灵摆区域是否没有卡片存在。
	return not Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 定义一个过滤函数，用于筛选符合条件的「魔导兽」怪兽（7星以下、具有效果且可以加入手牌）。
function c53842431.thfilter(c)
	return c:IsSetCard(0x10d) and c:IsLevelBelow(7)
		and c:IsType(TYPE_EFFECT) and c:IsAbleToHand()
end
-- 设置目标选择和操作信息，用于从卡组检索并加入手牌的「魔导兽」怪兽。
function c53842431.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查当前卡片是否可破坏以及是否存在符合条件的「魔导兽」怪兽在卡组中。
	if chk==0 then return c:IsDestructable() and Duel.IsExistingMatchingCard(c53842431.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示要破坏一张卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
	-- 设置连锁的操作信息，表示要将一张卡片加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义一个操作函数，用于执行灵摆效果：破坏当前卡片并从卡组检索「魔导兽」怪兽加入手牌。
function c53842431.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡片是否与效果相关联并且成功被破坏。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择符合条件的「魔导兽」怪兽。
		local g=Duel.SelectMatchingCard(tp,c53842431.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选定的「魔导兽」怪兽加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认加入手牌的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 创建一个持续性场上效果，用于在连锁发生时注册当前卡片的存在。
function c53842431.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 定义一个条件函数，用于判断是否满足使当前卡片不会被破坏的条件（拥有4个或以上魔力指示物）。
function c53842431.incon(e)
	-- 检查场上是否存在4个或以上的魔力指示物。
	return Duel.GetCounter(e:GetHandlerPlayer(),1,0,0x1)>=4
end
-- 定义一个费用支付函数，用于移除指定数量的魔力指示物作为效果发动的前置条件。
function c53842431.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以移除4个魔力指示物作为费用。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,4,REASON_COST) end
	-- 移除4个魔力指示物作为费用。
	Duel.RemoveCounter(tp,1,0,0x1,4,REASON_COST)
end
-- 定义一个过滤函数，用于筛选可以被除外的目标怪兽。
function c53842431.rmfilter(c)
	return c:IsAbleToRemove()
end
-- 设置目标选择和操作信息，用于从对方场上选择一只怪兽并将其除外。
function c53842431.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c53842431.rmfilter(chkc) end
	-- 检查是否存在可被选为目标的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c53842431.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择一只符合条件的怪兽。
	local g=Duel.SelectTarget(tp,c53842431.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表示要移除一张卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 定义一个操作函数，用于执行效果：除外选定的目标怪兽并提升当前卡片的攻击力。
function c53842431.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否与效果相关联、成功被移除以及当前卡片是否在场上且与效果相关联。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 创建一个单次效果，提升当前卡片的攻击力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		c:RegisterEffect(e1)
	end
end
