--No.29 マネキンキャット
-- 效果：
-- 2星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除，以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。种族或属性和那只怪兽相同的1只怪兽从自己的手卡·卡组·墓地特殊召唤。
function c54191698.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：2星怪兽×2。
	aux.AddXyzProcedure(c,nil,2,2)
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方墓地1只怪兽为对象才能发动。那只怪兽在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54191698,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c54191698.spcost)
	e1:SetTarget(c54191698.sptg1)
	e1:SetOperation(c54191698.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，对方场上有怪兽特殊召唤的场合，以对方场上1只表侧表示怪兽为对象才能发动。种族或属性和那只怪兽相同的1只怪兽从自己的手卡·卡组·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54191698,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,54191698)
	e2:SetCondition(c54191698.spcon)
	e2:SetTarget(c54191698.sptg2)
	e2:SetOperation(c54191698.spop2)
	c:RegisterEffect(e2)
end
-- 设置该怪兽的“No.”编号为29。
aux.xyz_number[54191698]=29
-- 效果①的代价：取除这张卡的1个超量素材。
function c54191698.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果①的过滤条件：对方墓地中可以特殊召唤的怪兽。
function c54191698.spfilter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 效果①的发动准备：检查对方场上是否有空位以及对方墓地是否有可特殊召唤的怪兽，并选择1只作为对象。
function c54191698.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c54191698.spfilter1(chkc,e,tp) end
	-- 检查对方场上是否有可用于特殊召唤的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 检查对方墓地是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingTarget(c54191698.spfilter1,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c54191698.spfilter1,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表明将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的怪兽在对方场上特殊召唤。
function c54191698.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到对方场上。
		Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：对方场上有怪兽特殊召唤的场合。
function c54191698.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 效果②的对象过滤条件：对方场上表侧表示的怪兽，且自己手卡、卡组、墓地存在与其种族或属性相同的可特殊召唤的怪兽。
function c54191698.spfilter2(c,e,tp)
	-- 检查该怪兽是否表侧表示，且自己的手卡、卡组、墓地是否存在至少1只与其种族或属性相同的可特殊召唤的怪兽。
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c54191698.spfilter3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,c)
end
-- 效果②的特殊召唤怪兽过滤条件：与目标怪兽属性或种族相同，且可以特殊召唤的怪兽。
function c54191698.spfilter3(c,e,tp,tc)
	return (c:IsAttribute(tc:GetAttribute()) or c:IsRace(tc:GetRace())) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查自己场上是否有空位以及对方场上是否有满足条件的表侧表示怪兽，并选择1只作为对象。
function c54191698.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c54191698.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方场上是否存在至少1只满足条件的表侧表示怪兽。
		and Duel.IsExistingTarget(c54191698.spfilter2,tp,0,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足条件的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,c54191698.spfilter2,tp,0,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表明将从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②的效果处理：从自己的手卡、卡组、墓地将1只与对象怪兽种族或属性相同的怪兽特殊召唤。
function c54191698.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取效果②的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡、卡组、墓地中选择1只与目标怪兽种族或属性相同的怪兽（受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c54191698.spfilter3),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp,tc)
		if g:GetCount()>0 then
			-- 将选定的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
