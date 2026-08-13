--No.62 銀河眼の光子竜皇
-- 效果：
-- 8星怪兽×2
-- ①：这张卡进行战斗的伤害计算时1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时上升场上的超量怪兽的阶级合计×200。
-- ②：没有「银河眼光子龙」在作为超量素材中的这张卡给与对方的战斗伤害变成一半。
-- ③：有「银河眼光子龙」在作为超量素材中的这张卡被对方的效果破坏的场合才能发动。发动后第2次的自己准备阶段把这张卡的攻击力变成2倍特殊召唤。
function c31801517.initial_effect(c)
	-- 为此卡添加超量召唤手续：需要2只8星怪兽作为超量素材，方可从额外卡组超量召唤。
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
	-- 设置此效果的值：此卡给予对方玩家的战斗伤害变为一半（通过辅助函数封装伤害变更逻辑）。
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
end
-- 将此卡登记为No.62编号的超量怪兽，供其他卡或规则判断“No.62”卡片使用。
aux.xyz_number[31801517]=62
-- 定义效果①的发动条件函数：检查此卡是否为当前战斗中的攻击怪兽或攻击对象。
function c31801517.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当此卡等于当前战斗的攻击怪兽或攻击目标时，返回true（即此卡正在进行战斗）。
	return c==Duel.GetAttacker() or c==Duel.GetAttackTarget()
end
-- 定义效果①的发动代价：若可以取除自己1个超量素材且本次伤害计算尚未发动过该效果，则取除1个超量素材作为代价，并在伤害计算阶段内附加该效果的发动标记；此标记在伤害计算阶段结束重置，实现“1次”限制。
function c31801517.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) and c:GetFlagEffect(31801517)==0 end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
	c:RegisterFlagEffect(31801517,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 定义效果①的解决处理：若此卡仍与该效果关联且表侧表示，则收集双方场上所有表侧怪兽，计算阶级合计×200，并为此卡附加仅在本次伤害计算阶段有效的攻击力上升效果。
function c31801517.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 获取双方场上所有表侧表示怪兽的集合（用于随后统计其中超量怪兽的阶级合计）。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local val=g:GetSum(Card.GetRank)*200
		-- 这张卡的攻击力只在那次伤害计算时上升场上的超量怪兽的阶级合计×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(val)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		c:RegisterEffect(e1)
	end
end
-- 定义效果③的发动条件：此卡在之前由自己控制且在怪兽区域被对方的效果破坏，破坏时其作为超量素材中含有「银河眼光子龙」，并且自身满足特殊召唤条件。
function c31801517.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,93717133)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果③发动后的处理：在墓地/除外区注册一个在准备阶段触发的延迟效果，用于累计自己的准备阶段次数；若破坏时正好处于自己的准备阶段，则将延迟效果的重置次数设为3，否则设为2，之后把此卡的回合计数器初始化为0。
function c31801517.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 发动后第2次的自己准备阶段把这张卡的攻击力变成2倍特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_REMOVED+LOCATION_GRAVE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	-- 判断当前阶段是否为自己的准备阶段，用于设置延迟效果的剩余重置次数，以正确对应“第2次自己的准备阶段”触发。
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
-- 定义延迟效果的触发条件：仅当当前回合玩家为己方时触发，即在自己的准备阶段。
function c31801517.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为自己时返回true，保证只在己方准备阶段计数。
	return Duel.GetTurnPlayer()==tp
end
-- 定义延迟效果的解决：每次自己的准备阶段使此卡的回合计数加1；当计数达到2时，将此卡特殊召唤，并赋予其攻击力变成2倍的效果。
function c31801517.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		-- 将此卡以表侧攻击表示特殊召唤到己方场上（作为连续特殊召唤处理的一步）。
		Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP)
		-- 把这张卡的攻击力变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 完成特殊召唤处理，将此前通过SpecialSummonStep的卡正式特殊召唤上场，并触发对应的特殊召唤成功时点。
		Duel.SpecialSummonComplete()
	end
end
-- 定义效果②的适用条件：此卡的超量素材中没有「银河眼光子龙」时返回true。
function c31801517.rdcon(e)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,93717133)
end
