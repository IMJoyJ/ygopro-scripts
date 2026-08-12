--コズミック・サイクロン
-- 效果：
-- ①：支付1000基本分，以场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
function c8267140.initial_effect(c)
	-- ①：支付1000基本分，以场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c8267140.cost)
	e1:SetTarget(c8267140.target)
	e1:SetOperation(c8267140.activate)
	c:RegisterEffect(e1)
end
-- 定义发动Cost，用于处理支付基本分
function c8267140.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，确认玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 在发动时，让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤场上的魔法·陷阱卡，且该卡必须是可以被除外的
function c8267140.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 定义发动Target，用于进行对象选择和设置操作信息
function c8267140.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c8267140.filter(chkc) and chkc~=e:GetHandler() end
	-- 在发动检查阶段，确认场上是否存在可作为对象的魔法·陷阱卡（排除自身）
	if chk==0 then return Duel.IsExistingTarget(c8267140.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 设置选择卡片时的提示信息为“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择场上1张符合条件的魔法·陷阱卡作为效果的对象
	local g=Duel.SelectTarget(tp,c8267140.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果处理的操作信息，表示该连锁将除外所选的对象卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 定义效果处理函数，执行除外操作
function c8267140.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的第一个（也是唯一一个）对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡以表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
