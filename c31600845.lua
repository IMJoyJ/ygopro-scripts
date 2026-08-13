--恐楽園の死配人 ＜Arlechino＞
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「惊乐」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「惊乐家族脸」加入手卡。
-- ②：对方回合，以场上1只其他的效果怪兽为对象才能发动。这张卡回到持有者卡组，从卡组把1只「惊乐园的支配人 ＜∀丑角＞」特殊召唤。那之后，作为对象的怪兽的攻击力变成0。
function c31600845.initial_effect(c)
	-- ①：自己场上有「惊乐」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「惊乐家族脸」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31600845)
	e1:SetCondition(c31600845.spcon)
	e1:SetTarget(c31600845.sptg)
	e1:SetOperation(c31600845.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以场上1只其他的效果怪兽为对象才能发动。这张卡回到持有者卡组，从卡组把1只「惊乐园的支配人 ＜∀丑角＞」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31600845,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,0x21e0)
	e2:SetCountLimit(1,31600846)
	e2:SetCondition(c31600845.dhcon)
	e2:SetTarget(c31600845.dhtg)
	e2:SetOperation(c31600845.dhop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件函数：检查自己场上是否存在表侧表示且属于「惊乐」字段的怪兽。
function c31600845.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示且字段为「惊乐」的怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x15b)
end
-- ①效果的发动时点判定函数：确认这张卡能否特殊召唤、自己场上是否有怪兽区域空位。
function c31600845.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时检查自己场上是否存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本次效果处理将特殊召唤这张卡（目标就是这张卡本身）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 检索/加入手卡的过滤条件：对象必须是「惊乐家族脸」（卡号20989253）且能够加入手卡。
function c31600845.thfilter(c)
	return c:IsCode(20989253) and c:IsAbleToHand()
end
-- ①效果的处理：先从手卡特殊召唤这张卡，成功后可能再从自己的卡组·墓地选1张「惊乐家族脸」加入手卡。
function c31600845.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡表侧攻击表示特殊召唤；如果特殊召唤失败，则结束后续处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 从自己的卡组和墓地中筛选出满足条件的「惊乐家族脸」，并通过王家长眠之谷效果过滤，得到候选集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c31600845.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 当存在可检索的候选卡时，询问玩家是否要将「惊乐家族脸」加入手卡。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(31600845,0)) then  --"是否把「惊乐家族脸」加入手卡？"
		-- 中断当前效果处理，使后续的检索加入手卡动作作为不同时处理，以调整时点。
		Duel.BreakEffect()
		-- 向玩家显示选择提示，要求选择要加入手卡的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tag=g:Select(tp,1,1,nil)
		-- 将选中的「惊乐家族脸」加入持有者手卡。
		Duel.SendtoHand(tag,nil,REASON_EFFECT)
		-- 向对方玩家展示这次加入手卡的卡。
		Duel.ConfirmCards(1-tp,tag)
	end
end
-- ②效果的发动条件函数：必须是对方回合，且满足伤害步骤内仅伤害计算前可发动的限制。
function c31600845.dhcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合，并通过aux.dscon限制伤害步骤内只能在伤害计算前发动。
	return Duel.GetTurnPlayer()==1-tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 对象筛选条件：表侧表示的效果怪兽，且当前攻击力大于0。
function c31600845.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:GetAttack()>0
end
-- 特殊召唤候选筛选条件：卡为「惊乐园的支配人 ＜∀丑角＞」且可以被特殊召唤。
function c31600845.spfilter(c,e,tp)
	return c:IsCode(94821366) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动时判定与选择：确认本卡能回卡组、有可特殊召唤的替换怪兽且场上存在可选对象，然后选择1只其他表侧效果怪兽为对象。
function c31600845.dhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and c31600845.xfilter(chkc) end
	-- 发动时确认这张卡可以回到卡组，并且这张卡离开后自己场上仍有可用的怪兽区域。
	if chk==0 then return c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		-- 确认场上存在1只满足条件且不是这张卡自身的表侧效果怪兽，可以作为效果对象。
		and Duel.IsExistingTarget(c31600845.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
		-- 确认卡组中至少存在1只可以特殊召唤的「惊乐园的支配人 ＜∀丑角＞」。
		and Duel.IsExistingMatchingCard(c31600845.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从场上选择1只满足条件的表侧效果怪兽（不能选择这张卡自身）作为效果对象。
	Duel.SelectTarget(tp,c31600845.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 登记操作信息：将要从卡组特殊召唤1只怪兽；由于对象在处理时才确定，目标暂设为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 登记操作信息：这张卡将回到持有者卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- ②效果处理：先把这张卡送回持有者卡组并洗牌，成功后再从卡组选择1只「惊乐园的支配人 ＜∀丑角＞」特殊召唤；之后（见后续代码）将对象怪兽攻击力变成0。
function c31600845.dhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 如果这张卡已与效果失去联系，或将其送回卡组洗牌失败，或该卡不在卡组中，则效果处理终止。
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or c:GetLocation()~=LOCATION_DECK then return end
	-- 从卡组筛选出所有可以特殊召唤的「惊乐园的支配人 ＜∀丑角＞」作为候选。
	local g=Duel.GetMatchingGroup(c31600845.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的怪兽表侧表示特殊召唤到自己场上；若特殊召唤失败，则不再进行后续的攻击力变更。
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0
		or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 中断当前效果，使后续的攻击力变成0处理作为不同时处理，以调整时点。
	Duel.BreakEffect()
	-- 那之后，作为对象的怪兽的攻击力变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end
