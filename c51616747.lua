--ヌビアガード
-- 效果：
-- 这张卡对对方造成战斗伤害时，可以将自己墓地里的1张永续魔法卡弹回卡组最上面。
function c51616747.initial_effect(c)
	-- 诱发选发效果，对应一速的【……才能发动】
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51616747,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c51616747.condition)
	e1:SetTarget(c51616747.target)
	e1:SetOperation(c51616747.operation)
	c:RegisterEffect(e1)
end
-- 效果适用条件：造成战斗伤害的玩家不是自己
function c51616747.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤器函数：选择墓地里类型为永续魔法卡且能送入卡组的卡片
function c51616747.filter(c)
	return c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToDeck()
end
-- 效果处理目标选择阶段：确认是否能选择满足条件的目标卡片并设置操作信息
function c51616747.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c51616747.filter(chkc) end
	-- 检查阶段：确认场上是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c51616747.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1张墓地中的永续魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c51616747.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，指定将目标卡片送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理阶段：将选中的卡片送回卡组最上面
function c51616747.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送回卡组顶端
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
