--混沌のヴァルキリア
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把1只光属性或者暗属性的怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被除外的场合才能发动。从卡组把1只光属性或者暗属性的怪兽送去墓地。这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
function c53871273.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c53871273.splimit)
	c:RegisterEffect(e1)
	-- 从自己墓地把1只光属性或者暗属性的怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53871273,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,53871273)
	e2:SetCost(c53871273.spcost)
	e2:SetTarget(c53871273.sptg)
	e2:SetOperation(c53871273.spop)
	c:RegisterEffect(e2)
	-- 这张卡被除外的场合才能发动。从卡组把1只光属性或者暗属性的怪兽送去墓地。这个回合，自己不能把这个效果送去墓地的卡以及那些同名卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,53871274)
	e3:SetTarget(c53871273.tgtg)
	e3:SetOperation(c53871273.tgop)
	c:RegisterEffect(e3)
end
-- 限制此卡只能通过效果特殊召唤。
function c53871273.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤满足条件的卡：能作为除外的代价且属性为光或暗。
function c53871273.cfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 检查手牌是否有满足条件的卡，若有则提示选择并除外。
function c53871273.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌是否有满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53871273.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡。
	local sg=Duel.SelectMatchingCard(tp,c53871273.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 检查是否有足够的场地位置并判断此卡是否能特殊召唤。
function c53871273.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的场地位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作。
function c53871273.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤满足条件的卡：属性为光或暗且能送去墓地。
function c53871273.tgfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 检查卡组是否有满足条件的卡，若有则设置处理信息。
function c53871273.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否有满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53871273.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 执行将卡送去墓地并设置不能发动效果的处理。
function c53871273.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,c53871273.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地并判断是否成功。
		if Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
			-- 创建并注册一个效果，使玩家不能发动与该卡同名的卡的效果。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1,0)
			e1:SetValue(c53871273.aclimit)
			e1:SetLabel(g:GetFirst():GetCode())
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将效果注册给玩家。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 判断效果是否为同名卡的效果。
function c53871273.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
