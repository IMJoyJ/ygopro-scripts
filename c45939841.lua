--ツイスター
-- 效果：
-- 支付500基本分才能发动。选择场上表侧表示存在的1张魔法·陷阱卡破坏。
function c45939841.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，具有取对象属性，可在自由时点发动，提示在结束阶段时点发动，设置支付500基本分作为费用，设置选择目标函数和发动函数
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
-- 支付500基本分才能发动
function c45939841.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 筛选场上表侧表示存在的魔法·陷阱卡
function c45939841.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择场上表侧表示存在的1张魔法·陷阱卡作为破坏对象
function c45939841.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c45939841.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查场上是否存在满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c45939841.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的魔法·陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c45939841.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 将选中的魔法·陷阱卡破坏
function c45939841.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
