--武神－マヒトツ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1张其他的「武神」卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：可以从以下效果选择1个发动。
-- ●从手卡把1只「武神」怪兽送去墓地才能发动。从自己墓地选和那只怪兽卡名不同的1只「武神」怪兽加入手卡。
-- ●从自己墓地把1只「武神」怪兽除外才能发动。和那只怪兽卡名不同的1只「武神」怪兽从卡组送去墓地。
function c92586237.initial_effect(c)
	-- ①：从手卡把1张其他的「武神」卡送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92586237,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,92586237)
	e1:SetCost(c92586237.spcost)
	e1:SetTarget(c92586237.sptg)
	e1:SetOperation(c92586237.spop)
	c:RegisterEffect(e1)
	-- ●从手卡把1只「武神」怪兽送去墓地才能发动。从自己墓地选和那只怪兽卡名不同的1只「武神」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92586237,1))  --"从墓地加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,92586238)
	e2:SetCost(c92586237.thcost)
	e2:SetTarget(c92586237.thtg)
	e2:SetOperation(c92586237.thop)
	c:RegisterEffect(e2)
	-- ●从自己墓地把1只「武神」怪兽除外才能发动。和那只怪兽卡名不同的1只「武神」怪兽从卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92586237,2))  --"从卡组送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,92586238)
	e3:SetCost(c92586237.tgcost)
	e3:SetTarget(c92586237.tgtg)
	e3:SetOperation(c92586237.tgop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查手卡中是否存在可以作为发动代价送去墓地的「武神」卡
function c92586237.spcfilter(c)
	return c:IsSetCard(0x88) and c:IsAbleToGraveAsCost()
end
-- ①号效果的代价：从手卡把1张其他的「武神」卡送去墓地
function c92586237.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查手卡中是否存在除自身以外的「武神」卡可以送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c92586237.spcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择手卡中1张除自身以外的「武神」卡
	local g=Duel.SelectMatchingCard(tp,c92586237.spcfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①号效果的靶向：检查自身是否可以特殊召唤，并声明特殊召唤的操作信息
function c92586237.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理：将这张卡从手卡特殊召唤
function c92586237.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检查手卡中是否存在可以作为代价送去墓地的「武神」怪兽，且自己墓地存在与之卡名不同的「武神」怪兽
function c92586237.thcfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x88) and c:IsAbleToGraveAsCost()
		-- 检查自己墓地是否存在与该手卡怪兽卡名不同的「武神」怪兽
		and Duel.IsExistingMatchingCard(c92586237.thfilter,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- 过滤函数：检查墓地中是否存在与作为代价的怪兽卡名不同的「武神」怪兽，且该怪兽可以加入手卡
function c92586237.thfilter(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x88) and not c:IsCode(code) and c:IsAbleToHand()
end
-- ②号效果分支1的代价：从手卡把1只「武神」怪兽送去墓地，并记录其卡名
function c92586237.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查手卡中是否存在满足条件的「武神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92586237.thcfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1只满足条件的「武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c92586237.thcfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②号效果分支1的靶向：声明将墓地的卡加入手卡的操作信息
function c92586237.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁中的操作信息：从墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②号效果分支1的处理：从自己墓地选和作为代价的怪兽卡名不同的1只「武神」怪兽加入手卡
function c92586237.thop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从自己墓地选择1只与代价怪兽卡名不同的「武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c92586237.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 对选中的卡进行效果确认（向对方展示）
		Duel.HintSelection(g)
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 过滤函数：检查墓地中是否存在可以作为代价除外的「武神」怪兽，且卡组中存在与之卡名不同的「武神」怪兽
function c92586237.tgcfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x88) and c:IsAbleToRemoveAsCost()
		-- 检查自己卡组中是否存在与该墓地怪兽卡名不同的「武神」怪兽
		and Duel.IsExistingMatchingCard(c92586237.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤函数：检查卡组中是否存在与作为代价的怪兽卡名不同的「武神」怪兽，且该怪兽可以送去墓地
function c92586237.tgfilter(c,code)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x88) and not c:IsCode(code) and c:IsAbleToGrave()
end
-- ②号效果分支2的代价：从自己墓地把1只「武神」怪兽除外，并记录其卡名
function c92586237.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：检查墓地中是否存在满足条件的「武神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92586237.tgcfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从自己墓地选择1只满足条件的「武神」怪兽
	local tc=Duel.SelectMatchingCard(tp,c92586237.tgcfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
	e:SetLabel(tc:GetCode())
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
end
-- ②号效果分支2的靶向：声明将卡组的卡送去墓地的操作信息
function c92586237.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁中的操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②号效果分支2的处理：将和作为代价的怪兽卡名不同的1只「武神」怪兽从卡组送去墓地
function c92586237.tgop(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只与代价怪兽卡名不同的「武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c92586237.tgfilter,tp,LOCATION_DECK,0,1,1,nil,code)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
