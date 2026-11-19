--聖種の天双芽
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「圣天树」连接怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1只4星以下的植物族通常怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡和自己场上1只连接怪兽除外才能发动。自己墓地有同名植物族连接怪兽2只以上存在的场合，选那之内的1只特殊召唤。
function c66407907.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己场上有「圣天树」连接怪兽存在，这张卡召唤·特殊召唤成功的场合，以自己墓地1只4星以下的植物族通常怪兽为对象才能发动。那只怪兽特殊召唤。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：把墓地的这张卡和自己场上1只连接怪兽除外才能发动。自己墓地有同名植物族连接怪兽2只以上存在的场合，选那之内的1只特殊召唤。
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
-- 定义条件过滤函数，检查场上怪兽是否为表侧表示且属于「圣天树」(0x2158)字段的连接怪兽。
function c66407907.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x2158)
end
-- ①效果发动条件检查函数：确认自己怪兽区是否存在表侧表示的「圣天树」连接怪兽。
function c66407907.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只表侧表示的「圣天树」连接怪兽。
	return Duel.IsExistingMatchingCard(c66407907.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义①效果的特殊召唤对象过滤函数：检查墓地怪兽是否为4星以下、植物族、通常怪兽且可以正规特殊召唤。
function c66407907.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_PLANT) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动对象检查函数：确认自己怪兽区有空位，且自己墓地存在至少1只符合条件的4星以下植物族通常怪兽可作为对象。
function c66407907.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c66407907.filter(chkc,e,tp) end
	-- 在检查能否发动时，确认自己主要怪兽区至少有1个可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的4星以下植物族通常怪兽并可成为效果对象。
		and Duel.IsExistingTarget(c66407907.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择要特殊召唤的墓地怪兽提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的植物族通常怪兽作为发动对象。
	local g=Duel.SelectTarget(tp,c66407907.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向引擎登记本次连锁确定将对象怪兽特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理函数：若对象怪兽仍与效果保持联系，则将其以表侧表示特殊召唤到自己场上。
function c66407907.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果Cost过滤函数：检查自己场上的怪兽是否为连接怪兽、可作为Cost除外，且该怪兽离场后自己怪兽区有至少1个可用空位。
function c66407907.cfilter1(c,tp)
	-- 判断怪兽是否为连接怪兽、可作为Cost除外，且离场后己方场上存在可用怪兽区空位。
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c,tp)>0
end
-- ②效果Cost检查函数：确认墓地的这张卡自身可作为Cost除外，且自己怪兽区存在至少1只符合条件的连接怪兽。
function c66407907.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己怪兽区是否存在至少1只可作为Cost除外的连接怪兽。
		and Duel.IsExistingMatchingCard(c66407907.cfilter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家发送选择要作为Cost除外的场上连接怪兽提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己怪兽区选择1只满足条件的连接怪兽。
	local g=Duel.SelectMatchingCard(tp,c66407907.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	g:AddCard(e:GetHandler())
	-- 将选中的场上连接怪兽和墓地的这张卡一起以表侧表示作为Cost除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义②效果的特殊召唤过滤函数：检查墓地怪兽是否为可正规特召的植物族连接怪兽，且墓地中除它自身外还存在至少1只同名植物族连接怪兽。
function c66407907.spfilter1(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地除该怪兽外是否存在至少1只同名的植物族连接怪兽。
		and Duel.IsExistingMatchingCard(c66407907.spnfilter,tp,LOCATION_GRAVE,0,1,c,c:GetCode())
end
-- 定义同名连接怪兽检查过滤函数，检查卡片是否为植物族连接怪兽且当前卡名与指定卡名code相同。
function c66407907.spnfilter(c,code)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_PLANT) and c:IsCode(code)
end
-- ②效果目标检查与信息登记函数：确认墓地存在同名2只以上的植物族连接怪兽可特殊召唤，并登记墓地特召1只的操作信息。
function c66407907.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检查能否发动时，确认自己墓地存在至少1组满足2只以上同名的可特召植物族连接怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c66407907.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向引擎登记本次连锁预计从自己墓地特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理函数：确认怪兽区有空位后，从自己墓地选1只满足条件的同名植物族连接怪兽特殊召唤。
function c66407907.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区可用空位是否小于等于0，若无空位则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择要特殊召唤卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只不受「王家长眠之谷」影响且满足同名2只以上条件的植物族连接怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c66407907.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的植物族连接怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
