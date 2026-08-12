--サイバー・オーガ・2
-- 效果：
-- 「电子食人魔」＋「电子食人魔」
-- 这只怪兽的融合召唤只能用上记的卡进行。这张卡进行攻击时，这张卡的攻击力上升攻击对象怪兽的攻击力一半的数值。
function c37057012.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2张编号为64268668的卡作为融合素材
	aux.AddFusionProcCodeRep(c,64268668,2,false,false)
	-- 这张卡进行攻击时，这张卡的攻击力上升攻击对象怪兽的攻击力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c37057012.atkcon)
	e1:SetValue(c37057012.atkval)
	c:RegisterEffect(e1)
end
-- 攻击时触发的条件判断函数，用于判断是否满足攻击力上升效果的触发条件
function c37057012.atkcon(e)
	-- 判断当前阶段是否为伤害计算阶段
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		-- 判断当前攻击的怪兽是否为该卡，且存在攻击对象
		and e:GetHandler()==Duel.GetAttacker() and Duel.GetAttackTarget()~=nil
end
-- 攻击力上升效果的计算函数，用于计算攻击力提升值
function c37057012.atkval(e,c)
	-- 计算攻击对象怪兽攻击力的一半并向上取整作为提升的攻击力
	return math.ceil(Duel.GetAttackTarget():GetAttack()/2)
end
