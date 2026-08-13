--プログレオ
-- 效果：
-- 衍生物以外的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡是已连接召唤的场合，把这张卡所连接区1只自己怪兽和这张卡除外，以自己或者对方的墓地1只连接怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
function c52615248.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，需要且仅需要2只“衍生物以外的怪兽”作为连接素材。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,2)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡是已连接召唤的场合，把这张卡所连接区1只自己怪兽和这张卡除外，以自己或者对方的墓地1只连接怪兽为对象才能发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52615248,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,52615248)
	e1:SetCondition(c52615248.spcon)
	e1:SetCost(c52615248.spcost)
	e1:SetTarget(c52615248.sptg)
	e1:SetOperation(c52615248.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡是以连接召唤方式成功出场（召唤类型为连接召唤）时才可发动。
function c52615248.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 代价筛选函数：候选怪兽必须位于这张卡的连接区，且可作为代价除外；同时除外该怪兽和这张卡后，自己场上仍有空余怪兽区用来特殊召唤。
function c52615248.costfilter(c,tp,mc)
	local lg=mc:GetLinkedGroup()
	-- 判断候选怪兽是否在逐行狮的连接区、能否作为代价除外，并确认除外后自己场上仍有空余的怪兽区。
	return lg:IsContains(c) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,Group.FromCards(c,mc))>0
end
-- 代价检测：自己场上存在1只满足代价筛选的连接区怪兽，且逐行狮自身也可作为代价除外。
function c52615248.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在代价检测阶段，检查自己场上（主要怪兽区）是否存在至少1张满足costfilter的怪兽卡，排除逐行狮自身。
	if chk==0 then return Duel.IsExistingMatchingCard(c52615248.costfilter,tp,LOCATION_MZONE,0,1,c,tp,c)
		and c:IsAbleToRemoveAsCost() end
	-- 弹出选择提示，提示玩家选择要作为代价除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1张满足costfilter的怪兽卡作为代价要除外的卡。
	local g=Duel.SelectMatchingCard(tp,c52615248.costfilter,tp,LOCATION_MZONE,0,1,1,c,tp,c)
	g:AddCard(c)
	-- 将选中的代价怪兽（与逐行狮一起）以表侧表示除外，作为发动效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标筛选函数：对象必须是连接怪兽，并且可以被玩家tp通过该效果正常特殊召唤（检查召唤条件与苏生限制）。
function c52615248.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：从双方墓地选择1只满足条件的连接怪兽作为对象，并设置特殊召唤的操作信息。
function c52615248.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c52615248.spfilter(chkc,e,tp) end
	-- 在目标检测阶段，确认双方墓地存在至少1只满足spfilter的连接怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c52615248.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1只连接怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c52615248.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，告知系统本效果将进行特殊召唤，对象为所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将对象怪兽特殊召唤到自己场上，并给其附加离场除外效果。
function c52615248.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡（墓地中的连接怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，则以表侧表示将其特殊召唤（分步特殊召唤中的一步）；成功后继续对其附加离场除外效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1,true)
	end
	-- 完成分步特殊召唤处理，宣告这次特殊召唤成功。
	Duel.SpecialSummonComplete()
end
