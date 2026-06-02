--閉ザサレシ世界ノ冥神
-- 效果：
-- 效果怪兽4只以上
-- 这张卡连接召唤的场合，对方场上1只怪兽也能作为连接素材。
-- ①：这张卡连接召唤的场合才能发动。对方场上的全部表侧表示怪兽的效果无效化。
-- ②：连接召唤的这张卡不受除以这张卡为对象的效果以外的对方发动的效果影响。
-- ③：1回合1次，包含从墓地把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果由对方发动时才能发动。那个发动无效。
function c98127546.initial_effect(c)
	-- 添加连接召唤手续：效果怪兽4只以上
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
-- 检查除了本卡以外是否还有其他能将特定卡片当作连接素材的效果
function c98127546.is_external_exmat(c,lc,mg,tp)
	local le={c:IsHasEffect(EFFECT_EXTRA_LINK_MATERIAL,tp)}
	for _,te in ipairs(le) do
		local h=te:GetHandler()
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
-- 过滤并判断指定的卡是否是对方控制的怪兽，且没有被其他效果允许作为连接素材
function c98127546.is_goddess_opp(mc,lc,mg,tp)
	return mc:IsControler(1-tp) and not c98127546.is_external_exmat(mc,lc,mg,tp)
end
-- 判断对方怪兽是否能作为这只怪兽的连接召唤素材，限制最多只能使用对方场上的1只怪兽
function c98127546.matval(e,lc,mg,c,tp)
	if e:GetHandler()~=lc then return false,nil end
	if not c:IsControler(1-tp) then return false,nil end
	if not mg then
		return true,true
	end
	if c98127546.is_external_exmat(c,lc,mg,tp) then
		return true,true
	end
	if mg:IsExists(c98127546.is_goddess_opp,1,c,lc,mg,tp) then
		return true,false
	end
	return true,true
end
-- 效果①的发动条件：此卡连接召唤成功
function c98127546.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的发动判定与效果处理目标设置
function c98127546.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时判定对方场上是否有可以被无效效果的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示且未被无效的效果怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理的分类为效果无效，并将目标卡片组及数量写入操作信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- 效果①的效果处理函数：使对方场上全部表侧表示怪兽的效果无效化
function c98127546.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足无效化条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使和目标怪兽相关的连锁都无效化
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
-- 效果②的适用条件：自身是连接召唤成功过而存在的
function c98127546.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果②的免疫过滤器：判定对方发动的效果是否不以这张卡为对象
function c98127546.efilter(e,te)
	if te:GetOwnerPlayer()==e:GetHandlerPlayer() or not te:IsActivated() then return false end
	if not te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	-- 获取当前连锁中该效果指定的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(e:GetHandler())
end
-- 过滤函数：用于判定是否是墓地中的怪兽卡
function c98127546.cfilter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动条件：对方发动了包含从墓地把怪兽特殊召唤效果的卡的效果
function c98127546.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发连锁效果的特殊召唤操作信息
	local ex,g,gc,dp,dv=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	-- 判定该连锁是否可以被无效，且该效果是由对方玩家发动的
	return Duel.IsChainNegatable(ev) and rp==1-tp
		and (ex and (dv&LOCATION_GRAVE==LOCATION_GRAVE or g and g:IsExists(c98127546.cfilter,1,nil)) or re:IsHasCategory(CATEGORY_GRAVE_SPSUMMON))
end
-- 效果③的发动判定与效果处理目标设置
function c98127546.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的分类为发动无效，并将被无效的连锁卡片组写入操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果③的效果处理函数：使包含从墓地特殊召唤效果的发动无效
function c98127546.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标连锁的发动无效
	Duel.NegateActivation(ev)
end
