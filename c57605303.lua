--武装竜の万雷
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「武装龙」怪兽为对象才能发动。那只怪兽的攻击力上升持有那只怪兽的等级以下的等级的自己墓地的「武装龙」怪兽种类×1000。这个回合，那只怪兽给与对方的战斗伤害变成0。
-- ②：把墓地的这张卡除外，以自己墓地1张「武装龙」魔法卡为对象才能发动。那张卡加入手卡。
function c57605303.initial_effect(c)
	-- ①：以自己场上1只「武装龙」怪兽为对象才能发动。那只怪兽的攻击力上升持有那只怪兽的等级以下的等级的自己墓地的「武装龙」怪兽种类×1000。这个回合，那只怪兽给与对方的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57605303,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,57605303)
	e1:SetTarget(c57605303.target)
	e1:SetOperation(c57605303.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「武装龙」魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57605303,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,57605303)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c57605303.thtg)
	e2:SetOperation(c57605303.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的「武装龙」怪兽，且自己墓地存在等级在它以下的「武装龙」怪兽
function c57605303.filter(c,tp)
	-- 检查卡片是否为表侧表示的「武装龙」怪兽，且自己墓地存在等级在它以下的「武装龙」怪兽
	return c:IsFaceup() and c:IsSetCard(0x111) and Duel.IsExistingMatchingCard(c57605303.atkfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetLevel())
end
-- 过滤自己墓地中等级在指定等级以下的「武装龙」怪兽
function c57605303.atkfilter(c,lv)
	return c:IsSetCard(0x111) and c:IsLevelBelow(lv)
end
-- 效果①的发动准备与目标选择
function c57605303.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57605303.filter(chkc,tp) end
	-- 检查场上是否存在可以作为效果对象的「武装龙」怪兽
	if chk==0 then return Duel.IsExistingTarget(c57605303.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「武装龙」怪兽作为效果对象
	Duel.SelectTarget(tp,c57605303.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果①的处理（提升攻击力，并使给与对方的战斗伤害变成0）
function c57605303.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 获取自己墓地中等级在对象怪兽等级以下的「武装龙」怪兽组
		local g=Duel.GetMatchingGroup(c57605303.atkfilter,tp,LOCATION_GRAVE,0,nil,tc:GetLevel())
		local ct=g:GetClassCount(Card.GetCode)
		if ct>0 then
			-- 那只怪兽的攻击力上升持有那只怪兽的等级以下的等级的自己墓地的「武装龙」怪兽种类×1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个回合，那只怪兽给与对方的战斗伤害变成0。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCondition(c57605303.damcon)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e2:SetOwnerPlayer(tp)
			tc:RegisterEffect(e2)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e3:SetCondition(c57605303.damcon2)
			e3:SetValue(1)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判定是否为该怪兽的控制者（用于使给与对方的战斗伤害变成0）
function c57605303.damcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 判定是否为该怪兽控制者的对手（用于避免对方受到的战斗伤害）
function c57605303.damcon2(e)
	return 1-e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 过滤自己墓地中可以加入手牌的「武装龙」魔法卡
function c57605303.thfilter(c)
	return c:IsSetCard(0x111) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择
function c57605303.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57605303.thfilter(chkc) end
	-- 检查自己墓地是否存在可以加入手牌的「武装龙」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c57605303.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「武装龙」魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c57605303.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息为“将选择的卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理（将选择的卡加入手牌）
function c57605303.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
