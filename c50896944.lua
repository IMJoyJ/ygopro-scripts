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
-- 定义对象筛选条件：怪兽不是表侧守备表示，且能够改变表示形式。
function c50896944.filter(c)
	return not c:IsPosition(POS_FACEUP_DEFENSE) and c:IsCanChangePosition()
end
-- 效果发动时的对象选择处理：先验证对象是否位于主要怪兽区且满足筛选条件，再检查是否存在至少1只符合条件的怪兽，存在则提示玩家选择并设定为效果对象。
function c50896944.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c50896944.filter(chkc) end
	-- 发动条件检查：确认场上存在至少1只满足筛选条件的怪兽可选为对象。
	if chk==0 then return Duel.IsExistingTarget(c50896944.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要改变表示形式的怪兽”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从双方主要怪兽区选择1只满足条件的怪兽作为效果对象。
	Duel.SelectTarget(tp,c50896944.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数：取得效果对象，若对象仍与效果关联且不是表侧守备表示，则将其变为表侧守备表示。
function c50896944.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将该对象怪兽的表示形式变为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
