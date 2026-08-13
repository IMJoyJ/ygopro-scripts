--竜魂の幻泉
-- 效果：
-- ①：以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽守备表示特殊召唤。只要这张卡在魔法与陷阱区域存在，特殊召唤的那只怪兽的种族变成幻龙族。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c39122311.initial_effect(c)
	-- ①：以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽守备表示特殊召唤。
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
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c39122311.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c39122311.descon2)
	e4:SetOperation(c39122311.desop2)
	c:RegisterEffect(e4)
	-- 只要这张卡在魔法与陷阱区域存在，特殊召唤的那只怪兽的种族变成幻龙族。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_TARGET)
	e5:SetCode(EFFECT_CHANGE_RACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetValue(RACE_WYRM)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断自己墓地的怪兽能否以表侧守备表示被当前效果特殊召唤。
function c39122311.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的目标选择与合法性判定：需存在可特殊召唤的墓地怪兽且自己主要怪兽区有空位，并从中选择1只为对象。
function c39122311.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39122311.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空格，作为发动条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在1只满足特殊召唤条件的怪兽，作为发动条件之一。
		and Duel.IsExistingTarget(c39122311.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c39122311.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本次效果将进行特殊召唤（数量1），以便后续时点与效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：在发动者与对象均与效果关联时，将对象怪兽以表侧守备表示特殊召唤，并让这张卡与那只怪兽建立永续对象关系。
function c39122311.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果发动时选择的那1只墓地怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 尝试以表侧守备表示将对象怪兽特殊召唤上场（分步特殊召唤步骤）。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤处理，结束分步特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 这张卡离场前检查自身是否处于无效状态，并将结果记录到效果标签中。
function c39122311.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 这张卡从场上离开时，若其不是因无效状态而离场，且关联对象怪兽仍在场上，则将对象怪兽破坏。
function c39122311.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因将关联的怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定条件：这张卡的关联对象怪兽是否因离场事件而离场。
function c39122311.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 对象怪兽从场上离开时，将这张卡破坏。
function c39122311.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将这张卡自身破坏。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
