--罠はずし
-- 效果：
-- 破坏表侧表示的场上的存在的1张陷阱卡。
function c51482758.initial_effect(c)
	-- 破坏表侧表示的场上的存在的1张陷阱卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c51482758.target)
	e1:SetOperation(c51482758.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片必须是表侧表示且为陷阱卡。
function c51482758.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP)
end
-- 发动时的目标处理：检查对象合法性、是否存在可选择的场上表侧表示的陷阱卡，然后选择1张并设置破坏的操作信息。
function c51482758.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c51482758.filter(chkc) end
	-- 在发动时（chk==0）检查场上是否存在至少1张表侧表示陷阱卡可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c51482758.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张表侧表示的陷阱卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c51482758.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 将本次连锁的操作信息设置为破坏1张卡，用于后续效果判定与连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：取得对象卡，若对象仍与本效果关联，则将其破坏。
function c51482758.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
