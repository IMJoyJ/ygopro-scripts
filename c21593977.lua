--処刑人－マキュラ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从怪兽区域送去墓地的场合才能发动。这个回合只有1次，自己可以把陷阱卡从手卡发动。
function c21593977.initial_effect(c)
	-- 效果原文内容：①：这张卡从怪兽区域送去墓地的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,21593977)
	e1:SetCondition(c21593977.condition)
	e1:SetOperation(c21593977.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断这张卡是否从怪兽区域被送去墓地
function c21593977.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 规则层面作用：创建一个让玩家可以在手卡发动陷阱卡的效果
function c21593977.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果原文内容：这个回合只有1次，自己可以把陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21593977,0))  --"适用「处刑人-摩休罗」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：将效果注册给玩家，使玩家在结束阶段前可以发动手卡陷阱
	Duel.RegisterEffect(e1,tp)
end
