--サムライソード・バロン
-- 效果：
-- 1回合1次，选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。
function c14344682.initial_effect(c)
	-- 1回合1次，选择对方场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14344682,0))  --"表示形式改变"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c14344682.target)
	e1:SetOperation(c14344682.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的取对象处理：确认对象为对方场上守备表示怪兽，提示玩家选择1只，并将该怪兽登记为效果对象，同时设置变更表示形式的操作信息。
function c14344682.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsDefensePos() end
	-- 发动合法性检查：确认对方场上存在至少1只可被选择为对象的守备表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择守备表示的怪兽”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 让玩家从对方场上选择1只守备表示怪兽，并将其锁定为本效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息，声明本效果将变更对象怪兽的表示形式（CATEGORY_POSITION），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理函数：获取效果对象，确认其仍与该效果相关且仍为守备表示后，将其变成表侧攻击表示。
function c14344682.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁中登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsDefensePos() then
		-- 将对象怪兽的表示形式变更为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
