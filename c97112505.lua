--先史遺産メガラ・グローヴ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从卡组把「先史遗产 墨瓦腊地球仪」以外的1只「先史遗产」怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，从自己墓地把「先史遗产 墨瓦腊地球仪」以外的1张「先史遗产」卡除外才能发动。这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
function c97112505.initial_effect(c)
	-- ①：把这张卡解放才能发动。从卡组把「先史遗产 墨瓦腊地球仪」以外的1只「先史遗产」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97112505,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97112505)
	e1:SetCost(c97112505.spcost)
	e1:SetTarget(c97112505.sptg)
	e1:SetOperation(c97112505.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从自己墓地把「先史遗产 墨瓦腊地球仪」以外的1张「先史遗产」卡除外才能发动。这张卡加入手卡。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97112505,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,97112506)
	-- 设置效果发动的条件：这张卡送去墓地的回合不能发动。
	e2:SetCondition(aux.exccon)
	e2:SetCost(c97112505.thcost)
	e2:SetTarget(c97112505.thtg)
	e2:SetOperation(c97112505.thop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）处理：解放自身。
function c97112505.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中「先史遗产 墨瓦腊地球仪」以外的、可以特殊召唤的「先史遗产」怪兽。
function c97112505.spfilter(c,e,tp)
	return c:IsSetCard(0x70) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(97112505)
end
-- 效果①的发动检测与效果分类注册（Target）。
function c97112505.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查解放这张卡后，自己场上是否有可用于特殊召唤怪兽的空位。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在满足特殊召唤条件的「先史遗产」怪兽。
		and Duel.IsExistingMatchingCard(c97112505.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）：从卡组特殊召唤1只「先史遗产」怪兽。
function c97112505.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1张满足条件的「先史遗产」怪兽。
	local g=Duel.SelectMatchingCard(tp,c97112505.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己墓地中「先史遗产 墨瓦腊地球仪」以外的、可以作为代价除外的「先史遗产」卡。
function c97112505.thcfilter(c)
	return c:IsSetCard(0x70) and c:IsAbleToRemoveAsCost() and not c:IsCode(97112505)
end
-- 效果②的发动代价（Cost）处理：从墓地除外1张「先史遗产」卡。
function c97112505.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己墓地是否存在除这张卡以外、可作为代价除外的「先史遗产」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c97112505.thcfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从墓地选择1张除这张卡以外的「先史遗产」卡。
	local g=Duel.SelectMatchingCard(tp,c97112505.thcfilter,tp,LOCATION_GRAVE,0,1,1,c)
	-- 将选中的卡表侧表示除外，作为发动的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动检测与效果分类注册（Target）。
function c97112505.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁信息：将墓地的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）：将这张卡加入手卡。
function c97112505.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
