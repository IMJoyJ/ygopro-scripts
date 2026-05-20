--深海のアーチザン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用水属性怪兽的效果从卡组·墓地加入手卡的场合，把这张卡给对方观看才能发动。对方手卡全部确认。
-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把1张卡送去墓地，以「深海工匠」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c8495780.initial_effect(c)
	-- ①：这张卡用水属性怪兽的效果从卡组·墓地加入手卡的场合，把这张卡给对方观看才能发动。对方手卡全部确认。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8495780,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,8495780)
	e1:SetCondition(c8495780.cfcon)
	e1:SetTarget(c8495780.cftg)
	e1:SetOperation(c8495780.cfop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，从自己卡组上面把1张卡送去墓地，以「深海工匠」以外的自己墓地1只4星以下的水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8495780,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,8495781)
	e2:SetCost(c8495780.spcost)
	e2:SetTarget(c8495780.sptg)
	e2:SetOperation(c8495780.spop)
	c:RegisterEffect(e2)
end
-- 判断是否因水属性怪兽的效果从卡组或墓地加入手卡，且未公开
function c8495780.cfcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
		and c:IsPreviousLocation(LOCATION_DECK+LOCATION_GRAVE) and c:IsPreviousControler(tp) and not c:IsPublic()
end
-- 效果1的发动准备，检查对方手卡是否存在未公开的卡
function c8495780.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手卡中是否存在至少1张未公开的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
end
-- 效果1的处理，确认对方全部手卡
function c8495780.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方的全部手卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 让己方玩家确认对方的全部手卡
		Duel.ConfirmCards(tp,g)
		-- 洗切对方的手卡
		Duel.ShuffleHand(1-tp)
	end
end
-- 效果2的代价处理，将自己卡组最上方的一张卡送去墓地
function c8495780.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能将卡组最上方的1张卡送去墓地作为代价
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	-- 将自己卡组最上方的1张卡送去墓地
	Duel.DiscardDeck(tp,1,REASON_COST)
end
-- 过滤条件：自己墓地中「深海工匠」以外的4星以下的水属性怪兽，且能特殊召唤
function c8495780.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(8495780)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备，检查怪兽区域空位并选择墓地中符合条件的怪兽作为对象
function c8495780.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8495780.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c8495780.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8495780.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果2的处理，将作为对象的怪兽特殊召唤并将其效果无效化
function c8495780.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
