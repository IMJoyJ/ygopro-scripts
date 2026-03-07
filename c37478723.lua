--『焔聖剣－デュランダル』
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡装备中的场合才能发动。从卡组把1只5星以下的战士族·炎属性怪兽加入手卡。那之后，这张卡破坏。
-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以自己墓地1只5星以下的战士族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
function c37478723.initial_effect(c)
	-- ①：这张卡装备中的场合才能发动。从卡组把1只5星以下的战士族·炎属性怪兽加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37478723.target)
	e1:SetOperation(c37478723.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：装备怪兽被送去墓地让这张卡被送去墓地的场合，以自己墓地1只5星以下的战士族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是战士族怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37478723,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,37478723)
	e3:SetTarget(c37478723.thtg)
	e3:SetOperation(c37478723.thop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37478723,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,37478723)
	e4:SetCondition(c37478723.spcon)
	e4:SetTarget(c37478723.sptg)
	e4:SetOperation(c37478723.spop)
	c:RegisterEffect(e4)
end
-- 选择装备目标怪兽
function c37478723.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可装备的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，记录装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡效果处理
function c37478723.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检索满足条件的战士族·炎属性5星以下怪兽
function c37478723.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(5) and c:IsAbleToHand()
end
-- 设置检索效果处理信息
function c37478723.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37478723.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将怪兽加入手牌的效果信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置破坏装备卡的效果信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 检索并加入手牌，随后破坏装备卡
function c37478723.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,c37478723.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 将选中的怪兽加入手牌
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 确认玩家手牌
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsLocation(LOCATION_HAND) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏装备卡
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 判断装备卡是否因失去装备对象而进入墓地
function c37478723.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_LOST_TARGET) and c:GetPreviousEquipTarget():IsLocation(LOCATION_GRAVE)
end
-- 判断墓地怪兽是否满足特殊召唤条件
function c37478723.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_WARRIOR) and c:IsLevelBelow(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果处理信息
function c37478723.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37478723.spfilter(chkc,e,tp) end
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c37478723.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c37478723.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤效果信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤墓地怪兽并设置后续限制
function c37478723.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置不能特殊召唤非战士族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c37478723.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非战士族怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制非战士族怪兽特殊召唤
function c37478723.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
