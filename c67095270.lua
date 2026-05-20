--ディメンション・ウォール
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。这次战斗让自己受到的战斗伤害，作为代替由对方承受。
function c67095270.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。这次战斗让自己受到的战斗伤害，作为代替由对方承受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c67095270.condition)
	e1:SetOperation(c67095270.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否满足
function c67095270.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 验证当前回合玩家不是自己，即对方怪兽进行攻击宣言
	return tp~=Duel.GetTurnPlayer()
end
-- 执行卡片发动时的效果处理
function c67095270.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 这次战斗让自己受到的战斗伤害，作为代替由对方承受。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局环境中注册该玩家受到的战斗伤害由对方承受的效果
	Duel.RegisterEffect(e1,tp)
end
