--タイムパッセージ
-- 效果：
-- 自己场上表侧表示存在的1只名字带有「命运女郎」的怪兽的等级直到结束阶段时上升3星。
function c94068856.initial_effect(c)
	-- 自己场上表侧表示存在的1只名字带有「命运女郎」的怪兽的等级直到结束阶段时上升3星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c94068856.target)
	e1:SetOperation(c94068856.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且名字带有「命运女郎」的卡
function c94068856.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x31)
end
-- 效果发动的目标选择函数
function c94068856.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c94068856.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c94068856.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94068856.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，将目标怪兽的等级上升3星直到结束阶段
function c94068856.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 等级直到结束阶段时上升3星。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(3)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
