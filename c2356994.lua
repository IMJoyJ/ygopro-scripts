--偉大天狗
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡给与对方玩家战斗伤害的场合，跳过下次的对方回合的战斗阶段。
function c2356994.initial_effect(c)
	-- 为该卡添加在召唤或反转时结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡给与对方玩家战斗伤害的场合，跳过下次的对方回合的战斗阶段。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(2356994,1))  --"跳过战斗阶段"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c2356994.skipcon)
	e4:SetOperation(c2356994.skipop)
	c:RegisterEffect(e4)
end
-- 触发条件：造成战斗伤害的玩家不是自己
function c2356994.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果操作：创建一个跳过对方战斗阶段的效果并注册
function c2356994.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个影响对方玩家的跳过战斗阶段效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SKIP_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	-- 判断当前回合玩家是否不是效果发动者
	if Duel.GetTurnPlayer()~=tp then
		-- 记录当前回合数用于后续判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c2356994.bpcon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	-- 将效果注册给对应玩家
	Duel.RegisterEffect(e1,tp)
end
-- 跳过战斗阶段效果的条件函数
function c2356994.bpcon(e)
	-- 判断当前回合数是否与记录的回合数不同
	return Duel.GetTurnCount()~=e:GetLabel()
end
