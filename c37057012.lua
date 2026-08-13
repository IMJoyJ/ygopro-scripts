--サイバー・オーガ・2
-- 效果：
-- 「电子食人魔」＋「电子食人魔」
-- 这只怪兽的融合召唤只能用上记的卡进行。这张卡进行攻击时，这张卡的攻击力上升攻击对象怪兽的攻击力一半的数值。
function c37057012.initial_effect(c)
	c:EnableReviveLimit()
	-- 为电子食人魔2添加融合召唤手续：需要以2只「电子食人魔」（卡号64268668）为融合素材，且非替代素材、不启用其他融合素材替代效果，配合EnableReviveLimit实现“只能以这些卡进行融合召唤”。
	aux.AddFusionProcCodeRep(c,64268668,2,false,false)
	-- 对应效果原文：“这张卡进行攻击时，这张卡的攻击力上升攻击对象怪兽的攻击力一半的数值。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37057012.atkcon)
	e1:SetValue(c37057012.atkval)
	c:RegisterEffect(e1)
end
-- 攻击力上升效果的发动条件：仅在伤害计算阶段，且效果持有者是当前发动攻击的怪兽、并存在攻击对象怪兽时满足。
function c37057012.atkcon(e)
	-- 判断当前阶段是否为伤害计算阶段（PHASE_DAMAGE_CAL）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 进一步判断效果持有者（这张卡）就是正在攻击的怪兽，且攻击对象怪兽存在（不是直接攻击）。
		and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil
end
-- 计算攻击力上升数值：以攻击对象怪兽当前的攻击力为基准，取其一半并向上取整。
function c37057012.atkval(e,c)
	-- 返回攻击对象怪兽攻击力的一半（向上取整），作为这张卡的攻击力上升值。
	return math.ceil(Duel.GetAttackTarget():GetAttack()/2)
end
