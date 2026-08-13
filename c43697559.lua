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
-- 当这张卡被对方怪兽选为攻击对象时，给其控制者附加一个持续效果：该玩家在本连锁中可以从手卡发动陷阱卡，连锁结束后该效果重置。
function c43697559.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的控制者可以从手卡发动陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetReset(RESET_CHAIN)
	-- 将上述“手牌陷阱卡可发动”的持续效果注册给当前玩家tp，使其在本次连锁处理期间生效。
	Duel.RegisterEffect(e1,tp)
end
