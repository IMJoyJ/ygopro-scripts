--洗脳－ブレインコントロール
-- 效果：
-- ①：支付800基本分，以对方场上1只可以通常召唤的表侧表示怪兽为对象才能发动。那只表侧表示怪兽的控制权直到结束阶段得到。
function c87910978.initial_effect(c)
	-- ①：支付800基本分，以对方场上1只可以通常召唤的表侧表示怪兽为对象才能发动。那只表侧表示怪兽的控制权直到结束阶段得到。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c87910978.cost)
	e1:SetTarget(c87910978.target)
	e1:SetOperation(c87910978.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数：检查并支付800点基本分
function c87910978.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，检查玩家是否能够支付800点基本分
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 让发动效果的玩家支付800点基本分
	Duel.PayLPCost(tp,800)
end
-- 过滤条件：可以改变控制权、表侧表示且可以通常召唤的怪兽
function c87910978.filter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup() and c:IsSummonableCard()
end
-- 定义效果发动时的目标选择（Target）函数：选择对方场上1只符合条件的表侧表示怪兽作为对象
function c87910978.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c87910978.filter(chkc) end
	-- 在发动效果的检测阶段，检查对方场上是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c87910978.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端向玩家显示“请选择要改变控制权的怪兽”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择对方场上1只满足过滤条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c87910978.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：此效果包含改变控制权的操作，涉及卡片为选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 定义效果处理（Operation）函数：获取对象怪兽并尝试夺取其控制权
function c87910978.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个（也是唯一一个）对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 让发动效果的玩家获得该怪兽的控制权，直到结束阶段
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
