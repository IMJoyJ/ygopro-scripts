--塊斬機ダランベルシアン
-- 效果：
-- 4星怪兽×2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合，可以把这张卡的超量素材的以下数量取除，那个效果发动。
-- ●2：从卡组把1张「斩机」卡加入手卡。
-- ●3：从卡组把1只4星怪兽加入手卡。
-- ●4：从卡组把1张魔法·陷阱卡加入手卡。
-- ②：把自己场上1只怪兽解放才能发动。从自己的手卡·墓地把1只4星「斩机」怪兽特殊召唤。
function c85692042.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：4星怪兽2只以上（最多99只）。
	aux.AddXyzProcedure(c,nil,4,2,nil,nil,99)
	-- ①：这张卡超量召唤的场合，可以把这张卡的超量素材的以下数量取除，那个效果发动。●2：从卡组把1张「斩机」卡加入手卡。●3：从卡组把1只4星怪兽加入手卡。●4：从卡组把1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85692042,0))  --"2个：检索「斩机」卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,85692042)
	e1:SetCondition(c85692042.thcon)
	e1:SetCost(c85692042.thcost)
	e1:SetTarget(c85692042.thtg)
	e1:SetOperation(c85692042.thop)
	e1:SetLabel(2)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(85692042,1))  --"3个：检索4星怪兽"
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetDescription(aux.Stringid(85692042,2))  --"4个：检索魔法·陷阱卡"
	e3:SetLabel(4)
	c:RegisterEffect(e3)
	-- ②：把自己场上1只怪兽解放才能发动。从自己的手卡·墓地把1只4星「斩机」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(85692042,3))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,85692043)
	e4:SetCost(c85692042.spcost)
	e4:SetTarget(c85692042.sptg)
	e4:SetOperation(c85692042.spop)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：这张卡超量召唤成功。
function c85692042.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果①的代价值：取除对应数量的超量素材。
function c85692042.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,ct,REASON_COST) end
	-- 向对方玩家提示当前选择发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveOverlayCard(tp,ct,ct,REASON_COST)
end
-- 效果①的检索卡片过滤条件：根据取除素材数量，分别过滤「斩机」卡、4星怪兽或魔法·陷阱卡。
function c85692042.thfilter(c,ct)
	if not c:IsAbleToHand() then return false end
	if ct==2 then return c:IsSetCard(0x132)
	elseif ct==3 then return c:IsType(TYPE_MONSTER) and c:IsLevel(4)
	else return c:IsType(TYPE_SPELL+TYPE_TRAP) end
end
-- 效果①的靶向处理：检查卡组是否存在可检索的卡，并设置检索的操作信息。
function c85692042.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足对应检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c85692042.thfilter,tp,LOCATION_DECK,0,1,nil,e:GetLabel()) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组选择1张满足条件的卡加入手卡并给对方确认。
function c85692042.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,c85692042.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的解放怪兽过滤条件：解放该怪兽后，场上必须有可用的怪兽区域。
function c85692042.costfilter(c,tp)
	-- 检查解放该怪兽后，自己场上是否有可用的怪兽区域。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 效果②的代价值：解放自己场上1只怪兽。
function c85692042.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只可解放的怪兽，且解放后能腾出怪兽区域。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c85692042.costfilter,1,nil,tp) end
	-- 让玩家选择1只自己场上要解放的怪兽。
	local g=Duel.SelectReleaseGroup(tp,c85692042.costfilter,1,1,nil,tp)
	-- 解放选择的怪兽。
	Duel.Release(g,REASON_COST)
end
-- 效果②的特殊召唤怪兽过滤条件：手卡或墓地的4星「斩机」怪兽。
function c85692042.spfilter(c,e,tp)
	return c:IsSetCard(0x132) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向处理：检查手卡或墓地是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息。
function c85692042.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的4星「斩机」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c85692042.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从手卡或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理：从手卡或墓地选择1只4星「斩机」怪兽特殊召唤。
function c85692042.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或墓地选择1只满足条件的怪兽（适用墓地封锁效果的检测）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c85692042.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
