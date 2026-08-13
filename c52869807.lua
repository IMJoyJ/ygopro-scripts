--BF－逆風のガスト
-- 效果：
-- 自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。只要这张卡在场上表侧表示存在，对方怪兽向自己场上存在的名字带有「黑羽」的怪兽攻击的场合，那只攻击怪兽在伤害步骤内攻击力下降300。
function c52869807.initial_effect(c)
	-- 自己场上没有卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52869807.spcon)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，对方怪兽向自己场上存在的名字带有「黑羽」的怪兽攻击的场合，那只攻击怪兽在伤害步骤内攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c52869807.atkcon)
	e2:SetTarget(c52869807.atktg)
	e2:SetValue(-300)
	c:RegisterEffect(e2)
end
-- 作为特殊召唤规则效果的条件函数，确认这张卡的控制者场上没有任何卡，且主要怪兽区域存在空格，满足时才能从手卡特殊召唤。
function c52869807.spcon(e,c)
	if c==nil then return true end
	-- 确认这张卡的控制者有可用的主要怪兽区域空格，以满足从手卡特殊召唤所需的空间条件。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 确认这张卡的控制者场上没有任何卡（怪兽区和魔法陷阱区均为空），满足“自己场上没有卡存在”的特殊召唤条件。
		Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end
-- 攻击力下降效果的适用条件：当前阶段为伤害步骤或伤害计算时，且本次攻击的被攻击对象是自己场上的名字带有「黑羽」的怪兽。
function c52869807.atkcon(e)
	-- 获取当前战斗阶段，用于判断是否处于伤害步骤或伤害计算时，从而决定是否适用攻击力下降效果。
	local ph=Duel.GetCurrentPhase()
	-- 获取当前攻击的目标怪兽（被攻击的怪兽），用于判断该怪兽是否是自己场上名字带有「黑羽」的怪兽。
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and d and d:IsControler(tp) and d:IsSetCard(0x33)
end
-- 攻击力下降效果的对象筛选函数，将适用对象限定为当前发动攻击的攻击怪兽，使“那只攻击怪兽”在伤害步骤内攻击力下降300。
function c52869807.atktg(e,c)
	-- 判断怪兽c是否为当前攻击怪兽，若是则将其作为攻击力下降效果的适用对象。
	return c==Duel.GetAttacker()
end
