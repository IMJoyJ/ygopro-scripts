--ハイ・スピード・リレベル
-- 效果：
-- ①：把自己墓地1只「疾行机人」怪兽除外，以自己场上1只同调怪兽为对象才能发动。那只怪兽直到回合结束时变成和除外的怪兽相同等级，攻击力上升除外的怪兽的等级×500。
function c15555120.initial_effect(c)
	-- 效果原文内容：①：把自己墓地1只「疾行机人」怪兽除外，以自己场上1只同调怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c15555120.cost)
	e1:SetTarget(c15555120.target)
	e1:SetOperation(c15555120.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：检查墓地是否存在满足条件的「疾行机人」怪兽，且场上有可选择的同调怪兽作为对象。
function c15555120.cfilter(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 规则层面作用：确认场上存在满足条件的同调怪兽作为目标。
		and Duel.IsExistingTarget(c15555120.filter,tp,LOCATION_MZONE,0,1,nil,lv)
end
-- 规则层面作用：检索满足条件的墓地「疾行机人」怪兽并除外作为发动代价。
function c15555120.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：判断是否满足发动条件，即是否存在满足条件的墓地怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15555120.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示其选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：选择满足条件的墓地「疾行机人」怪兽。
	local g=Duel.SelectMatchingCard(tp,c15555120.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 规则层面作用：将选中的怪兽除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 规则层面作用：定义目标筛选函数，用于筛选场上的同调怪兽。
function c15555120.filter(c,lv)
	return c:IsFaceup() and not c:IsLevel(lv) and c:IsType(TYPE_SYNCHRO)
end
-- 规则层面作用：设置效果目标，选择场上的同调怪兽作为对象。
function c15555120.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c15555120.filter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 规则层面作用：向玩家发送提示信息，提示其选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面作用：选择满足条件的场上的同调怪兽作为效果对象。
	Duel.SelectTarget(tp,c15555120.filter,tp,LOCATION_MZONE,0,1,1,nil,e:GetLabel())
end
-- 规则层面作用：执行效果，将目标怪兽等级调整为除外怪兽的等级，并提升攻击力。
function c15555120.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 规则层面作用：获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsLevel(lv) then
		-- 效果原文内容：那只怪兽直到回合结束时变成和除外的怪兽相同等级，攻击力上升除外的怪兽的等级×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 效果原文内容：那只怪兽直到回合结束时变成和除外的怪兽相同等级，攻击力上升除外的怪兽的等级×500。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(lv*500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
