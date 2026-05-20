--究極地縛神
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：场上有通常召唤的「地缚神」怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
function c70109009.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：场上有通常召唤的「地缚神」怪兽存在的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70109009,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,70109009)
	e2:SetCondition(c70109009.descon)
	e2:SetTarget(c70109009.destg)
	e2:SetOperation(c70109009.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的通常召唤的「地缚神」怪兽
function c70109009.cfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_NORMAL) and c:IsSetCard(0x1021)
end
-- 效果发动条件：场上有通常召唤的「地缚神」怪兽存在
function c70109009.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c70109009.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 效果发动靶向（Target）：检查并选择场上1只表侧表示怪兽作为对象，并设置破坏操作信息
function c70109009.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理（Operation）：获取对象怪兽，若其仍适用则将其破坏
function c70109009.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏该怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
