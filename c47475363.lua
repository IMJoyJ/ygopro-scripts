--波紋のバリア －ウェーブ・フォース－
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。对方场上的攻击表示怪兽全部回到持有者卡组。
function c47475363.initial_effect(c)
	-- 创建效果对象并设置其分类为回卡组、类型为发动、触发事件为攻击宣言、条件函数为condition、目标函数为target、运算函数为operation
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c47475363.condition)
	e1:SetTarget(c47475363.target)
	e1:SetOperation(c47475363.operation)
	c:RegisterEffect(e1)
end
-- 当对方怪兽进行直接攻击时才能发动
function c47475363.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认攻击方为对方且没有攻击目标
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤函数，筛选攻击表示且可以送去卡组的怪兽
function c47475363.filter(c)
	return c:IsAttackPos() and c:IsAbleToDeck()
end
-- 设置效果的目标为对方场上所有攻击表示且可送去卡组的怪兽
function c47475363.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：对方场上存在至少1只攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47475363.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有攻击表示且可送去卡组的怪兽组成的组
	local g=Duel.GetMatchingGroup(c47475363.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息为回卡组效果，目标怪兽组为g，数量为g的数量
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 执行效果运算，将符合条件的怪兽全部送回卡组
function c47475363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有攻击表示且可送去卡组的怪兽组成的组
	local g=Duel.GetMatchingGroup(c47475363.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将怪兽组g以效果原因送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
