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
	-- 只要这张卡在场上表侧表示存在，对方怪兽向自己场上存在的名字带有「黑羽」的怪兽攻击的场合，那只攻击怪兽在伤害步骤内攻击力下降 300。
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
-- 检查场上是否有空位且自己场上没有卡存在
function c52869807.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上怪兽区是否有可用空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 检查自己场上是否没有任何卡存在
		Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,0)==0
end
-- 检查是否为伤害步骤且攻击目标为我方黑羽怪兽
function c52869807.atkcon(e)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 获取当前攻击的目标怪兽
	local d=Duel.GetAttackTarget()
	local tp=e:GetHandlerPlayer()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		and d and d:IsControler(tp) and d:IsSetCard(0x33)
end
-- 检查目标是否为攻击怪兽
function c52869807.atktg(e,c)
	-- 判断该卡是否为本次攻击的攻击者
	return c==Duel.GetAttacker()
end
