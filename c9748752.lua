--邪帝ガイウス
-- 效果：
-- ①：这张卡上级召唤成功的场合，以场上1张卡为对象发动。那张卡除外，除外的卡是暗属性怪兽卡的场合，给与对方1000伤害。
function c9748752.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合，以场上1张卡为对象发动。那张卡除外，除外的卡是暗属性怪兽卡的场合，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9748752,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c9748752.condition)
	e1:SetTarget(c9748752.target)
	e1:SetOperation(c9748752.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是通过上级召唤成功的，作为效果发动的条件
function c9748752.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果的发动准备与对象选择阶段，确认场上存在可除外的卡，选择1张卡作为对象并设置相应的操作信息
function c9748752.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家在场上选择1张可以被除外的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 设置操作信息，表明此效果在处理时会除外指定的对象卡
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,0,0)
		if tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_DARK) then
			-- 若对象卡是表侧表示的暗属性卡，则设置操作信息，表明此效果在处理时可能会给与对方1000点伤害
			Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
		end
	end
end
-- 效果的处理阶段，将对象卡除外，并根据除外卡的属性和种类决定是否给予对方伤害
function c9748752.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示因效果除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		if tc:IsLocation(LOCATION_REMOVED) and tc:IsType(TYPE_MONSTER) and tc:IsAttribute(ATTRIBUTE_DARK) then
			-- 因效果给与对方玩家1000点伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
