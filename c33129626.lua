--ケンタウルミナ
-- 效果：
-- 战士族·光属性怪兽＋兽族怪兽
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从自己的手卡·墓地选1只2星以下的怪兽特殊召唤。
-- ②：1回合1次，自己回合对方把陷阱卡发动时才能发动。那个发动无效，那张卡直接盖放。
-- ③：这张卡作为战士族·风属性同调怪兽的同调素材送去墓地的场合才能发动。选场上1只表侧表示怪兽破坏。
function c33129626.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：使此卡能以“战士族·光属性怪兽＋兽族怪兽”各1只为融合素材进行融合召唤（true表示满足素材条件即可，不限定卡名）。
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
-- 融合素材过滤条件1：判定怪兽是否为光属性且战士族。
function c33129626.matfilter1(c)
	return c:IsFusionAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)
end
-- 融合素材过滤条件2：判定怪兽是否为兽族。
function c33129626.matfilter2(c)
	return c:IsRace(RACE_BEAST)
end
-- 定义①效果可特殊召唤的怪兽：等级2以下且当前能够被特殊召唤的怪兽。
function c33129626.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动条件判定：若为发动时点（chk==0），则需要我方怪兽区有空位，且手牌·墓地存在1只以上满足spfilter的怪兽。
function c33129626.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否还有可用空格，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌·墓地是否存在满足spfilter（2星以下、可特殊召唤）的怪兽，至少1只。
		and Duel.IsExistingMatchingCard(c33129626.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：该效果将进行特殊召唤，预计从自己的手牌·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：若有空位，则玩家从自己的手牌·墓地选择1只2星以下怪兽，以表侧攻击表示特殊召唤到场上；选择时受王家长眠之谷影响时，墓地符合条件的怪兽不能选择。
function c33129626.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方怪兽区仍有空位，若无空位则效果处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手牌·墓地选择1只满足spfilter且不受王家长眠之谷影响的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c33129626.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：自己回合、对方发动陷阱卡、该发动可被无效，且此卡未被战斗破坏；满足时才能发动。
function c33129626.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 具体判定：当前回合玩家是自己，且对方发动的卡是陷阱卡，且是发动效果（陷阱卡的发动）。
	return Duel.GetTurnPlayer()==tp and re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 判定该连锁（陷阱卡的发动）是否能够被无效化。
		and Duel.IsChainNegatable(ev)
end
-- ②效果的目标选择：发动时无需选择对象；设置操作信息为无效该陷阱卡发动。
function c33129626.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：该效果将无效当前连锁（eg）的发动，对应无效对象为那张陷阱卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果处理：无效对方陷阱卡的发动；若该卡仍与效果关联且可以盖放，则将其直接里侧盖放到魔法陷阱区，并触发盖放事件。
function c33129626.negop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 执行发动无效；若无效不成功则不再进行后续处理。
	if not Duel.NegateActivation(ev) then return end
	if rc:IsRelateToEffect(re) and rc:IsRelateToEffect(re) and rc:IsCanTurnSet() then
		rc:CancelToGrave()
		-- 将那张陷阱卡变为里侧表示（盖放）。
		Duel.ChangePosition(rc,POS_FACEDOWN)
		-- 触发该卡被盖放的事件（EVENT_SSET），使其他卡可以对此进行时点响应。
		Duel.RaiseEvent(rc,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end
-- ③效果的发动条件：此卡作为同调素材被送去墓地后位于墓地，且同调召唤出的怪兽是战士族·风属性。
function c33129626.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO and c:GetReasonCard():IsAttribute(ATTRIBUTE_WIND) and c:GetReasonCard():IsRace(RACE_WARRIOR)
end
-- ③效果的目标选择：发动时确认场上存在表侧表示怪兽，并设置破坏操作信息（不取对象，处理时选择）。
function c33129626.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只表侧表示怪兽，作为可破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取当前场上所有表侧表示怪兽，组成集合，用于设置操作信息。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：该效果将破坏场上1只表侧表示怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：从场上选择1只表侧表示怪兽并破坏。
function c33129626.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽。
	local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		-- 高亮显示被选择的卡，作为对象确认动画。
		Duel.HintSelection(g)
		-- 将选择的怪兽以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
