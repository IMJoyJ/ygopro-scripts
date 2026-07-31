--捕食植物トリフィオヴェルトゥム
-- 效果：
-- 场上的暗属性怪兽×3
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的攻击力上升这张卡以外的有捕食指示物放置的怪兽的原本攻击力的合计数值。
-- ②：这张卡是已融合召唤的场合，对方从额外卡组把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。
-- ③：对方场上的怪兽有捕食指示物放置中的场合才能发动。这张卡从墓地守备表示特殊召唤。
function c79864860.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：场上的暗属性怪兽3只
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
c79864860.mentioned_counter={
	[0x1041]=true,
}
-- 融合素材过滤条件：场上的暗属性怪兽
function c79864860.ffilter(c)
	return c:IsFusionAttribute(ATTRIBUTE_DARK) and c:IsOnField()
end
-- 攻击力上升计算的过滤条件：表侧表示且放置有捕食指示物的怪兽
function c79864860.atkfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- 攻击力上升数值计算：此卡以外场上有捕食指示物放置的怪兽原本攻击力合计
function c79864860.atkval(e,c)
	-- 获取场上此卡以外所有放置有捕食指示物的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c79864860.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)
	local atk=g:GetSum(Card.GetBaseAttack)
	return atk
end
-- 特殊召唤无效过滤条件：对方从额外卡组特殊召唤的怪兽
function c79864860.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- ②效果发动条件：此卡是已融合召唤，且对方从额外卡组把怪兽特殊召唤之际（不在连锁处理中）
function c79864860.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方从额外卡组特殊召唤怪兽之际且当前连锁数为0
	return tp~=ep and eg:IsExists(c79864860.cfilter,1,nil,1-tp) and Duel.GetCurrentChain()==0
		and e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ②效果发动准备：设置无效特殊召唤和破坏相关怪兽的操作信息
function c79864860.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c79864860.cfilter,nil,1-tp)
	-- 设置连锁操作信息：无效特殊召唤的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：破坏被无效特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：使对方从额外卡组的特殊召唤无效，并将那些怪兽破坏
function c79864860.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c79864860.cfilter,nil,1-tp)
	-- 无效目标的特殊召唤
	Duel.NegateSummon(g)
	-- 破坏那些特殊召唤被无效的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
-- 墓地特召条件过滤：对方场上表侧表示且有捕食指示物放置的怪兽
function c79864860.spfilter(c)
	return c:IsFaceup() and c:GetCounter(0x1041)>0
end
-- ③效果发动条件：对方场上有放置捕食指示物的怪兽存在
function c79864860.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在放置有捕食指示物的怪兽
	return Duel.IsExistingMatchingCard(c79864860.spfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- ③效果发动准备检查：己方怪兽区是否有空位且此卡能否守备表示特殊召唤
function c79864860.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息：从墓地特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：将墓地的此卡表侧守备表示特殊召唤
function c79864860.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
