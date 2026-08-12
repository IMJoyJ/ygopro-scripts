--グレイブ・スクワーマー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地的场合，以场上1张卡为对象发动。那张卡破坏。
function c48343627.initial_effect(c)
	-- 创建效果，描述为“场上1张卡破坏”，分类为破坏，类型为单体诱发必发效果，取对象，触发事件为被战斗破坏送去墓地，条件函数为c48343627.condition，目标函数为c48343627.target，处理函数为c48343627.operation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48343627,0))  --"场上1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c48343627.condition)
	e1:SetTarget(c48343627.target)
	e1:SetOperation(c48343627.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否在墓地且被战斗破坏
function c48343627.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 设置选择目标的条件，允许选择场上的卡作为目标，并提示选择要破坏的卡，然后选择1张场上卡作为目标，设置操作信息为破坏该卡
function c48343627.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return true end
	-- 向玩家提示“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张场上卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏效果，目标为所选的卡，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理函数，获取目标卡，若目标卡存在且与效果相关，则将其破坏
function c48343627.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡以效果为原因进行破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
