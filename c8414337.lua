--ガスタの風塵
-- 效果：
-- 这张卡发动的回合，自己场上存在的名字带有「薰风」的怪兽的攻击宣言时，对方不能把魔法·陷阱·效果怪兽的效果发动。
function c8414337.initial_effect(c)
	-- 这张卡发动的回合，自己场上存在的名字带有「薰风」的怪兽的攻击宣言时，对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c8414337.condition)
	e1:SetTarget(c8414337.target)
	e1:SetOperation(c8414337.activate)
	c:RegisterEffect(e1)
end
-- 定义卡片发动的条件函数
function c8414337.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 限制只能在自己的回合且战斗阶段结束前（含战斗阶段）发动
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 定义卡片发动的对象选择与合法性检查函数
function c8414337.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
end
-- 定义卡片发动成功时的效果处理函数，注册一个持续到回合结束的全局效果
function c8414337.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上存在的名字带有「薰风」的怪兽的攻击宣言时，对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c8414337.actcon)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制对方发动效果的全局效果注册给发动卡片的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义限制对方发动效果的条件函数
function c8414337.actcon(e)
	-- 检查当前是否为攻击宣言时，且攻击怪兽是名字带有「薰风」的怪兽
	return Duel.CheckEvent(EVENT_ATTACK_ANNOUNCE) and Duel.GetAttacker():IsSetCard(0x10)
end
