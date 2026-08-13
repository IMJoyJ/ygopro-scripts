--超電導戦機インペリオン・マグナム
-- 效果：
-- 「磁石战士 电磁武神」＋「电磁石战士 电磁狂神」
-- 这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
-- ①：1回合1次，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「磁石战士 电磁武神」「电磁石战士 电磁狂神」各1只从手卡·卡组无视召唤条件特殊召唤。
function c4628897.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：必须使用卡号75347539（磁石战士 电磁武神）与卡号42901635（电磁石战士 电磁狂神）各1只作为融合素材，false、false表示素材不可替换且无特殊调整。
	aux.AddFusionProcCode2(c,75347539,42901635,false,false)
	-- 「磁石战士 电磁武神」＋「电磁石战士 电磁狂神」这张卡用以上记的卡为融合素材的融合召唤才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果的限制判定函数为aux.fuslimit，即这张卡只允许通过融合召唤方式特殊召唤。
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方把怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4628897,0))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c4628897.negcon)
	e2:SetTarget(c4628897.negtg)
	e2:SetOperation(c4628897.negop)
	c:RegisterEffect(e2)
	-- ②：表侧表示的这张卡因对方的效果从场上离开的场合才能发动。「磁石战士 电磁武神」「电磁石战士 电磁狂神」各1只从手卡·卡组无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4628897,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c4628897.spcon)
	e3:SetTarget(c4628897.sptg)
	e3:SetOperation(c4628897.spop)
	c:RegisterEffect(e3)
end
-- 该效果的发动条件：对方发动了怪兽效果或魔法·陷阱卡，且该连锁可以被无效，并且这张卡不是处于战斗破坏确定状态，才能发动。
function c4628897.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==tp or c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 判断对方发动的卡是否为怪兽效果或魔法·陷阱卡的发动，并且当前连锁可以被无效。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
-- 无效并破坏效果发动前的目标处理：无发动代价，准备将对方发动的对象卡设为无效对象，并在合适时追加破坏对象。
function c4628897.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本连锁将处理“使发动无效”的效果，对象为对方发动的卡片（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果对方发动的那张卡可以被破坏且仍与该效果关联，则追加设置“破坏”的操作信息，对象为eg，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理时的操作：先无效对方该卡的发动，若无效成功且对象卡仍与效果关联，则将其破坏。
function c4628897.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动无效是否成功，以及对方发动的卡是否仍与当前效果存在关联。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将eg中对方发动的卡片以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 离场诱发效果的发动条件：这张卡因对方的效果从场上表侧表示离场，且离场原因是对方的卡片效果。
function c4628897.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤候选卡的过滤函数：卡名必须与指定卡号一致，并且可以被无视召唤条件地特殊召唤。
function c4628897.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果的发动条件检查：不存在青眼精灵龙的“不能同时特殊召唤2只以上怪兽”限制，我方主怪兽区空位大于1，且手卡·卡组中同时存在两种所需的磁石战士怪兽可供特殊召唤。
function c4628897.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方主怪兽区可用空格数大于1，以便同时特殊召唤2只怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查手卡·卡组中是否存在1只可以特殊召唤的卡号75347539（磁石战士 电磁武神）。
		and Duel.IsExistingMatchingCard(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,75347539)
		-- 检查手卡·卡组中是否存在1只可以特殊召唤的卡号42901635（电磁石战士 电磁狂神）。
		and Duel.IsExistingMatchingCard(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,42901635) end
	-- 设置操作信息：该效果将进行特殊召唤，预计从手卡·卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤处理时的再次检查：如果青眼精灵龙的效果仍生效或主怪兽区空位不足2个，则终止处理。
function c4628897.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 如果当前主怪兽区可用空格少于2个，则无法同时特殊召唤2只怪兽，直接返回。
		or Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取手卡·卡组中所有可以特殊召唤的卡号75347539（磁石战士 电磁武神）的候选卡组。
	local g1=Duel.GetMatchingGroup(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp,75347539)
	-- 获取手卡·卡组中所有可以特殊召唤的卡号42901635（电磁石战士 电磁狂神）的候选卡组。
	local g2=Duel.GetMatchingGroup(c4628897.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp,42901635)
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 弹出选择提示，让玩家选择要特殊召唤的“磁石战士 电磁武神”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 弹出选择提示，让玩家选择要特殊召唤的“电磁石战士 电磁狂神”。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg2=g2:Select(tp,1,1,nil)
		sg1:Merge(sg2)
		-- 将选中的两只怪兽以表侧攻击表示特殊召唤到持有者场上，无视召唤条件。
		Duel.SpecialSummon(sg1,0,tp,tp,true,false,POS_FACEUP)
	end
end
