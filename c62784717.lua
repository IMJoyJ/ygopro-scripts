--死神の巡遊
-- 效果：
-- 对方回合的准备阶段时进行1次投掷硬币以下效果适用。
-- ●表：对方直到结束阶段时不能召唤·反转召唤。
-- ●里：自己在下次的自己回合不能召唤·反转召唤。
function c62784717.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	c:RegisterEffect(e1)
	-- 对方回合的准备阶段时进行1次投掷硬币以下效果适用。●表：对方直到结束阶段时不能召唤·反转召唤。●里：自己在下次的自己回合不能召唤·反转召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62784717,0))  --"投掷硬币"
	e2:SetCategory(CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c62784717.coincon)
	e2:SetTarget(c62784717.cointg)
	e2:SetOperation(c62784717.coinop)
	c:RegisterEffect(e2)
end
-- 准备阶段投掷硬币效果的发动条件函数
function c62784717.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方（即对方回合的准备阶段）
	return tp~=Duel.GetTurnPlayer()
end
-- 准备阶段投掷硬币效果的发动准备（Target）函数
function c62784717.cointg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁信息，表示该效果包含投掷1次硬币的操作
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 准备阶段投掷硬币效果的执行（Operation）函数
function c62784717.coinop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 进行1次投掷硬币，并获取投掷结果（1为表，0为里）
	local res=Duel.TossCoin(tp,1)
	-- ●表：对方直到结束阶段时不能召唤·反转召唤。●里：自己在下次的自己回合不能召唤·反转召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	if res==0 then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		e1:SetTargetRange(1,0)
		e1:SetCondition(c62784717.limcon)
	else
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetTargetRange(0,1)
	end
	-- 给受影响的玩家注册不能召唤的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 给受影响的玩家注册不能反转召唤的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制自身召唤效果的生效条件函数
function c62784717.limcon(e)
	-- 判定当前回合是否为自己的回合（用于在下次自己的回合限制召唤）
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
