--ゲール・ドグラ
-- 效果：
-- ①：支付3000基本分才能发动。从自己的额外卡组把1只怪兽送去墓地。
function c16229315.initial_effect(c)
	-- ①：支付3000基本分才能发动。从自己的额外卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetDescription(aux.Stringid(16229315,0))  --"送墓"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c16229315.cost)
	e1:SetTarget(c16229315.target)
	e1:SetOperation(c16229315.operation)
	c:RegisterEffect(e1)
end
-- 定义发动代价函数：检查并支付3000基本分作为发动条件。
function c16229315.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，若为检测调用则返回当前玩家是否能支付3000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,3000) end
	-- 实际支付3000基本分。
	Duel.PayLPCost(tp,3000)
end
-- 定义发动目标选择函数：检查额外卡组是否有怪兽能送去墓地，并设置对应操作信息。
function c16229315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在合法性检测阶段，检查自己的额外卡组是否存在至少1只可以送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置本次效果处理时将执行“把1只怪兽送去墓地”的操作信息，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果处理函数：从自己的额外卡组选择1只怪兽送去墓地。
function c16229315.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的额外卡组中选择1张可以送去墓地的怪兽卡（处理时选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
