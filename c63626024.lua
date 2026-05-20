--忍法 妖変化の術
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只「忍者」怪兽解放，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上特殊召唤。这个效果特殊召唤的怪兽在这张卡表侧表示存在期间，也当作「忍者」怪兽使用。这张卡从场上离开时那只怪兽送去墓地。
function c63626024.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只「忍者」怪兽解放，以对方墓地1只怪兽为对象才能把这张卡发动。那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,63626024+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c63626024.cost)
	e1:SetTarget(c63626024.target)
	e1:SetOperation(c63626024.activate)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c63626024.desop)
	c:RegisterEffect(e2)
	-- 这个效果特殊召唤的怪兽在这张卡表侧表示存在期间，也当作「忍者」怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_ADD_SETCODE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetValue(0x2b)
	c:RegisterEffect(e3)
end
-- 过滤条件：是否为「忍者」怪兽
function c63626024.cfilter(c)
	return c:IsSetCard(0x2b)
end
-- 发动代价：解放自己场上1只「忍者」怪兽
function c63626024.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的「忍者」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c63626024.cfilter,1,nil) end
	-- 选择自己场上1只「忍者」怪兽解放
	local g=Duel.SelectReleaseGroup(tp,c63626024.cfilter,1,1,nil)
	-- 解放选择的怪兽
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：是否可以特殊召唤
function c63626024.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否能选择对方墓地1只怪兽为对象发动
function c63626024.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c63626024.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在可以特殊召唤的怪兽
		and Duel.IsExistingTarget(c63626024.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c63626024.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽并建立对象关联
function c63626024.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地，则将其以表侧表示特殊召唤到自己场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 离场时的处理：将特殊召唤的怪兽送去墓地
function c63626024.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将该怪兽送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
