--偉大天狗
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡给与对方玩家战斗伤害的场合，跳过下次的对方回合的战斗阶段。
function c2356994.initial_effect(c)
	-- 为这张卡注册灵魂怪兽的回归效果：在通常召唤成功或反转的回合的结束阶段时，将这张卡返回持有者手卡。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 对应效果原文：“这张卡不能特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 对应效果原文：“这张卡给与对方玩家战斗伤害的场合，跳过下次的对方回合的战斗阶段。”
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2356994,1))  --"跳过战斗阶段"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c2356994.skipcon)
	e4:SetOperation(c2356994.skipop)
	c:RegisterEffect(e4)
end
-- 战斗伤害触发效果的发动条件：受到战斗伤害的玩家（ep）不是这张卡的控制者（tp），即对对方玩家造成了战斗伤害。
function c2356994.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 处理跳过对方下次战斗阶段的操作：创建一个影响对方玩家的“跳过战斗阶段”的永续效果，根据当前回合情况设置持续条件与重置时机，并注册该效果。
function c2356994.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 对应效果原文：“跳过下次的对方回合的战斗阶段。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前是否不是这张卡控制者的回合（即该战斗伤害是否发生在对方回合）。
	if Duel.GetTurnPlayer()~=tp then
		-- 将当前回合数记录到效果e1的Label中，用于后续判断是否已经过了当前回合，从而确保只跳过下一个对方回合的战斗阶段。
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c2356994.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	-- 将创建的“跳过战斗阶段”效果e1注册给控制者tp，使其在满足条件时对对方玩家生效。
	Duel.RegisterEffect(e1,tp)
end
-- “跳过战斗阶段”效果的发动条件：当前回合数不等于记录在Label中的回合数，即不是造成伤害时的那个回合，确保跳过的是后续的对方回合。
function c2356994.bpcon(e)
	-- 判断当前回合数与记录值不同：若当前已不是造成伤害时的那个回合，则条件成立，允许跳过战斗阶段。
	return Duel.GetTurnCount()~=e:GetLabel()
end
