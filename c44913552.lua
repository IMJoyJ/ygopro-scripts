--タイム・イーター
-- 效果：
-- 这张卡战斗破坏对方怪兽的场合，下次的对方回合的主要阶段1跳过。
function c44913552.initial_effect(c)
	-- 这张卡战斗破坏对方怪兽的场合，下次的对方回合的主要阶段1跳过。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44913552,0))  --"跳过阶段"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c44913552.skipop)
	c:RegisterEffect(e2)
end
-- 将下次对方回合主要阶段1跳过的效果注册给全局环境
function c44913552.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合的主要阶段1跳过
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_M1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将跳过主要阶段1的效果注册给对方玩家
	Duel.RegisterEffect(e1,tp)
end
