--閉ザサレシ世界ノ冥神
-- 效果：
-- 效果怪兽4只以上
-- 这张卡连接召唤的场合，对方场上1只怪兽也能作为连接素材。
-- ①：这张卡连接召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
-- ②：连接召唤的这张卡不受除以这张卡为对象的效果以外的对方发动的效果影响。
-- ③：1回合1次，包含从墓地把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效。
function c98127546.initial_effect(c)
	-- 设置连接召唤手续：需要4只以上的效果怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),4)
	c:EnableReviveLimit()
	-- 这张卡连接召唤的场合，对方场上1只怪兽也能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_EXTRA_LINK_MATERIAL)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(c98127546.matval)
	c:RegisterEffect(e1)
	-- ①：这张卡连接召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98127546,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c98127546.discon)
	e2:SetTarget(c98127546.distg)
	e2:SetOperation(c98127546.disop)
	c:RegisterEffect(e2)
	-- ②：连接召唤的这张卡不受除以这张卡为对象的效果以外的对方发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetCondition(c98127546.immcon)
	e3:SetValue(c98127546.efilter)
	c:RegisterEffect(e3)
	-- ③：1回合1次，包含从墓地把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(98127546,1))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c98127546.negcon)
	e4:SetTarget(c98127546.negtg)
	e4:SetOperation(c98127546.negop)
	c:RegisterEffect(e4)
end
function c98127546.is_external_exmat(c,lc,mg,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in ipairs(le) do
		local h=te:GetHandler()
		-- external = any ex-mat effect not created by 閉ザサレシ世界ノ冥神 herself
		if h and not h:IsCode(98127546) then
			local f=te:GetValue()
			if f then
				local related,valid=f(te,lc,mg,c,tp)
				if related and valid~=false then
					return true
				end
			end
		end
	end
	return false
end
function c98127546.is_goddess_opp(mc,lc,mg,tp)
	return mc:IsControler(1-tp) and not c98127546.is_external_exmat(mc,lc,mg,tp)
end
-- 限制对方场上最多只能有1只怪兽作为此卡的连接素材。
function c98127546.matval(e,lc,mg,c,tp)
	-- Only while Link Summoning this card
	if e:GetHandler()~=lc then return false,nil end
	-- 閉ザサレシ世界ノ冥神 only concerns opponent monsters
	if not c:IsControler(1-tp) then return false,nil end
	-- related=true
	if not mg then
		return true,true
	end
	-- If this opponent monster is already permitted by some OTHER ex-mat effect,
	-- 閉ザサレシ世界ノ冥神 should not block it and should not count it as "her 1".
	if c98127546.is_external_exmat(c,lc,mg,tp) then
		return true,true
	end
	-- Otherwise this would be "via 閉ザサレシ世界ノ冥神": allow at most one such opponent monster.
	if mg:IsExists(c98127546.is_goddess_opp,1,c,lc,mg,tp) then
		return true,false
	end
	return true,true
end
-- 检查此卡是否是通过连接召唤成功特殊召唤，作为效果①的发动条件。
function c98127546.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的发动准备：检查对方场上是否存在可无效的表侧表示怪兽，并设置无效效果的操作信息。
function c98127546.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查对方场上是否存在可以被无效化效果的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以被无效化效果的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果无效的操作信息，包含目标怪兽组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果①的处理：获取对方场上所有表侧表示怪兽，并注册使其效果无效的永续效果。
function c98127546.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有可以被无效化效果的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标怪兽当前正在处理的连锁效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 对方场上的全部表侧表示怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 检查此卡是否为连接召唤成功，作为不受影响效果的适用条件。
function c98127546.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤不受影响的效果：必须是对方发动的、且不以这张卡为对象的效果。
function c98127546.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁中被选为对象的卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
-- 过滤条件：检查卡片是否是墓地中的怪兽卡。
function c98127546.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动条件：对方发动了包含从墓地特殊召唤怪兽效果的卡片或效果。
function c98127546.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方发动的效果的操作信息，以检查是否包含特殊召唤。
	local ex,g,gc,dp,dv=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	-- 检查该连锁是否可以被无效，且该效果是由对方玩家发动的。
	return Duel.IsChainNegatable(ev) and rp==1-tp
		and (ex and (dv&LOCATION_GRAVE==LOCATION_GRAVE or g and g:IsExists(c98127546.cfilter,1,nil)) or re:IsHasCategory(CATEGORY_GRAVE_SPSUMMON))
end
-- 效果③的发动准备：设置无效发动的操作信息。
function c98127546.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果将无效该连锁的发动。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果③的处理：使该发动的效果无效。
function c98127546.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的发动。
	Duel.NegateActivation(ev)
end
