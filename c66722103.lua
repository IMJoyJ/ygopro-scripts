--封狼雷坊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方把怪兽的效果发动时，把特殊召唤的这张卡解放才能发动。那个发动无效并破坏。
-- ②：这张卡从场上送去墓地的场合才能发动。从手卡把1只雷族怪兽守备表示特殊召唤。
function c66722103.initial_effect(c)
	-- ①：对方把怪兽的效果发动时，把特殊召唤的这张卡解放才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,66722103)
	e1:SetCondition(c66722103.condition)
	e1:SetCost(c66722103.cost)
	e1:SetTarget(c66722103.target)
	e1:SetOperation(c66722103.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从手卡把1只雷族怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,66722104)
	e2:SetCondition(c66722103.spcon)
	e2:SetTarget(c66722103.sptg)
	e2:SetOperation(c66722103.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数
function c66722103.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方发动的怪兽效果，且该发动可以被无效，同时这张卡没有处于战斗破坏确定状态
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ①效果的代价处理函数
function c66722103.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(c,REASON_COST)
end
-- ①效果的对象与操作信息设置函数
function c66722103.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可以被破坏，则设置当前连锁的操作信息为破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ①效果的效果处理函数
function c66722103.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使发动无效，且该卡在场上（或与效果相关联）
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- ②效果的发动条件判定函数（从场上送去墓地）
function c66722103.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤手卡中可以守备表示特殊召唤的雷族怪兽
function c66722103.spfilter(c,e,tp)
	return c:IsRace(RACE_THUNDER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的对象与操作信息设置函数
function c66722103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手卡中存在至少1只满足特召条件的雷族怪兽
		and Duel.IsExistingMatchingCard(c66722103.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ②效果的效果处理函数
function c66722103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的雷族怪兽
	local g=Duel.SelectMatchingCard(tp,c66722103.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
