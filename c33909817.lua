--森羅の姫芽宮
-- 效果：
-- 1星怪兽×2
-- 「森罗的姬芽宫」的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。自己卡组最上面的卡翻开。翻开的卡是魔法·陷阱卡的场合，那张卡加入手卡。不是的场合，那张卡送去墓地。
-- ②：从手卡以及这张卡以外的自己场上的表侧表示怪兽之中把1只植物族怪兽送去墓地，以自己墓地1只「森罗」怪兽为对象才能发动。那只怪兽特殊召唤。
function c33909817.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用1星怪兽2只作为素材
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。自己卡组最上面的卡翻开。翻开的卡是魔法·陷阱卡的场合，那张卡加入手卡。不是的场合，那张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33909817,0))  --"翻开卡组"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33909817)
	e1:SetCost(c33909817.cost)
	e1:SetTarget(c33909817.target)
	e1:SetOperation(c33909817.operation)
	c:RegisterEffect(e1)
	-- ②：从手卡以及这张卡以外的自己场上的表侧表示怪兽之中把1只植物族怪兽送去墓地，以自己墓地1只「森罗」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33909817,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,33909818)
	e2:SetCost(c33909817.spcost)
	e2:SetTarget(c33909817.sptg)
	e2:SetOperation(c33909817.spop)
	c:RegisterEffect(e2)
end
-- 支付效果代价，从自身场上取除1个超量素材
function c33909817.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查是否满足效果发动条件，确认玩家可以翻开卡组最上方1张卡且卡组中存在可加入手卡的魔法或陷阱卡
function c33909817.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以翻开卡组最上方1张卡
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查卡组中是否存在至少1张可加入手卡的魔法或陷阱卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK,0,1,nil) end
end
-- 翻开玩家卡组最上方1张卡，若为魔法或陷阱卡则加入手卡，否则送去墓地
function c33909817.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以翻开卡组最上方1张卡
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开玩家卡组最上方1张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取玩家卡组最上方1张卡的Group对象
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_SPELL+TYPE_TRAP) and tc:IsAbleToHand() then
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡加入玩家手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 洗切玩家手卡
		Duel.ShuffleHand(tp)
	else
		-- 禁用后续操作的洗牌检测
		Duel.DisableShuffleCheck()
		-- 将翻开的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- 筛选满足条件的植物族怪兽作为效果发动的代价
function c33909817.cfilter(c,ft)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_PLANT) and c:IsAbleToGraveAsCost()
		and (ft>0 or c:GetSequence()<5)
end
-- 支付效果代价，从手卡或场上送1只植物族怪兽到墓地
function c33909817.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local loc=LOCATION_HAND+LOCATION_MZONE
	if ft==0 then loc=LOCATION_MZONE end
	-- 检查是否满足效果发动条件，确认玩家可以送1只植物族怪兽到墓地
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c33909817.cfilter,tp,loc,0,1,e:GetHandler(),ft) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只植物族怪兽送入墓地
	local g=Duel.SelectMatchingCard(tp,c33909817.cfilter,tp,loc,0,1,1,e:GetHandler(),ft)
	-- 将选择的怪兽送入墓地作为效果代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 筛选满足条件的森罗族怪兽用于特殊召唤
function c33909817.filter(c,e,tp)
	return c:IsSetCard(0x90) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，选择玩家墓地中的森罗族怪兽作为特殊召唤对象
function c33909817.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33909817.filter(chkc,e,tp) end
	-- 检查是否满足效果发动条件，确认玩家墓地存在森罗族怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingTarget(c33909817.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择玩家墓地中的森罗族怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c33909817.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量和对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将目标怪兽特殊召唤到场上
function c33909817.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以特殊召唤方式送入场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
