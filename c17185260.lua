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
	-- 检测是否满足效果发动条件：与对方怪兽战斗并战斗破坏对方怪兽送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c17185260.postg)
	e1:SetOperation(c17185260.posop)
	c:RegisterEffect(e1)
end
-- 筛选条件：目标怪兽必须是表侧表示且可以变成里侧表示
function c17185260.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果处理时的处理函数，用于选择目标怪兽并设置操作信息
function c17185260.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c17185260.filter(chkc) end
	-- 判断是否满足发动条件：场上是否存在符合条件的对方怪兽
	if chk==0 then return Duel.IsExistingTarget(c17185260.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的对方场上的1只表侧表示怪兽作为目标
	local g=Duel.SelectTarget(tp,c17185260.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，指定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果发动后的处理函数，用于执行将目标怪兽变为里侧守备表示
function c17185260.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
