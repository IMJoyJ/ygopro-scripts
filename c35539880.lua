--正統なる血統
-- 效果：
-- ①：以自己墓地1只通常怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c35539880.initial_effect(c)
	-- ①：以自己墓地1只通常怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c35539880.target)
	e1:SetOperation(c35539880.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c35539880.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c35539880.descon2)
	e3:SetOperation(c35539880.desop2)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡片是否满足作为对象的条件，即为通常怪兽且可以被当前效果以表侧攻击表示特殊召唤。
function c35539880.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 取对象效果的Target函数：处理对象指定（chkc）与发动合法性（chk==0）判定。
function c35539880.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35539880.filter(chkc,e,tp) end
	-- 发动条件：自己主要怪兽区需要存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：自己墓地存在至少1只满足条件的通常怪兽可作为对象。
		and Duel.IsExistingTarget(c35539880.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示请选择要特殊召唤的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的通常怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c35539880.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将特殊召唤的操作信息登记到当前连锁，供后续检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：获取对象卡，在卡片和对象仍与效果关联时，将其攻击表示特殊召唤，并与这张卡建立永续对象关系。
function c35539880.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 以表侧攻击表示尝试特殊召唤对象怪兽，若成功召唤则继续执行后续处理。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 结束特殊召唤处理，完成特殊召唤并触发相关时点。
	Duel.SpecialSummonComplete()
end
-- 这张卡从场上离开时的效果：若存在关联对象且该对象仍在怪兽区，则将其破坏。
function c35539880.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏关联的对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定条件：这张卡存在关联对象，且当前离场事件中的怪兽组包含该对象。
function c35539880.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当关联对象离场时，效果处理：破坏这张卡自身。
function c35539880.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡（正统的血统）破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
