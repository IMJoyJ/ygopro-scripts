--サイクロン
-- 效果：
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c5318639.initial_effect(c)
	-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c5318639.target)
	e1:SetOperation(c5318639.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定卡片是否为魔法·陷阱卡（魔法卡或陷阱卡类型）。
function c5318639.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果的目标选择函数：进行取对象合法性检查，选择场上1张魔法·陷阱卡作为对象，并设置破坏相关的操作信息。
function c5318639.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5318639.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动时点检查：确认场上是否存在1张除自身以外的、满足条件的魔法·陷阱卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c5318639.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向当前玩家显示选择提示，提示内容为“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1张满足条件的魔法·陷阱卡（除外自身）作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c5318639.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 将本次连锁要执行的操作信息设置为：破坏选中的1张卡，操作类别为破坏（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：从连锁中取出对象，若该对象仍与本次效果关联，则将其破坏。
function c5318639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中取得被选择为对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果（REASON_EFFECT）为原因，将对象卡片破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
