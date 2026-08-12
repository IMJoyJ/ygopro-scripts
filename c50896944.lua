--暗黒ブラキ
-- 效果：
-- ①：这张卡召唤成功时，以场上1只怪兽为对象才能发动。那只怪兽变成表侧守备表示。
function c50896944.initial_effect(c)
	-- ①：这张卡召唤成功时，以场上1只怪兽为对象才能发动。那只怪兽变成表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50896944,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c50896944.postg)
	e1:SetOperation(c50896944.posop)
	c:RegisterEffect(e1)
end
-- 筛选场上不是表侧守备表示且可以改变表示形式的怪兽
function c50896944.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 设定效果的目标为满足条件的怪兽
function c50896944.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50896944.filter(chkc) end
	-- 检查是否有满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c50896944.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择一个满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c50896944.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动，将目标怪兽变为表侧守备表示
function c50896944.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
