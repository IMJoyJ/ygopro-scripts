--陽動作戦
-- 效果：
-- 这个回合，双方不能向里侧表示怪兽攻击。
function c68170903.initial_effect(c)
	-- 这个回合，双方不能向里侧表示怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	-- 设置效果的发动条件为：当前处于可以进行战斗相关操作的时点或阶段
	e1:SetCondition(aux.bpcon)
	e1:SetOperation(c68170903.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理：注册一个持续到回合结束的全局效果，限制双方的攻击对象
function c68170903.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，双方不能向里侧表示怪兽攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetValue(c68170903.atlimit)
	e1:SetReset(RESET_PHASE+PHASE_END,1)
	-- 将该限制攻击的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 定义不能被选择为攻击对象的怪兽条件：该怪兽处于里侧表示
function c68170903.atlimit(e,c)
	return c:IsFacedown()
end
