--NT8000－SIRIUS
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：连接状态的这张卡不会被战斗破坏。
-- ②：连接怪兽的效果发动的自己·对方回合，以自己以及对方场上的表侧表示卡各1张为对象才能发动。那2张卡破坏。
-- ③：这张卡从场上以外送去墓地的场合，若自己场上有暗属性连接怪兽存在则能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果：①不被战斗破坏、②连接怪兽发动效果时可破坏对方场上卡、③送去墓地时可特殊召唤。
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
	-- 设置一个计数器，用于记录本回合发动的连锁次数，以限制②③效果各只能使用1次。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数，排除连接怪兽的效果发动。
function s.chainfilter(re,tp,cid)
	return not (re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAllTypes(TYPE_LINK+TYPE_MONSTER))
end
-- 效果①的发动条件：此卡处于连接状态。
function s.indcon(e)
	return e:GetHandler():IsLinkState()
end
-- 效果②的发动条件：本回合或对方回合有发动过连锁。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果②的发动条件：本回合有发动过连锁。
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
		-- 效果②的发动条件：对方回合有发动过连锁。
		or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- 效果②的发动时点处理函数，选择破坏对象并设置操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果②的发动时点判断条件：场上存在己方和对方各一张表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择己方场上一张表侧表示卡。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上一张表侧表示卡。
	local g2=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，表示将破坏2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果②的处理函数，执行破坏操作。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁相关的对象卡组。
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()==2 then
		-- 将对象卡组中的卡破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 特殊召唤条件的过滤函数，筛选场上存在的暗属性连接怪兽。
function s.spfilter(c)
	return c:IsAllTypes(TYPE_LINK+TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
-- 效果③的发动条件：此卡不是从场上送去墓地的。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果③的发动时点处理函数，判断是否满足特殊召唤条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果③的发动时点判断条件：己方场上存在暗属性连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 效果③的发动时点判断条件：己方有空场，且此卡可特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的处理函数，执行特殊召唤并设置离开场上的处理。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与效果相关且未受王家长眠之谷影响。
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c)
		-- 执行特殊召唤操作，若成功则注册离开场上的处理效果。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤后设置效果，使此卡从场上离开时被除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
