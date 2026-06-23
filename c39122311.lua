--竜魂の幻泉
-- 效果：
-- ①：以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽守备表示特殊召唤。只要这张卡在魔法与陷阱区域存在，特殊召唤的那只怪兽的种族变成幻龙族。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c39122311.initial_effect(c)
	-- ①：以自己墓地1只怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c39122311.target)
	e1:SetOperation(c39122311.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c39122311.checkop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c39122311.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 只要这张卡在魔法与陷阱区域存在，特殊召唤的那只怪兽的种族变成幻龙族。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c39122311.descon2)
	e4:SetOperation(c39122311.desop2)
	c:RegisterEffect(e4)
	-- 那只怪兽守备表示特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_CHANGE_RACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(RACE_WYRM)
	c:RegisterEffect(e5)
end
-- 检索满足特殊召唤条件的墓地怪兽
function c39122311.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足发动条件
function c39122311.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39122311.filter(chkc,e,tp) end
	-- 判断场上是否有足够空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c39122311.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c39122311.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动
function c39122311.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 执行特殊召唤步骤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 检查卡片是否被无效
function c39122311.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当怪兽离场时，若未被无效则破坏该怪兽
function c39122311.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否为特殊召唤的怪兽离场
function c39122311.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当特殊召唤的怪兽离场时，破坏此卡
function c39122311.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏此卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
