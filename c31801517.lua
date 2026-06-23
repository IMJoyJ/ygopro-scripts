--No.62 銀河眼の光子竜皇
-- 效果：
-- 8星怪兽×2
-- ①：这张卡进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时上升场上的超量怪兽的阶级合计×200。
-- ②：没有「银河眼光子龙」在作为超量素材中的这张卡给与对方的战斗伤害变成一半。
-- ③：有「银河眼光子龙」在作为超量素材中的这张卡被对方的效果破坏的场合才能发动。发动后第2次的自己准备阶段把这张卡的攻击力变成2倍特殊召唤。
function c31801517.initial_effect(c)
	-- 为卡片添加等级为8、需要2个素材的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：这张卡进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时上升场上的超量怪兽的阶级合计×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31801517,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c31801517.atkcon)
	e1:SetCost(c31801517.atkcost)
	e1:SetOperation(c31801517.atkop)
	c:RegisterEffect(e1)
	-- ③：有「银河眼光子龙」在作为超量素材中的这张卡被对方的效果破坏的场合才能发动。发动后第2次的自己准备阶段把这张卡的攻击力变成2倍特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31801517,1))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c31801517.spcon)
	e2:SetOperation(c31801517.spop)
	c:RegisterEffect(e2)
	-- ②：没有「银河眼光子龙」在作为超量素材中的这张卡给与对方的战斗伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetCondition(c31801517.rdcon)
	-- 设置战斗伤害为对方受到的伤害减半
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 设置该卡的编号为62
aux.xyz_number[31801517]=62
-- 判断该卡是否为攻击怪兽或被攻击怪兽
function c31801517.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 该卡为攻击怪兽或被攻击怪兽时效果发动
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 支付1个超量素材作为代价
function c31801517.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and c:GetFlagEffect(31801517)==0 end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	c:RegisterFlagEffect(31801517,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 计算场上所有表侧表示怪兽的阶级总和并乘以200作为攻击力加成
function c31801517.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取场上所有表侧表示怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local val=g:GetSum(Card.GetRank)*200
		-- 将攻击力增加指定数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end
-- 判断该卡是否被对方效果破坏且有银河眼光子龙作为超量素材
function c31801517.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,93717133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置一个在准备阶段触发的效果，用于在第2次准备阶段特殊召唤
function c31801517.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置一个在准备阶段触发的效果，用于在第2次准备阶段特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED+LOCATION_GRAVE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	-- 判断当前阶段是否为准备阶段且当前回合玩家为效果拥有者
	if Duel.GetCurrentPhase()==PHASE_STANDBY and Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
	else
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
	end
	e1:SetCountLimit(1)
	e1:SetCondition(c31801517.spcon2)
	e1:SetOperation(c31801517.spop2)
	c:RegisterEffect(e1)
	c:SetTurnCounter(0)
end
-- 判断当前回合玩家是否为效果拥有者
function c31801517.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果拥有者时效果发动
	return Duel.GetTurnPlayer()==tp
end
-- 处理特殊召唤逻辑，包括计数和实际召唤
function c31801517.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 特殊召唤该卡到场上
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		-- 将该卡的攻击力设置为原来的2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 判断该卡的超量素材中是否没有银河眼光子龙
function c31801517.rdcon(e)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,93717133)
end
