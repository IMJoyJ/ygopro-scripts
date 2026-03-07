--ケンタウルミナ
-- 效果：
-- 战士族·光属性怪兽＋兽族怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己的手卡·墓地选1只2星以下的怪兽特殊召唤。
-- ②：1回合1次，自己回合对方把陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。
-- ③：这张卡作为战士族·风属性同调怪兽的同调素材送去墓地的场合才能发动。选场上1只表侧表示怪兽破坏。
function c33129626.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用满足条件的光属性战士族怪兽和兽族怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,c33129626.matfilter1,c33129626.matfilter2,true)
	-- ①：自己主要阶段才能发动。从自己的手卡·墓地选1只2星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33129626,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33129626)
	e1:SetTarget(c33129626.sptg)
	e1:SetOperation(c33129626.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己回合对方把陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33129626,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c33129626.negcon)
	e2:SetTarget(c33129626.negtg)
	e2:SetOperation(c33129626.negop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为战士族·风属性同调怪兽的同调素材送去墓地的场合才能发动。选场上1只表侧表示怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33129626,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,33129627)
	e3:SetCondition(c33129626.descon)
	e3:SetTarget(c33129626.destg)
	e3:SetOperation(c33129626.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，判断怪兽是否为光属性战士族
function c33129626.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
end
-- 过滤函数，判断怪兽是否为兽族
function c33129626.matfilter2(c)
	return c:IsRace(RACE_BEAST)
end
-- 过滤函数，判断怪兽是否为2星以下且可特殊召唤
function c33129626.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的处理函数，检查是否满足发动条件
function c33129626.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c33129626.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果发动时的操作信息，表示将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动时的处理函数，执行特殊召唤操作
function c33129626.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33129626.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动时的处理函数，判断是否满足发动条件
function c33129626.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断对方是否在自己的回合发动了陷阱卡
	return Duel.GetTurnPlayer()==tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 判断该连锁是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果发动时的处理函数，设置操作信息
function c33129626.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果发动时的操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果发动时的处理函数，执行无效和盖放操作
function c33129626.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 使连锁发动无效
	if not Duel.NegateActivation(ev) then return end
	if rc:IsRelateToEffect(re) and rc:IsRelateToEffect(re) and rc:IsCanTurnSet() then
		rc:CancelToGrave()
		-- 将盖放的陷阱卡变为里侧表示
		Duel.ChangePosition(rc,POS_FACEDOWN)
		-- 触发陷阱卡盖放的时点事件
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
-- 效果发动时的处理函数，判断是否满足发动条件
function c33129626.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND) and c:GetReasonCard():IsRace(RACE_WARRIOR)
end
-- 效果发动时的处理函数，设置操作信息
function c33129626.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置效果发动时的操作信息，表示将破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理函数，执行破坏操作
function c33129626.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧表示的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 显示被选中的怪兽
		Duel.HintSelection(g)
		-- 将选中的怪兽破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
