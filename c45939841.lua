--ツイスター
-- 效果：
-- 支付500基本分才能发动。选择场上表侧表示存在的1张魔法·陷阱卡破坏。
function c45939841.initial_effect(c)
	-- 支付500基本分才能发动。选择场上表侧表示存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c45939841.cost)
	e1:SetTarget(c45939841.target)
	e1:SetOperation(c45939841.activate)
	c:RegisterEffect(e1)
end
-- 定义本卡的发动代价：检查并支付500基本分。
function c45939841.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认玩家能够支付500基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动代价。
	Duel.PayLPCost(tp,500)
end
-- 定义可选对象条件：场上表侧表示存在的魔法·陷阱卡。
function c45939841.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义效果的发动条件与取对象操作：从双方场上选择1张表侧表示的魔法·陷阱卡（不能选自身）。
function c45939841.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c45939841.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动合法性检查：确认双方场上存在至少1张符合条件的表侧表示魔法·陷阱卡可供选择（且不能是这张卡自身）。
	if chk==0 then return Duel.IsExistingTarget(c45939841.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择1张符合条件的表侧表示魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c45939841.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：本次连锁将破坏1张卡（即所选对象），供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理时的操作：取得对象卡并将其破坏。
function c45939841.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
