--天威無双の拳
-- 效果：
-- ①：自己场上有效果怪兽以外的表侧表示怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把效果怪兽以外的1只怪兽特殊召唤。
function c21834870.initial_effect(c)
	-- ①：自己场上有效果怪兽以外的表侧表示怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21834870,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c21834870.condition)
	e1:SetTarget(c21834870.target)
	e1:SetOperation(c21834870.operation)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的效果破坏的场合才能发动。从额外卡组把效果怪兽以外的1只怪兽特殊召唤。
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
-- 过滤条件：卡为表侧表示且不是效果怪兽（即效果怪兽以外的表侧表示怪兽）。
function c21834870.cfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_EFFECT)
end
-- ①的发动条件判定：自己场上存在表侧表示的效果怪兽以外的怪兽，且当前连锁为怪兽效果或魔法·陷阱卡发动，且该发动可被无效。
function c21834870.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区是否存在至少1张表侧表示且不是效果怪兽的怪兽。
	return Duel.IsExistingMatchingCard(c21834870.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 检查当前连锁的发动是否可被无效（满足‘那个发动无效’的前提）。
		and Duel.IsChainNegatable(ev)
end
-- ①的发动时点处理：无需选择对象，满足条件即可发动；设置将当前连锁的发动无效的操作信息。
function c21834870.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次操作信息：使当前连锁（eg）的发动无效，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①的发动无效处理：使当前连锁的发动无效。
function c21834870.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效发动操作，使连锁ev对应的效果·魔法·陷阱卡的发动无效。
	Duel.NegateActivation(ev)
end
-- ②的发动条件判定：此卡以里侧表示在场上被对方的效果破坏，且破坏前由自己控制、位于场上。
function c21834870.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 定义特殊召唤候选卡的过滤条件：不是效果怪兽、可以被特殊召唤、且当前有可供额外卡组怪兽出场的空格。
function c21834870.spfilter(c,e,tp)
	-- 判断候选卡不是效果怪兽、满足特殊召唤条件，且玩家tp有可用区域容纳额外卡组的怪兽。
	return not c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②的发动时点处理：检查额外卡组是否存在满足特殊召唤条件的非效果怪兽；设置特殊召唤操作信息。
function c21834870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查额外卡组是否有至少1只满足spfilter条件的非效果怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21834870.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从玩家tp的额外卡组特殊召唤1只怪兽（具体怪兽在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②的效果处理：从额外卡组选择1只符合条件的非效果怪兽，正面表示特殊召唤到自己场上。
function c21834870.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1张满足条件的非效果怪兽。
	local tg=Duel.SelectMatchingCard(tp,c21834870.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if tg:GetCount()>0 then
		-- 将选择的怪兽以正面表示特殊召唤到玩家自己场上。
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
