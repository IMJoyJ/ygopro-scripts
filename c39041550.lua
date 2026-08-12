--騎甲虫スケイル・ボム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有昆虫族怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：对方把场上的怪兽的效果发动时，把自己场上1只昆虫族怪兽解放才能发动。那只怪兽破坏。
function c39041550.initial_effect(c)
	-- ①：自己场上有昆虫族怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39041550,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,39041550)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c39041550.spcon)
	e1:SetTarget(c39041550.sptg)
	e1:SetOperation(c39041550.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：对方把场上的怪兽的效果发动时，把自己场上1只昆虫族怪兽解放才能发动。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,39041551)
	e3:SetCondition(c39041550.condition)
	e3:SetCost(c39041550.cost)
	e3:SetTarget(c39041550.target)
	e3:SetOperation(c39041550.operation)
	c:RegisterEffect(e3)
end
-- 过滤场上正面表示的昆虫族怪兽
function c39041550.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsControler(tp)
end
-- 判断是否有满足条件的昆虫族怪兽
function c39041550.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c39041550.filter,1,nil,tp)
end
-- 判断是否可以特殊召唤
function c39041550.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c39041550.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为对方怪兽效果发动
function c39041550.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	return tc:IsControler(1-tp) and tc:IsOnField() and tc:IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤自己场上的昆虫族怪兽
function c39041550.cfilter(c,tp)
	return c:IsRace(RACE_INSECT) and (c:IsControler(tp) or c:IsFaceup())
end
-- 设置解放怪兽作为cost的处理
function c39041550.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以解放满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c39041550.cfilter,1,re:GetHandler(),tp) end
	-- 选择要解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,c39041550.cfilter,1,1,re:GetHandler(),tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 设置破坏操作信息
function c39041550.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 执行破坏操作
function c39041550.operation(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 将目标怪兽破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
