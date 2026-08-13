--六花聖ストレナエ
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以自己墓地1只植物族怪兽或者1张「六花」卡为对象才能发动。那张卡加入手卡。
-- ②：持有超量素材的这张卡被解放的场合才能发动。从自己的额外卡组·墓地选1只5阶以上的植物族超量怪兽特殊召唤。那之后，可以把这张卡在那只怪兽下面重叠作为超量素材。
function c3828844.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：使用2只4星怪兽作为超量素材进行超量召唤（对应“4星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己墓地1只植物族怪兽或者1张「六花」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3828844,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,3828844)
	e1:SetCost(c3828844.thcost)
	e1:SetTarget(c3828844.thtg)
	e1:SetOperation(c3828844.thop)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡被解放的场合才能发动。从自己的额外卡组·墓地选1只5阶以上的植物族超量怪兽特殊召唤。那之后，可以把这张卡在那只怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3828844,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,3828845)
	e2:SetCondition(c3828844.spcon)
	e2:SetTarget(c3828844.sptg)
	e2:SetOperation(c3828844.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价：检查并取除这张卡的1个超量素材作为COST；若可发动则提示玩家选择并取除素材。
function c3828844.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 向当前玩家发送“请选择要取除的超量素材”的提示消息，用于取除素材时的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的对象筛选条件：目标必须是植物族怪兽或「六花」卡，并且能够被加入手卡。
function c3828844.thfilter(c)
	return (c:IsRace(RACE_PLANT) or c:IsSetCard(0x141)) and c:IsAbleToHand()
end
-- ①效果的目标选择与发动条件：发动时从自己墓地选择1张植物族或「六花」卡为对象；若指定对象则校验合法性，并设置回手牌操作信息。
function c3828844.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3828844.thfilter(chkc) end
	-- 发动检查：确认自己墓地存在至少1张植物族或「六花」卡且能被加入手卡，以此作为发动的前提。
	if chk==0 then return Duel.IsExistingTarget(c3828844.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向当前玩家发送“请选择要加入手牌的卡”的提示消息，用于选择目标卡时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的植物族/「六花」卡作为效果对象，并自动登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c3828844.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：本效果将对象卡加入手牌，数量为1，供其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理时的操作：取得对象卡，若其仍与效果关联，则将其加入持有者的手卡。
function c3828844.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁上记录的第1张对象卡（即发动时选择的目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入其持有者的手卡（nil表示送回持有者手卡），实现“那张卡加入手卡”。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡被解放时，且解放前位于怪兽区域并持有超量素材。
function c3828844.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousOverlayCountOnField()>0
end
-- ②效果选择特召怪兽的筛选条件：候选必须是5阶以上、植物族、超量怪兽，且能被效果特殊召唤。
function c3828844.spfilter(c,e,tp)
	if not (c:IsRankAbove(5) and c:IsRace(RACE_PLANT) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 当候选在额外卡组时，检查自己场上是否有从额外卡组特殊召唤所需的可用空格（>0表示可以）。
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 当候选在墓地时，检查自己场上是否有空的怪兽区域可以特殊召唤（>0表示可以）。
		return Duel.GetMZoneCount(tp)>0
	end
end
-- ②效果的目标选择与发动条件：检查是否存在符合条件的特召候选，并设置特殊召唤的操作信息。
function c3828844.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：确认额外卡组或墓地存在至少1只满足条件的5阶以上植物族超量怪兽，且能够特殊召唤。
	if chk==0 then return Duel.IsExistingMatchingCard(c3828844.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息：本效果将从额外卡组/墓地特殊召唤1只怪兽，供是否被无效等判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- ②效果处理时的操作：从额外卡组/墓地选择1只符合条件的植物族超量怪兽特殊召唤；成功后询问是否将这张被解放的卡叠放作为超量素材。
function c3828844.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向当前玩家发送“请选择要特殊召唤的卡”的提示消息，用于选择特召怪兽时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组或墓地选择1只符合条件的植物族超量怪兽（同时排除王家长眠之谷的影响），用于特殊召唤。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3828844.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择到了怪兽且特殊召唤成功（返回值不为0），则继续执行后续的叠放处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 若被解放的这张卡已不与效果关联、不能作为超量素材、或受王家长眠之谷等影响，则中止后续叠放。
		if not c:IsRelateToEffect(e) or not c:IsCanOverlay() or not aux.NecroValleyFilter()(c) then return end
		if c:IsLocation(LOCATION_HAND+LOCATION_DECK) or (not c:IsLocation(LOCATION_GRAVE) and c:IsFacedown()) then return end
		-- 询问玩家是否将这张被解放的卡叠放在特召怪兽下面作为超量素材（对应“那之后，可以把这张卡在那只怪兽下面重叠作为超量素材”）。
		if Duel.SelectYesNo(tp,aux.Stringid(3828844,2)) then  --"是否把这张卡重叠作为超量素材？"
			-- 中断当前效果处理，使后续的叠放处理与特殊召唤视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			if not tc:IsImmuneToEffect(e) then
				-- 将这张卡作为超量素材叠放到已特殊召唤的怪兽下面，完成叠放操作。
				Duel.Overlay(tc,Group.FromCards(c))
			end
		end
	end
end
