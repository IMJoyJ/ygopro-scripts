--デス・デーモン・ドラゴン
-- 效果：
-- 「巨龙」＋「下位恶魔」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：只要这张卡在怪兽区域存在，反转怪兽的效果无效化。
-- ②：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
function c66235877.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置「巨龙」与「下位恶魔」为融合素材，且不能使用融合代替怪兽
	aux.AddFusionProcCode2(c,93220472,16475472,false,false)
	-- ①：只要这张卡在怪兽区域存在，反转怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(c66235877.distg)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，反转怪兽的效果无效化。 / ②：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c66235877.disop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e3:SetTarget(c66235877.distg2)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡为对象的陷阱卡的效果无效化并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c66235877.distg2)
	c:RegisterEffect(e4)
end
-- 确定无效的目标为反转怪兽
function c66235877.distg(e,c)
	return c:IsType(TYPE_FLIP)
end
-- 在连锁处理时，无效化反转怪兽发动的效果，以及以这张卡为对象的陷阱卡的效果
function c66235877.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动效果的是反转怪兽，则使该效果无效
	if re:IsActiveType(TYPE_FLIP) then Duel.NegateEffect(ev) end
	if e:GetHandler():IsRelateToEffect(re)
		and re:IsActiveType(TYPE_TRAP) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取当前处理的连锁的对象卡片组
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:IsContains(e:GetHandler()) then
			-- 使该连锁的效果无效
			Duel.NegateEffect(ev)
		end
	end
end
-- 确定目标为以这张卡为对象的陷阱卡
function c66235877.distg2(e,c)
	return c:GetCardTargetCount()>0 and c:IsType(TYPE_TRAP)
		and c:GetCardTarget():IsContains(e:GetHandler())
end
