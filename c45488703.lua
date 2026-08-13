--NT8000－SIRIUS
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：连接状态的这张卡不会被战斗破坏。
-- ②：连接怪兽的效果发动的自己·对方回合，以自己以及对方场上的表侧表示卡各1张为对象才能发动。那2张卡破坏。
-- ③：这张卡从场上以外送去墓地的场合，若自己场上有暗属性连接怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册①战斗破坏耐性、②破坏双方场上各1张表侧表示卡、③从墓地特殊召唤并附加离场除外的3个效果，并添加自定义活动计数器用于记录连接怪兽效果的发动次数。
function s.initial_effect(c)
	-- ①：连接状态的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(s.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：连接怪兽的效果发动的自己·对方回合，以自己以及对方场上的表侧表示卡各1张为对象才能发动。那2张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上以外送去墓地的场合，若自己场上有暗属性连接怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 注册自定义活动计数器：记录双方玩家发动连接怪兽效果的次数（通过过滤函数s.chainfilter判断是否为连接怪兽效果），用于②效果的发动条件判断。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数：判断一次效果发动是否计入计数器；当且仅当发动效果为怪兽效果且发动者为连接怪兽时返回false，使该次发动被计入自定义计数器。
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAllTypes(TYPE_LINK+TYPE_MONSTER))
end
-- ①效果的发动条件：这张卡处于连接状态（即作为连接怪兽的连接对象）。只有满足该状态时，这张卡才不会被战斗破坏。
function s.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- ②效果的发动条件：自己或对方在当前回合发动过连接怪兽效果（通过自定义计数器判断任一方计数大于0）。满足该条件时才能发动②效果。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己在本回合发动过连接怪兽效果的计数是否大于0（即自己本回合发动过连接怪兽效果）。
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
		-- 或检查对方在本回合发动过连接怪兽效果的计数是否大于0（即对方本回合发动过连接怪兽效果）。
		or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- ②效果的目标函数：选择自己场上1张表侧表示卡和对方场上1张表侧表示卡作为对象，将两张卡合并后设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：自己场上存在表侧表示卡且对方场上存在表侧表示卡，才能满足‘各选1张作为对象’的发动条件。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家发送选择提示，提示内容为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张表侧表示卡作为对象，并将其登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向操作玩家发送选择提示，提示内容为‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张表侧表示卡作为对象，并将其登记为当前连锁的对象。
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息：本次连锁将破坏2张卡（对象为双方各选出的表侧表示卡g1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②效果处理：取得仍与本次效果关联的对象卡；若正好有2张，则以效果原因将它们破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中与本次效果仍有联系的对象卡集合（对象若已离场则不会包含在内）。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 then
		-- 以效果原因（REASON_EFFECT）破坏对象卡集合g。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤函数：检查自己场上是否存在表侧表示的暗属性连接怪兽（要求暗属性、连接怪兽、表侧表示同时满足）。
function s.spfilter(c)
	return c:IsAllTypes(TYPE_LINK+TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
-- ③效果发动条件：这张卡从场上以外的地方（手牌/卡组/额外卡组等）被送去墓地，即不是从场上被送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果的目标函数：检查发动时条件——自己场上有暗属性连接怪兽、自己有可用怪兽区、这张卡可以被特殊召唤；并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 合法性检查：自己场上存在暗属性连接怪兽（满足s.spfilter的卡至少1张）。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 补充合法性检查：自己场上有可用的怪兽区，并且这张卡能够以表侧表示被特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁的效果将特殊召唤这张卡（c），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果处理：如果这张卡仍与效果关联且不受王家长眠之谷影响，则将其以表侧表示特殊召唤到自己的怪兽区；特殊召唤成功后，为这张卡附加‘从场上离开的场合除外’的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 条件判断：这张卡仍与本次效果关联（未被其他效果移动或离场），且不受王家长眠之谷的影响，允许从墓地特殊召唤。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 将这张卡以表侧表示特殊召唤到自己场上；若特殊召唤成功（返回值>0），则继续执行后续的附加效果处理。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
