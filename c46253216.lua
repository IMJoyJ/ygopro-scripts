--フレンドリーファイア
-- 效果：
-- ①：对方的魔法·陷阱·怪兽的效果发动时，以那张卡以外的场上1张卡为对象才能发动。作为对象的卡破坏。
function c46253216.initial_effect(c)
	-- ①：对方的魔法·陷阱·怪兽的效果发动时，以那张卡以外的场上1张卡为对象才能发动。作为对象的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c46253216.condition)
	e1:SetTarget(c46253216.target)
	e1:SetOperation(c46253216.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：仅当效果发动方（ep）不是自己（tp）时，即对方发动效果时才满足条件。
function c46253216.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 对象筛选条件：选择的卡不能是发动中的效果的那张卡（rc），即“那张卡以外”。
function c46253216.filter(c,rc)
	return c~=rc
end
-- 发动时目标处理：选择对象并设置破坏效果，同时确认存在可选择的合法对象。
function c46253216.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c46253216.filter(chkc,re:GetHandler()) and chkc~=e:GetHandler() end
	-- 检查场上是否存在“那张卡以外”且本卡自身以外的1张卡，可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c46253216.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),re:GetHandler()) end
	-- 弹出选择提示，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方和我方场上选择1张卡作为效果对象（不取发动的效果卡本身）。
	local g=Duel.SelectTarget(tp,c46253216.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler(),re:GetHandler())
	-- 将本次连锁的处理信息设置为破坏1张卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：获取发动时选择的对象，如果对象仍然与效果关联则将其破坏。
function c46253216.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本连锁中作为效果对象而选定的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
