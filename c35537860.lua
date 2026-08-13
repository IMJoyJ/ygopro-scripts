--精神同調波
-- 效果：
-- 自己场上有同调怪兽表侧表示存在的场合才能发动。对方场上存在的1只怪兽破坏。
function c35537860.initial_effect(c)
	-- 自己场上有同调怪兽表侧表示存在的场合才能发动。对方场上存在的1只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c35537860.condition)
	e1:SetTarget(c35537860.target)
	e1:SetOperation(c35537860.activate)
	c:RegisterEffect(e1)
end
-- 判定怪兽是否为表侧表示且为同调怪兽，作为筛选自己场上同调怪兽的过滤条件。
function c35537860.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 发动条件判断：自己场上存在表侧表示的同调怪兽时才满足条件。
function c35537860.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（主要怪兽区）是否存在至少1只表侧表示的同调怪兽。
	return Duel.IsExistingMatchingCard(c35537860.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的取对象处理：选择对方场上存在的1只怪兽作为对象，并设置破坏效果的操作信息。
function c35537860.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 在非连锁处理时检查对方场上是否存在至少1只可成为效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1只怪兽作为此卡效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，记录将破坏1张所选对象卡的类别，供相关效果检测与连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：若选择的对象卡仍与此效果关联，则将其破坏。
function c35537860.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时已选择的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以卡片效果的原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
