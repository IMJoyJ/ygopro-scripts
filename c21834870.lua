--天威無双の拳
-- 效果：
-- ①：自己场上有效果怪兽以外的表侧表示怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把效果怪兽以外的1只怪兽特殊召唤。
function c21834870.initial_effect(c)
	-- 效果①：自己场上有效果怪兽以外的表侧表示怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21834870,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c21834870.condition)
	e1:SetTarget(c21834870.target)
	e1:SetOperation(c21834870.operation)
	c:RegisterEffect(e1)
	-- 效果②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把效果怪兽以外的1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21834870,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c21834870.spcon)
	e2:SetTarget(c21834870.sptg)
	e2:SetOperation(c21834870.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在表侧表示且不是效果怪兽的怪兽
function c21834870.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- 效果①的发动条件：场上存在非效果怪兽且发动的卡为怪兽效果或魔法/陷阱卡，且该连锁可以被无效
function c21834870.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只表侧表示且不是效果怪兽的怪兽
	return Duel.IsExistingMatchingCard(c21834870.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 检查当前连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果①的发动时处理，设置将要无效的连锁信息
function c21834870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果①的发动处理，使连锁发动无效
function c21834870.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效
	Duel.NegateActivation(ev)
end
-- 效果②的发动条件：被对方效果破坏且为盖放状态
function c21834870.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数，用于筛选额外卡组中可以特殊召唤的非效果怪兽
function c21834870.spfilter(c,e,tp)
	-- 筛选条件：非效果怪兽且可以特殊召唤，且有足够召唤位置
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果②的发动时处理，设置特殊召唤目标
function c21834870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21834870.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的发动处理，选择并特殊召唤怪兽
function c21834870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只满足条件的怪兽
	local tg=Duel.SelectMatchingCard(tp,c21834870.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if tg:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
