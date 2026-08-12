--ドラゴンメイド・パルラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「半龙女仆·客厅龙女」以外的1张「半龙女仆」卡送去墓地。
-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只8星「半龙女仆」怪兽特殊召唤。
function c88453933.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「半龙女仆·客厅龙女」以外的1张「半龙女仆」卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88453933,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,88453933)
	e1:SetTarget(c88453933.tgtg)
	e1:SetOperation(c88453933.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己·对方的战斗阶段开始时才能发动。这张卡回到手卡，从自己的手卡·墓地把1只8星「半龙女仆」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88453933,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,88453934)
	e3:SetTarget(c88453933.sptg)
	e3:SetOperation(c88453933.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「半龙女仆·客厅龙女」以外的「半龙女仆」卡
function c88453933.tgfilter(c)
	return c:IsSetCard(0x133) and not c:IsCode(88453933) and c:IsAbleToGrave()
end
-- ①号效果的发动准备与效果检测
function c88453933.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在除「半龙女仆·客厅龙女」以外的「半龙女仆」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c88453933.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的实际处理
function c88453933.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张除「半龙女仆·客厅龙女」以外的「半龙女仆」卡
	local g=Duel.SelectMatchingCard(tp,c88453933.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤手卡或墓地中可以特殊召唤的8星「半龙女仆」怪兽
function c88453933.spfilter(c,e,tp)
	return c:IsSetCard(0x133) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备与效果检测
function c88453933.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查在这张卡离开场上后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡或墓地是否存在可以特殊召唤的8星「半龙女仆」怪兽
		and Duel.IsExistingMatchingCard(c88453933.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为将自身回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息为从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②号效果的实际处理
function c88453933.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍存在于场上，则将其回到手卡
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)~=0
		-- 确认这张卡已成功回到手卡，且自己场上有可用的怪兽区域
		and c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡或墓地选择1只不受墓地限制效果影响的8星「半龙女仆」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c88453933.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
