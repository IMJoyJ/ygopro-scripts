--白鱓
-- 效果：
-- ①：这张卡召唤成功的回合，这张卡可以向对方直接攻击。
-- ②：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。
function c32825095.initial_effect(c)
	-- ①：这张卡召唤成功的回合，这张卡可以向对方直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c32825095.sumsuc)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地的特殊召唤成功的场合才能发动。这个回合，这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c32825095.tncon)
	e2:SetOperation(c32825095.tnop)
	c:RegisterEffect(e2)
end
c32825095.treat_itself_tuner=true
-- 这张卡召唤成功时，给这张卡赋予“可以直接攻击”的永续效果，该效果持续到回合结束，且随卡片离场等标准事件重置失效。
function c32825095.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，这张卡可以向对方直接攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 判定这张卡在特殊召唤成功前是否位于墓地，即是否满足“从墓地的特殊召唤成功”这一条件。
function c32825095.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 处理②效果：若这张卡仍与发动后的效果相关联，则给这张卡附加“当作调整使用”的永续效果，持续到回合结束。
function c32825095.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
