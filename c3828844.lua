--六花聖ストレナエ
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以自己墓地1只植物族怪兽或者1张「六花」卡为对象才能发动。那张卡加入手卡。
-- ②：持有超量素材的这张卡被解放的场合才能发动。从自己的额外卡组·墓地选1只5阶以上的植物族超量怪兽特殊召唤。那之后，可以把这张卡在那只怪兽下面重叠作为超量素材。
function c3828844.initial_effect(c)
	-- 为卡片添加等级为4、需要2个超量素材的XYZ召唤手续
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
-- 效果处理时检查是否能取除1个超量素材作为代价，并提示玩家选择取除的超量素材
function c3828844.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 提示玩家选择要取除的超量素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVEXYZ)  --"请选择要取除的超量素材"
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义过滤函数，用于筛选墓地中的植物族怪兽或六花卡
function c3828844.thfilter(c)
	return (c:IsRace(RACE_PLANT) or c:IsSetCard(0x141)) and c:IsAbleToHand()
end
-- 设置效果目标，选择满足条件的墓地中的卡作为对象
function c3828844.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3828844.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地中的卡
	if chk==0 then return Duel.IsExistingTarget(c3828844.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地中的卡作为效果对象
	local g=Duel.SelectTarget(tp,c3828844.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，将目标卡加入手牌
function c3828844.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 判断该卡是否在解放时具有超量素材
function c3828844.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousOverlayCountOnField()>0
end
-- 定义过滤函数，用于筛选5阶以上植物族XYZ怪兽
function c3828844.spfilter(c,e,tp)
	if not (c:IsRankAbove(5) and c:IsRace(RACE_PLANT) and c:IsType(TYPE_XYZ)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查额外卡组是否有足够的召唤空位
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查主怪兽区是否有足够的召唤空位
		return Duel.GetMZoneCount(tp)>0
	end
end
-- 设置效果目标，选择满足条件的额外卡组或墓地中的怪兽
function c3828844.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的额外卡组或墓地中的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c3828844.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息，指定将怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果处理函数，特殊召唤满足条件的怪兽，并可选择是否将其叠放
function c3828844.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的额外卡组或墓地中的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c3828844.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 检查是否满足叠放条件
		if not c:IsRelateToEffect(e) or not c:IsCanOverlay() or not aux.NecroValleyFilter()(c) then return end
		if c:IsLocation(LOCATION_HAND+LOCATION_DECK) or (not c:IsLocation(LOCATION_GRAVE) and c:IsFacedown()) then return end
		-- 询问玩家是否将此卡叠放作为超量素材
		if Duel.SelectYesNo(tp,aux.Stringid(3828844,2)) then  --"是否把这张卡重叠作为超量素材？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			if not tc:IsImmuneToEffect(e) then
				-- 将此卡叠放至目标怪兽下方
				Duel.Overlay(tc,Group.FromCards(c))
			end
		end
	end
end
