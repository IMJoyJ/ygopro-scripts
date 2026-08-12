--ゲート・ブロッカー
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能把其他的自己场上的怪兽作为效果的对象，不能给场上的卡放置指示物。此外，对方的场地魔法卡的效果无效。
function c8102334.initial_effect(c)
	-- 此外，对方的场地魔法卡的效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_SZONE)
	e1:SetTarget(c8102334.distg)
	c:RegisterEffect(e1)
	-- 此外，对方的场地魔法卡的效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c8102334.disop)
	c:RegisterEffect(e2)
	-- 不能给场上的卡放置指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_PLACE_COUNTER)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
	-- 只要这张卡在怪兽区域存在，对方不能把其他的自己场上的怪兽作为效果的对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetTarget(c8102334.tglimit)
	-- 设置不能成为对方卡的效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
end
-- 过滤出场地魔法卡，作为无效效果的对象
function c8102334.distg(e,c)
	return c:IsType(TYPE_FIELD)
end
-- 在连锁处理时，若对方在场地区域发动了场地魔法的效果，则将其效果无效
function c8102334.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发动位置
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if bit.band(tl,LOCATION_FZONE)~=0 and re:IsActiveType(TYPE_FIELD) and 1-tp==rp then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end
-- 过滤出除自身以外的我方场上的怪兽
function c8102334.tglimit(e,c)
	return c~=e:GetHandler()
end
