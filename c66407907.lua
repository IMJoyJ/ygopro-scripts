--聖種の天双芽
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「圣天树」连接怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1只4星以下的植物族通常怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡和自己场上1只连接怪兽除外才能发动。自己墓地有同名植物族连接怪兽2只以上存在的场合，选那之内的1只特殊召唤。
function c66407907.initial_effect(c)
	-- ①：自己场上有「圣天树」连接怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1只4星以下的植物族通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,66407907)
	e1:SetCondition(c66407907.spcon)
	e1:SetTarget(c66407907.sptg)
	e1:SetOperation(c66407907.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡和自己场上1只连接怪兽除外才能发动。自己墓地有同名植物族连接怪兽2只以上存在的场合，选那之内的1只特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(66407907,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,66407908)
	e3:SetCost(c66407907.spcost1)
	e3:SetTarget(c66407907.sptg1)
	e3:SetOperation(c66407907.spop1)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「圣天树」连接怪兽
function c66407907.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x2158)
end
-- 效果①的发动条件：自己场上有「圣天树」连接怪兽存在
function c66407907.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「圣天树」连接怪兽
	return Duel.IsExistingMatchingCard(c66407907.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己墓地4星以下的植物族通常怪兽，且能特殊召唤
function c66407907.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查怪兽区域空格、墓地是否存在符合条件的怪兽、选择对象并设置特殊召唤的操作信息）
function c66407907.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66407907.filter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的4星以下植物族通常怪兽
		and Duel.IsExistingTarget(c66407907.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的植物族通常怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c66407907.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（包含选中的对象怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤作为对象的怪兽）
function c66407907.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上可以作为cost除外，且除外后能腾出怪兽区域空格的连接怪兽
function c66407907.cfilter1(c,tp)
	-- 检查该卡是否为连接怪兽、能否作为cost除外，以及该卡离开场上后自己场上是否有可用的怪兽区域空格
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c,tp)>0
end
-- 效果②的发动代价（将墓地的这张卡和自己场上1只连接怪兽除外）
function c66407907.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在至少1只满足条件的连接怪兽可以除外
		and Duel.IsExistingMatchingCard(c66407907.cfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1只满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c66407907.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	g:AddCard(e:GetHandler())
	-- 将选中的连接怪兽和墓地的这张卡表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地可以特殊召唤的植物族连接怪兽，且墓地存在至少2只同名卡
function c66407907.spfilter1(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在另一只与该卡同名的植物族连接怪兽（即墓地有同名卡2只以上存在）
		and Duel.IsExistingMatchingCard(c66407907.spnfilter,tp,LOCATION_GRAVE,0,1,c,c:GetCode())
end
-- 过滤条件：用于检查同名卡的植物族连接怪兽
function c66407907.spnfilter(c,code)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT) and c:IsCode(code)
end
-- 效果②的发动准备（检查墓地是否存在满足特殊召唤条件的同名植物族连接怪兽，并设置特殊召唤的操作信息）
function c66407907.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足特殊召唤条件且有同名卡2只以上存在的植物族连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c66407907.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（选墓地有同名卡2只以上存在的植物族连接怪兽之内的1只特殊召唤）
function c66407907.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件且不受「王家之谷」影响的植物族连接怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66407907.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
