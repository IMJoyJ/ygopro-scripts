--マシンナーズ・ラディエーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：以自己场上1只机械族怪兽为对象才能发动。从自己墓地选和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽特殊召唤，作为对象的怪兽破坏。
function c50863093.initial_effect(c)
	-- ①：从手卡把这张卡以外的1只「机甲」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50863093,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50863093)
	e1:SetCost(c50863093.spcost1)
	e1:SetTarget(c50863093.sptg1)
	e1:SetOperation(c50863093.spop1)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只机械族怪兽为对象才能发动。从自己墓地选和那只怪兽卡名不同并持有那只怪兽的等级以下的等级的1只「机甲」怪兽特殊召唤，作为对象的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50863093,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50863094)
	e2:SetTarget(c50863093.sptg2)
	e2:SetOperation(c50863093.spop2)
	c:RegisterEffect(e2)
end
-- 定义①效果代价的过滤函数：手卡中满足「机甲」字段、是怪兽卡且可以作为代价丢弃的卡。
function c50863093.cfilter(c)
	return c:IsSetCard(0x36) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- ①效果的代价处理：先检查能否支付代价，再选择并丢弃1张满足条件的「机甲」怪兽。
function c50863093.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：手牌中存在这张卡以外的、满足丢弃条件的「机甲」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c50863093.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手卡将1张符合条件的「机甲」怪兽以代价+丢弃的原因送去墓地。
	Duel.DiscardHand(tp,c50863093.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果的目标条件：自己主要怪兽区有空位，且这张卡自身可以被特殊召唤。
function c50863093.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否有可用的怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本效果将把这张卡从手卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍与效果关联，则将其特殊召唤。
function c50863093.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的选择对象过滤：选择自己场上表侧表示机械族怪兽，且墓地存在能对其发动特召的「机甲」怪兽。
function c50863093.desfilter(c,e,tp)
	-- 对象需为表侧表示机械族怪兽，并且墓地存在至少1只符合特召条件的「机甲」怪兽。
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and Duel.IsExistingMatchingCard(c50863093.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode(),c:GetLevel())
end
-- ②效果中从墓地特召的「机甲」怪兽的过滤条件：属于「机甲」字段、卡名与对象怪兽不同、等级不高于对象怪兽等级、且可以被特殊召唤。
function c50863093.spfilter(c,e,tp,code,lv)
	return c:IsSetCard(0x36) and not c:IsCode(code) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动目标处理：确认空位并选择1只符合条件的机械族怪兽作为对象。
function c50863093.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c50863093.desfilter(chkc,e,tp) end
	-- 发动时检查自己场上是否有可用怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查是否存在能够作为对象的机械族怪兽（且墓地有可特召的「机甲」怪兽）。
		and Duel.IsExistingTarget(c50863093.desfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向操作者发出提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作者从自己场上选择1只符合条件的机械族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c50863093.desfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记操作信息：将从墓地特殊召唤1只「机甲」怪兽（数量1，持有者为自己）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	-- 登记操作信息：将破坏选择的对象怪兽（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：若场上仍有空位且对象仍合法，则从墓地选择符合条件的「机甲」怪兽特殊召唤，成功后破坏对象。
function c50863093.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次确认自己场上仍存在可用的怪兽区空格，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 向操作者发出提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只不受王家长眠之谷影响、满足spfilter条件的「机甲」怪兽（不同卡名且等级不高于对象）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50863093.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode(),tc:GetLevel())
		-- 若成功选择到怪兽并特殊召唤成功，则继续执行破坏。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 将作为对象的怪兽以效果原因破坏。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
