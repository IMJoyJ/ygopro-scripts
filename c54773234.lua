--禁じられた聖典
-- 效果：
-- ①：双方怪兽进行战斗的伤害计算时才能发动。直到伤害步骤结束时，这张卡以外的场上的卡的效果无效化，那次战斗的伤害计算用原本的攻击力·守备力进行。
function c54773234.initial_effect(c)
	-- ①：双方怪兽进行战斗的伤害计算时才能发动。直到伤害步骤结束时，这张卡以外的场上的卡的效果无效化，那次战斗的伤害计算用原本的攻击力·守备力进行。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(c54773234.condition)
	e1:SetOperation(c54773234.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数
function c54773234.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否存在攻击对象（即双方怪兽进行战斗）
	return Duel.GetAttackTarget()~=nil
end
-- 效果处理函数
function c54773234.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击侧怪兽
	local a=Duel.GetAttacker()
	-- 获取防守侧怪兽
	local d=Duel.GetAttackTarget()
	-- 直到伤害步骤结束时，这张卡以外的场上的卡的效果无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetTarget(c54773234.distg)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使场上卡片效果无效的永续效果
	Duel.RegisterEffect(e1,tp)
	-- 直到伤害步骤结束时，这张卡以外的场上的卡的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c54773234.disop)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册在连锁处理时无效化场上卡片效果的事件型效果
	Duel.RegisterEffect(e2,tp)
	-- 直到伤害步骤结束时，这张卡以外的场上的卡的效果无效化
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使陷阱怪兽效果无效的效果
	Duel.RegisterEffect(e3,tp)
	-- 手动刷新场上卡片的无效状态
	Duel.AdjustInstantly()
	if a:IsRelateToBattle() then
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_BATTLE_ATTACK)
		e4:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e4:SetValue(a:GetBaseAttack())
		a:RegisterEffect(e4,true)
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_SET_BATTLE_DEFENSE)
		e5:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e5:SetValue(a:GetBaseDefense())
		a:RegisterEffect(e5,true)
	end
	if d and d:IsRelateToBattle() then
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetCode(EFFECT_SET_BATTLE_ATTACK)
		e6:SetValue(d:GetBaseAttack())
		e6:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e6,true)
		-- 那次战斗的伤害计算用原本的攻击力·守备力进行。
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_SINGLE)
		e7:SetCode(EFFECT_SET_BATTLE_DEFENSE)
		e7:SetValue(d:GetBaseDefense())
		e7:SetReset(RESET_PHASE+PHASE_DAMAGE)
		d:RegisterEffect(e7,true)
	end
end
-- 过滤无效化目标的函数，排除这张卡自身
function c54773234.distg(e,c)
	return c~=e:GetHandler()
end
-- 连锁处理时无效化场上卡片效果的操作函数
function c54773234.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(loc,LOCATION_ONFIELD)~=0 then
		-- 无效化该连锁的效果
		Duel.NegateEffect(ev)
	end
end
