--コアの再練成
-- 效果：
-- 选择自己墓地存在的1只名字带有「核成」的怪兽，攻击表示特殊召唤。自己的结束阶段时那只怪兽被破坏时，这张卡的控制者受到那只怪兽的攻击力数值的伤害。这张卡不在场上存在时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c8057630.initial_effect(c)
	-- 选择自己墓地存在的1只名字带有「核成」的怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c8057630.target)
	e1:SetOperation(c8057630.operation)
	c:RegisterEffect(e1)
	-- 这张卡不在场上存在时，那只怪兽破坏。自己的结束阶段时那只怪兽被破坏时，这张卡的控制者受到那只怪兽的攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c8057630.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。自己的结束阶段时那只怪兽被破坏时，这张卡的控制者受到那只怪兽的攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c8057630.descon2)
	e3:SetOperation(c8057630.desop2)
	e2:SetLabelObject(e3)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地中名字带有「核成」且可以表侧攻击表示特殊召唤的怪兽
function c8057630.filter(c,e,tp)
	return c:IsSetCard(0x1d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动的靶向判定与合法性检查
function c8057630.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c8057630.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c8057630.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8057630.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的怪兽特殊召唤，并建立对象连接
function c8057630.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将目标怪兽以表侧攻击表示特殊召唤
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 这张卡离场时的处理：破坏目标怪兽，若在自己的结束阶段则给予控制者伤害
function c8057630.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if not tc then return end
	-- 若目标怪兽在怪兽区，则将其破坏，若破坏失败则不执行后续处理
	if tc:IsLocation(LOCATION_MZONE) and Duel.Destroy(tc,REASON_EFFECT)==0 then return end
	-- 判定是否在自己的结束阶段，且不是因为怪兽被破坏导致此卡离场
	if re~=e:GetLabelObject() and Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 给予这张卡的控制者那只怪兽攻击力数值的伤害
		Duel.Damage(tp,atk,REASON_EFFECT)
	end
end
-- 判定是否为目标怪兽被破坏的事件
function c8057630.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 目标怪兽被破坏时的处理：这张卡破坏，若在自己的结束阶段则给予控制者伤害
function c8057630.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	-- 判定是否在自己的结束阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_END then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 给予这张卡的控制者那只怪兽攻击力数值的伤害
		Duel.Damage(tp,atk,REASON_EFFECT)
	end
	-- 破坏这张卡
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
