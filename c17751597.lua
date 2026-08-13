--烙印断罪
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时才能发动。需以「阿不思的落胤」为融合素材的融合怪兽从自己场上的表侧表示怪兽之中选1只或者从自己墓地选2只回到额外卡组，那个发动无效并破坏。
-- ②：把墓地的这张卡除外，以「烙印断罪」以外的自己墓地1张「烙印」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c17751597.initial_effect(c)
	-- 记录这张卡（烙印断罪）的卡名列表中包含卡号68468459（阿不思的落胤），使本卡被视为记载有该卡名，用于后续融合素材相关判定。
	aux.AddCodeList(c,68468459)
	-- ①：包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时才能发动。需以「阿不思的落胤」为融合素材的融合怪兽从自己场上的表侧表示怪兽之中选1只或者从自己墓地选2只回到额外卡组，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,17751597)
	e1:SetCondition(c17751597.condition)
	e1:SetTarget(c17751597.target)
	e1:SetOperation(c17751597.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「烙印断罪」以外的自己墓地1张「烙印」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,17751597)
	-- 设置效果②的发动代价为把墓地的这张卡除外，即必须将自身除外才能发动。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17751597.thtg)
	e2:SetOperation(c17751597.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前连锁可以被无效，且被连锁发动的是包含特殊召唤效果的怪兽效果或魔法·陷阱卡的发动；只有满足这些条件时效果才可发动。
function c17751597.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁是否可被无效，若不可无效则不能发动无效类效果，条件不成立。
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
-- 定义从场上选择融合怪兽的筛选条件：表侧表示、融合怪兽、卡名记载有「阿不思的落胤」作为融合素材、且能够返回额外卡组。
function c17751597.filter1(c)
	-- 判断怪兽是否为表侧表示的融合怪兽，且是以「阿不思的落胤」为融合素材并能返回额外卡组。
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToExtra()
end
-- 定义从墓地选择融合怪兽的筛选条件：融合怪兽、卡名记载有「阿不思的落胤」作为融合素材、且能够返回额外卡组。
function c17751597.filter2(c)
	-- 判断墓地怪兽是否为融合怪兽，且是以「阿不思的落胤」为融合素材并能返回额外卡组。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToExtra()
end
-- 效果①发动时的合法性检查：自己场上存在至少1只符合条件的表侧融合怪兽，或墓地存在至少2只符合条件的融合怪兽，否则不能发动。
function c17751597.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否存在至少1只符合filter1条件的表侧融合怪兽，作为可以选择的选项。
	if chk==0 then return Duel.IsExistingMatchingCard(c17751597.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 或者检查墓地是否存在至少2只符合filter2条件的融合怪兽，作为可以选择的选项。
		or Duel.IsExistingMatchingCard(c17751597.filter2,tp,LOCATION_GRAVE,0,2,nil) end
	-- 设置操作信息：本次效果包含无效发动的效果类别，对象为正在连锁的发动卡（eg），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的卡可以被效果破坏且仍与效果相关，则设置操作信息：本次效果包含破坏类别，对象为该发动卡，数量为1。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 规定玩家选择时的规则：只选1张时必须来自场上表侧怪兽（即场上路线）；选2张时必须都来自墓地（即墓地路线），与效果原文的『1只或2只』对应。
function c17751597.fselect(sg)
	if #sg==1 then
		return sg:GetFirst():IsLocation(LOCATION_MZONE)
	else
		return sg:GetFirst():IsLocation(LOCATION_GRAVE) and sg:GetNext():IsLocation(LOCATION_GRAVE)
	end
end
-- 效果①实际处理：从场上/墓地选出符合条件的怪兽返回额外卡组；若所选之卡均成功返回额外卡组，则无效并破坏对方发动的卡片效果。
function c17751597.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有符合filter1条件的表侧融合怪兽，作为候选集合。
	local g1=Duel.GetMatchingGroup(c17751597.filter1,tp,LOCATION_MZONE,0,nil)
	-- 获取自己墓地中符合filter2条件且不受王家长眠之谷影响的融合怪兽，作为候选集合。
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c17751597.filter2),tp,LOCATION_GRAVE,0,nil)
	if #g1==0 and #g2==0 then return end
	g1:Merge(g2)
	-- 向操作者显示『请选择要返回卡组的卡』的提示，引导选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=g1:SelectSubGroup(tp,c17751597.fselect,false,1,2)
	-- 将最终选择的卡组显示选中动画，并标记为本次效果处理的对象。
	Duel.HintSelection(g)
	-- 将选择的卡以效果原因送回持有者卡组（额外卡组怪兽会回到额外卡组），用于完成『回到额外卡组』的处理。
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	local fg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	if #fg~=#g then return end
	-- 若该发动被成功无效，且被无效的卡仍然与此次连锁相关，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将无效掉的那张发动卡以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义效果②的对象筛选条件：不是「烙印断罪」自身、属于「烙印」魔法陷阱卡、且可以加入手卡。
function c17751597.thfilter(c)
	return not c:IsCode(17751597) and c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果②发动时选择自己墓地1张符合条件的「烙印」魔法·陷阱卡为对象，并设置使其加入手牌的操作信息。
function c17751597.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17751597.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1张符合条件的对象（且该对象不能是「烙印断罪」自身）。
	if chk==0 then return Duel.IsExistingTarget(c17751597.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向操作者显示『请选择要加入手牌的卡』的提示，引导选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的「烙印」魔法·陷阱卡，将其作为本连锁的对象。
	local g=Duel.SelectTarget(tp,c17751597.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息：本次效果包含加入手牌的类别，对象为所选择的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②实际处理：若对象仍与效果相关，则将该卡加入手牌。
function c17751597.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因送往其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
