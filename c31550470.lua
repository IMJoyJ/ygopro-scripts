--闇次元の解放
-- 效果：
-- ①：以除外的1只自己的暗属性怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。这张卡从场上离开时那只怪兽破坏并除外。那只怪兽破坏时这张卡破坏。
function c31550470.initial_effect(c)
	-- ①：以除外的1只自己的暗属性怪兽为对象才能把这张卡发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31550470.target)
	e1:SetOperation(c31550470.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c31550470.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c31550470.descon2)
	e3:SetOperation(c31550470.desop2)
	c:RegisterEffect(e3)
end
-- 筛选符合条件的对象：怪兽需为表侧表示、暗属性，且能被当前效果特殊召唤。
function c31550470.filter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性判定：若在连锁处理中指定了对象（chkc），则检查该卡是否满足对象条件；若为发动确认（chk==0），则检查怪兽区空位以及是否存在合法对象。
function c31550470.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c31550470.filter(chkc,e,tp) end
	-- 发动时检查自己场上是否存在可用的怪兽区空格（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时检查除外区是否存在至少1只满足筛选条件的暗属性怪兽可作为对象。
		and Duel.IsExistingTarget(c31550470.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从自己除外区选择1只符合条件的暗属性怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c31550470.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，标记本效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽仍与效果关联，则将对象怪兽以表侧表示特殊召唤，并建立这张卡与对象怪兽的永续关联（用于后续追踪）。
function c31550470.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 调用特殊召唤步骤，尝试将对象怪兽以表侧表示特殊召唤；若成功则继续建立关系。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
		e:SetLabelObject(tc)
		c:CreateRelation(tc,RESET_EVENT+RESETS_STANDARD)
		tc:CreateRelation(c,RESET_EVENT+RESETS_STANDARD)
	end
	-- 结束特殊召唤步骤，完成整个特殊召唤流程并触发相关时点。
	Duel.SpecialSummonComplete()
end
-- 这张卡离场时触发的处理：取这张卡的第一个永续对象（被特殊召唤的怪兽），若该怪兽仍在怪兽区，则将其破坏并除外。
function c31550470.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏该对象怪兽，并将其送去除外区（而非墓地），实现“破坏并除外”。
		Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
	end
end
-- 触发条件：当本次离场事件组中含有这张卡记录的永续对象怪兽，且该怪兽的离场原因是“被破坏”时，条件成立。
function c31550470.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 满足条件时执行的处理函数：将这张卡自身破坏。
function c31550470.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏这张卡自身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
