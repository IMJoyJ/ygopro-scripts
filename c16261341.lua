--天空聖騎士アークパーシアス
-- 效果：
-- ①：这张卡在手卡·墓地存在，自己把反击陷阱卡发动的场合或者自己把怪兽的效果·魔法·陷阱卡的发动无效的场合，从自己的手卡·场上·墓地把这张卡以外的2只天使族怪兽除外才能发动。这张卡特殊召唤。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡给与对方战斗伤害时才能发动。从卡组把1张「珀耳修斯」卡或者反击陷阱卡加入手卡。
function c16261341.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己把反击陷阱卡发动的场合或者自己把怪兽的效果·魔法·陷阱卡的发动无效的场合，从自己的手卡·场上·墓地把这张卡以外的2只天使族怪兽除外才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16261341,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c16261341.spcon1)
	e3:SetCost(c16261341.spcost)
	e3:SetTarget(c16261341.sptg)
	e3:SetOperation(c16261341.spop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_CHAIN_NEGATED)
	e4:SetCondition(c16261341.spcon2)
	c:RegisterEffect(e4)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e5)
	-- ③：这张卡给与对方战斗伤害时才能发动。从卡组把1张「珀耳修斯」卡或者反击陷阱卡加入手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(16261341,1))
	e6:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(c16261341.thcon)
	e6:SetTarget(c16261341.thtg)
	e6:SetOperation(c16261341.thop)
	c:RegisterEffect(e6)
end
-- e3的发动条件：当前连锁是己方发动的反击陷阱卡，满足①中“自己把反击陷阱卡发动”的场合；此时手卡/墓地的这张卡可发动。
function c16261341.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_COUNTER)
end
-- e4的发动条件：当前连锁是因己方效果被无效的发动，且被无效的是怪兽效果或魔法·陷阱卡的发动，满足①中“自己把怪兽的效果·魔法·陷阱卡的发动无效”的场合。
function c16261341.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取把该连锁无效的玩家，用于判断是否为己方发动的无效。
	local dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_PLAYER)
	return dp==tp and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 费用筛选：从手卡·场上·墓地选择可作为除外代价的天使族怪兽，场上怪兽需表侧表示（不在主要怪兽区则无表侧要求），且满足可作为除外代价。
function c16261341.cfilter(c)
	return c:IsRace(RACE_FAIRY) and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE)) and c:IsAbleToRemoveAsCost()
end
-- 判断卡是否位于主要怪兽区（编号0-4），用于在怪兽区满时通过除外主要怪兽区怪兽来腾出特殊召唤空位。
function c16261341.mzfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetSequence()<5
end
-- ①的代价处理：根据己方可用怪兽区空格数，从手卡·场上·墓地选择这张卡以外的2只天使族怪兽除外；空格不足时强制选择相应数量的主要怪兽区怪兽，以确保特殊召唤时有空位。
function c16261341.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得满足cfilter的己方手卡、主要怪兽区、墓地的天使族怪兽集合，且排除这张卡自身。
	local rg=Duel.GetMatchingGroup(c16261341.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,c)
	-- 计算己方主要怪兽区的可用空格数，用于判断除外选择时需要多少只场上怪兽。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=-ft+1
	if chk==0 then return ft>-2 and rg:GetCount()>1 and (ft>0 or rg:IsExists(c16261341.mzfilter,ct,nil)) end
	local g=nil
	if ft>0 then
		-- 设置选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:Select(tp,2,2,nil)
	elseif ft==0 then
		-- 设置选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c16261341.mzfilter,1,1,nil)
		-- 设置选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g2=rg:Select(tp,1,1,g:GetFirst())
		g:Merge(g2)
	else
		-- 设置选择提示：请选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		g=rg:FilterSelect(tp,c16261341.mzfilter,2,2,nil)
	end
	-- 将选中的天使族怪兽以表侧表示除外，作为这张卡特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤的发动目标：确认这张卡可以被特殊召唤，并设置操作信息为特殊召唤自己。
function c16261341.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c16261341.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③的发动条件：这张卡对对方造成了战斗伤害（ep不为己方玩家）。
function c16261341.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 检索过滤：卡名属于「珀耳修斯」字段或是反击陷阱卡，且能够加入手牌。
function c16261341.thfilter(c)
	return (c:IsSetCard(0x10a) or c:IsType(TYPE_COUNTER)) and c:IsAbleToHand()
end
-- ③的发动目标：检查卡组存在符合条件的卡，并设置操作信息为从卡组检索加入手牌。
function c16261341.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否有至少1张符合条件的「珀耳修斯」卡或反击陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c16261341.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张符合条件的卡加入手牌（目标在效果处理时选择，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的检索处理：从卡组选1张符合条件的卡加入手牌，并向对方展示。
function c16261341.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,c16261341.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认检索到的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
