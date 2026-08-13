--インフェルノ・ハンマー
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽变成里侧守备表示。
function c17185260.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17185260,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件：本卡与对方怪兽战斗并战斗破坏对方怪兽将其送去墓地（由aux.bdogcon检测）。
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c17185260.postg)
	e1:SetOperation(c17185260.posop)
	c:RegisterEffect(e1)
end
-- 定义对象筛选条件：对象必须是表侧表示怪兽，且能够被转变为里侧表示。
function c17185260.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果发动时的目标选择处理：验证存在合法对象，选择对方场上1只表侧表示怪兽为效果对象，并设置操作信息为变更表示形式。
function c17185260.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c17185260.filter(chkc) end
	-- 检查发动时点：确认对方场上存在至少1只符合条件的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c17185260.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示信息，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从对方场上选择1只符合条件的表侧表示怪兽，并将其登记为效果的对象。
	local g=Duel.SelectTarget(tp,c17185260.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果处理将变更对象怪兽的表示形式（CATEGORY_POSITION），目标数量为已选择的怪兽数。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理部分：取回效果对象，若对象仍与该效果相关且为表侧表示，则将其变成里侧守备表示。
function c17185260.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将对象怪兽的表示形式改为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
