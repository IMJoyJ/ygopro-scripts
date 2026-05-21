--瓶亀
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次「强欲之瓶」发动从自己卡组抽1张卡。
function c96287685.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，每次「强欲之瓶」发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c96287685.regop)
	c:RegisterEffect(e1)
	-- 从自己卡组抽1张卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c96287685.drawop)
	c:RegisterEffect(e2)
end
-- 在连锁开始发动时，若发动的卡是「强欲之瓶」，则为这张卡注册一个在连锁结束时重置的标识
function c96287685.regop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(83968380) then
		e:GetHandler():RegisterFlagEffect(96287685,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	end
end
-- 在连锁处理时，若这张卡存有对应的标识且当前处理的连锁是「强欲之瓶」，则执行抽卡效果
function c96287685.drawop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(96287685)~=0 and re:GetHandler():IsCode(83968380) then
		-- 让玩家因效果从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
