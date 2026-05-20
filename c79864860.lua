--捕食植物トリフィオヴェルトゥム
-- 效果：
-- 场上的暗属性怪兽×3
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升这张卡以外的有捕食指示物放置的怪兽的原本攻击力的合计数值。
-- ②：这张卡是已融合召唤的场合，对方从额外卡组把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
-- ③：对方场上的怪兽有捕食指示物放置中的场合才能发动。这张卡从墓地守备表示特殊召唤。
function c79864860.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为3只满足过滤条件（场上的暗属性怪兽）的怪兽
	aux.AddFusionProcFunRep(c,c79864860.ffilter,3,true)
	-- ①：这张卡的攻击力上升这张卡以外的有捕食指示物放置的怪兽的原本攻击力的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c79864860.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡是已融合召唤的场合，对方从额外卡组把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79864860,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,79864860)
	e2:SetCondition(c79864860.condition)
	e2:SetTarget(c79864860.target)
	e2:SetOperation(c79864860.operation)
	c:RegisterEffect(e2)
	-- ③：对方场上的怪兽有捕食指示物放置中的场合才能发动。这张卡从墓地守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,79864861)
	e3:SetCondition(c79864860.spcon)
	e3:SetTarget(c79864860.sptg)
	e3:SetOperation(c79864860.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上的暗属性怪兽
function c79864860.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsOnField()
end
-- 过滤条件：表侧表示且放置有捕食指示物的怪兽
function c79864860.atkfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 计算攻击力上升值的回调函数
function c79864860.atkval(e,c)
	-- 获取双方场上除自身以外所有放置有捕食指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c79864860.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)
	local atk=g:GetSum(Card.GetBaseAttack)
	return atk
end
-- 过滤条件：由对方从额外卡组特殊召唤的怪兽
function c79864860.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：这张卡是融合召唤成功，且对方在连锁0（非效果处理中）从额外卡组特殊召唤怪兽之际
function c79864860.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方从额外卡组进行特殊召唤，且当前不在处理连锁中
	return tp~=ep and eg:IsExists(c79864860.cfilter,1,nil,1-tp) and Duel.GetCurrentChain()==0
		and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果②的靶向/发动准备函数：设置无效召唤与破坏的操作信息
function c79864860.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c79864860.cfilter,nil,1-tp)
	-- 设置操作信息：无效对应怪兽的特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置操作信息：破坏对应怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果②的效果处理函数：使特殊召唤无效并破坏那些怪兽
function c79864860.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c79864860.cfilter,nil,1-tp)
	-- 使目标怪兽的特殊召唤无效
	Duel.NegateSummon(g)
	-- 因效果破坏目标怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤条件：表侧表示且放置有捕食指示物的怪兽
function c79864860.spfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 效果③的发动条件：对方场上存在有捕食指示物放置中的怪兽
function c79864860.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只放置有捕食指示物的怪兽
	return Duel.IsExistingMatchingCard(c79864860.spfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果③的靶向/发动准备函数：检查自身是否能特殊召唤并设置操作信息
function c79864860.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理函数：将墓地的这张卡守备表示特殊召唤
function c79864860.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
