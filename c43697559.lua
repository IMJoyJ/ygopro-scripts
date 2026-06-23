--ジェット・ロイド
-- 效果：
-- 这张卡被对方怪兽选作为攻击对象时，这张卡的控制者可以从手卡发动陷阱卡。
function c43697559.initial_effect(c)
	-- 这张卡被对方怪兽选作为攻击对象时，这张卡的控制者可以从手卡发动陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43697559,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetOperation(c43697559.operation)
	c:RegisterEffect(e1)
end
-- 当此卡被选为攻击对象时，使控制者可以在手卡发动陷阱卡
function c43697559.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使控制者可以在手卡发动陷阱卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
