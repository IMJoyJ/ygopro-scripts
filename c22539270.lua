--スクラップ・オイルゾーン
-- 效果：
-- 选择自己墓地存在的1只名字带有「废铁」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这张卡不在场上存在时，那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。这张卡发动的回合，自己不能进行战斗阶段。
function c22539270.initial_effect(c)
	-- 选择自己墓地存在的1只名字带有「废铁」的怪兽发动。选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c22539270.cost)
	e1:SetTarget(c22539270.target)
	e1:SetOperation(c22539270.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c22539270.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c22539270.descon2)
	e3:SetOperation(c22539270.desop2)
	c:RegisterEffect(e3)
	-- 这个效果特殊召唤的怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_TARGET)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e4)
	-- 这张卡发动的回合，自己不能进行战斗阶段。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_DISABLE_EFFECT)
	e5:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e5)
end
-- 检查当前阶段是否为主要阶段1，是则使对方不能进入战斗阶段。
function c22539270.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前阶段是否为主要阶段1。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- 创建一个使对方不能进入战斗阶段的效果并注册。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤满足条件的怪兽（名字带有「废铁」且可特殊召唤）。
function c22539270.filter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标的条件：墓地且控制者为玩家且满足过滤条件。
function c22539270.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c22539270.filter(chkc,e,tp) end
	-- 检查玩家场上是否有足够的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的怪兽。
		and Duel.IsExistingTarget(c22539270.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c22539270.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作。
function c22539270.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然存在于场上且满足特殊召唤条件。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
end
-- 当此卡离开场时，若目标怪兽在场上则将其破坏。
function c22539270.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将目标怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 当目标怪兽离开场时，破坏此卡。
function c22539270.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 破坏此卡。
function c22539270.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏此卡。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
