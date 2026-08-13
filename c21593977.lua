--処刑人－マキュラ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡从怪兽区域送去墓地的场合才能发动。这个回合只有1次，自己可以把陷阱卡从手卡发动。
function c21593977.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡从怪兽区域送去墓地的场合才能发动。这个回合只有1次，自己可以把陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,21593977)
	e1:SetCondition(c21593977.condition)
	e1:SetOperation(c21593977.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查触发效果的这张卡在送去墓地之前是否位于怪兽区域，以确认是否符合“从怪兽区域送去墓地”的发动条件。
function c21593977.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果处理：创建一个持续到结束阶段的场上永续效果，使当前玩家tp可以从手卡发动陷阱卡；该效果限定本回合只能适用1次，并设置对应的效果描述。
function c21593977.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合只有1次，自己可以把陷阱卡从手卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21593977,0))  --"适用「处刑人-摩休罗」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的“自己可以从手卡发动陷阱卡”的场上永续效果注册到当前玩家tp，使该效果在本回合剩余时间内实际生效。
	Duel.RegisterEffect(e1,tp)
end
