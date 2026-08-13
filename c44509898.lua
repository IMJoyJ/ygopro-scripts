--ピンポイント・ガード
-- 效果：
-- ①：对方怪兽的攻击宣言时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
function c44509898.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c44509898.condition)
	e1:SetTarget(c44509898.target)
	e1:SetOperation(c44509898.operation)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：必须在对方回合（对方怪兽攻击宣言）时才能发动，因此检查当前回合玩家不是本卡控制者。
function c44509898.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不等于tp，确保是对方回合，满足“对方怪兽的攻击宣言时”的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 定义墓地怪兽的筛选条件：必须是4星以下，且能够以表侧守备表示被这个效果特殊召唤。
function c44509898.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的对象判定：若检查已选对象，则确认其在自己墓地、由自己控制且满足特殊召唤条件；若为发动时点检查，则判断场上是否有特殊召唤空格且墓地存在至少1只可选对象。
function c44509898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44509898.filter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区域必须存在可用的空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足条件（4星以下且可以被特殊召唤）的怪兽可以作为对象。
		and Duel.IsExistingTarget(c44509898.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让操作者从自己墓地选择1只满足条件的4星以下怪兽，并将其登记为这张卡发动时的效果对象。
	local g=Duel.SelectTarget(tp,c44509898.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息设定为“特殊召唤1只怪兽”，使其他卡能够对此进行响应和判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象怪兽仍与效果关联，则将其以表侧守备表示特殊召唤；召唤成功后再给它附加本回合内不被战斗·效果破坏的效果。
function c44509898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍与效果存在关联，且以表侧守备表示特殊召唤成功；只有成功时才继续赋予破坏抗性。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
