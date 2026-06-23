--八汰烏
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡给与对方战斗伤害的场合发动。下次的对方抽卡阶段跳过。
-- ②：这张卡召唤·反转的回合的结束阶段发动。这张卡回到手卡。
function c3078576.initial_effect(c)
	-- 为该卡添加在召唤或反转时回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡无法被特殊召唤
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
-- 判断造成战斗伤害的玩家是否为对方
function c3078576.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 创建并注册跳过对方抽卡阶段的效果
function c3078576.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 跳过下次抽卡阶段
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_DP)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
