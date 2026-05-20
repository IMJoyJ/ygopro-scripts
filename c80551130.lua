--奇跡の光臨
-- 效果：
-- ①：以除外的1只自己的天使族怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c80551130.initial_effect(c)
	-- ①：以除外的1只自己的天使族怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c80551130.target)
	e1:SetOperation(c80551130.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c80551130.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c80551130.descon2)
	e3:SetOperation(c80551130.desop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示、天使族且可以特殊召唤的怪兽
function c80551130.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与合法性检测
function c80551130.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c80551130.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足条件的、可作为对象的天使族怪兽
		and Duel.IsExistingTarget(c80551130.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只天使族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c80551130.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含目标卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对象怪兽特殊召唤，并建立对象连接关系
function c80551130.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 尝试将对象怪兽以表侧表示特殊召唤（分步处理）
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 离场时效果处理：获取当前卡片的对象怪兽，若其在怪兽区则将其破坏
function c80551130.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果将对象怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 破坏时效果条件：检查被破坏的卡中是否包含当前卡片的对象怪兽
function c80551130.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 破坏时效果处理：将这张卡自身破坏
function c80551130.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将这张卡自身破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
