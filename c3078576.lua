--八汰烏
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡给与对方战斗伤害的场合发动。下次的对方抽卡阶段跳过。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。
function c3078576.initial_effect(c)
	-- 为这张卡添加灵魂怪兽返回效果：在召唤成功或反转成功的回合的结束阶段，将这张卡回到手卡（对应②效果）。
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤限制效果的判定值设为恒为 false，即任何情况下都不允许这张卡被特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- ①：这张卡给与对方战斗伤害的场合发动。下次的对方抽卡阶段跳过。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3078576,1))  --"跳过下次抽卡阶段"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c3078576.skipcon)
	e4:SetOperation(c3078576.skipop)
	c:RegisterEffect(e4)
end
-- 条件函数：判断受到战斗伤害的玩家 ep 不是效果控制者 tp，即只有给与对方战斗伤害时才发动。
function c3078576.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 处理效果：创建一个持续型场地效果，只影响对方玩家，令对方跳过下一次抽卡阶段，并在对方回合的结束阶段后自动重置。
function c3078576.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方抽卡阶段跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将创建的跳过抽卡阶段效果以 tp 为所有者注册到决斗中，使其持续生效。
	Duel.RegisterEffect(e1,tp)
end
