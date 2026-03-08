--ピンポイント・ガード
-- 效果：
-- ①：对方怪兽的攻击宣言时，以自己墓地1只4星以下的怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
function c44509898.initial_effect(c)
	-- 效果发动条件：对方怪兽的攻击宣言时，以自己墓地1只4星以下的怪兽为对象才能发动。
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
-- 效果作用：判断是否为对方回合
function c44509898.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：对方怪兽的攻击宣言时
	return Duel.GetTurnPlayer()~=tp
end
-- 效果作用：筛选满足条件的墓地怪兽
function c44509898.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果作用：设置效果目标
function c44509898.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44509898.filter(chkc,e,tp) end
	-- 效果作用：判断场上是否有特殊召唤的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c44509898.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c44509898.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理效果的发动
function c44509898.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：判断目标怪兽是否有效且特殊召唤成功
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 效果原文内容：这个效果特殊召唤的怪兽在这个回合不会被战斗·效果破坏。
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
