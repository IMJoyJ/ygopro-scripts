--超重神童ワカ－U4
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合才能发动。从卡组选「超重神童 牛若-U4」以外的1只「超重武者」灵摆怪兽在自己的灵摆区域放置。那之后，这张卡特殊召唤。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「超重武者」卡使用。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，从手卡丢弃1只怪兽才能发动。从手卡·卡组把1只「超重武者」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「超重武者」怪兽不能特殊召唤。
-- ②：这张卡作为同调素材表侧表示加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
function c82112494.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：自己墓地没有魔法·陷阱卡存在的场合才能发动。从卡组选「超重神童 牛若-U4」以外的1只「超重武者」灵摆怪兽在自己的灵摆区域放置。那之后，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82112494,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,82112494)
	e1:SetCondition(c82112494.spcon)
	e1:SetTarget(c82112494.pctg)
	e1:SetOperation(c82112494.pcop)
	c:RegisterEffect(e1)
	-- ①：自己墓地没有魔法·陷阱卡存在的场合，从手卡丢弃1只怪兽才能发动。从手卡·卡组把1只「超重武者」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「超重武者」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82112494,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,82112495)
	e2:SetCondition(c82112494.spcon)
	e2:SetCost(c82112494.spcost)
	e2:SetTarget(c82112494.sptg)
	e2:SetOperation(c82112494.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡作为同调素材表侧表示加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,82112496)
	e3:SetCondition(c82112494.pencon)
	e3:SetTarget(c82112494.pentg)
	e3:SetOperation(c82112494.penop)
	c:RegisterEffect(e3)
end
-- 检查自己墓地是否存在魔法·陷阱卡，作为效果发动的条件。
function c82112494.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己墓地没有魔法·陷阱卡存在。
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 过滤卡组中「超重神童 牛若-U4」以外的「超重武者」灵摆怪兽，且该卡可以放置在灵摆区域。
function c82112494.pcfilter(c,tp)
	return not c:IsCode(82112494) and c:IsSetCard(0x9a) and c:IsType(TYPE_PENDULUM)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 灵摆效果的发动准备与可行性检查（检查灵摆区域是否有空位、卡组是否有可放置的怪兽、怪兽区域是否有空位以及自身能否特殊召唤）。
function c82112494.pctg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的灵摆区域是否有空位。
	if chk==0 then return (Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1))
		-- 检查卡组中是否存在满足条件的「超重武者」灵摆怪兽。
		and Duel.IsExistingMatchingCard(c82112494.pcfilter,tp,LOCATION_DECK,0,1,nil,tp)
		-- 检查自己场上是否有怪兽区域空位，且自身是否可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理（从卡组选怪兽放置到灵摆区域，那之后将自身特殊召唤）。
function c82112494.pcop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查灵摆区域是否仍有空位，若无则不处理。
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	local c=e:GetHandler()
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从卡组选择1张满足条件的「超重武者」灵摆怪兽。
	local g=Duel.SelectMatchingCard(tp,c82112494.pcfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 将选中的怪兽移动并表侧表示放置到自己的灵摆区域，若失败则流程终止。
	if #g==0 or not Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_PZONE,POS_FACEUP,true) then return end
	-- 检查自身是否仍与效果相关，且怪兽区域是否有空位，若不满足则不进行后续特殊召唤。
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 中断当前效果处理，使后续的特殊召唤与前面的放置灵摆卡不视为同时处理（对应“那之后”）。
	Duel.BreakEffect()
	-- 将这张卡表侧表示特殊召唤。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡中可以丢弃的怪兽，且卡组或手卡中存在可特殊召唤的「超重武者」怪兽。
function c82112494.costfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
		-- 检查手卡或卡组中是否存在可以特殊召唤的「超重武者」怪兽（排除作为cost丢弃的卡）。
		and Duel.IsExistingMatchingCard(c82112494.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp)
end
-- 过滤可以守备表示特殊召唤的「超重武者」怪兽。
function c82112494.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 怪兽效果①的发动代价处理（从手卡丢弃1只怪兽）。
function c82112494.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为代价丢弃的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c82112494.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 让玩家选择并丢弃1张手卡中的怪兽。
	Duel.DiscardHand(tp,c82112494.costfilter,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
end
-- 怪兽效果①的发动准备与可行性检查（检查怪兽区域空位及手卡·卡组中是否有可特殊召唤的怪兽）。
function c82112494.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在可以特殊召唤的「超重武者」怪兽。
		and Duel.IsExistingMatchingCard(c82112494.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示此效果会从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 怪兽效果①的效果处理（施加特殊召唤限制，并从手卡·卡组守备表示特殊召唤1只「超重武者」怪兽）。
function c82112494.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个效果的发动后，直到回合结束时自己不是「超重武者」怪兽不能特殊召唤。从手卡·卡组把1只「超重武者」怪兽守备表示特殊召唤。②：这张卡作为同调素材表侧表示加入额外卡组的场合才能发动。这张卡在自己的灵摆区域放置。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c82112494.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家在此回合内只能特殊召唤「超重武者」怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取手卡及卡组中所有满足特殊召唤条件的「超重武者」怪兽。
	local g=Duel.GetMatchingGroup(c82112494.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or #g==0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的怪兽以守备表示特殊召唤。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 限制只能特殊召唤「超重武者」怪兽的过滤函数。
function c82112494.splimit(e,c)
	return not c:IsSetCard(0x9a)
end
-- 检查这张卡是否作为同调素材表侧表示加入额外卡组，作为效果②的发动条件。
function c82112494.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and r==REASON_SYNCHRO
end
-- 效果②的发动准备与可行性检查（检查灵摆区域是否有空位）。
function c82112494.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 效果②的效果处理（将这张卡放置在自己的灵摆区域）。
function c82112494.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动并表侧表示放置到自己的灵摆区域。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
