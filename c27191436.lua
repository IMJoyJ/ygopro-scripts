--バースト・リターン
-- 效果：
-- 「元素英雄 爆热女郎」在自己场上表侧表示存在时才能发动。场上的「元素英雄 爆热女郎」以外的名字带有「元素英雄」的怪兽全部回到持有者的手卡。
function c27191436.initial_effect(c)
	-- 向卡片c注册“元素英雄”（0x3008）系列字段，使后续效果能够识别名字带有「元素英雄」的怪兽。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 爆热女郎」在自己场上表侧表示存在时才能发动。场上的「元素英雄 爆热女郎」以外的名字带有「元素英雄」的怪兽全部回到持有者的手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c27191436.condition)
	e1:SetTarget(c27191436.target)
	e1:SetOperation(c27191436.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数cfilter：判定卡片为表侧表示且卡号是58932615（元素英雄 爆热女郎）。
function c27191436.cfilter(c)
	return c:IsFaceup() and c:IsCode(58932615)
end
-- 定义发动条件函数condition：检查己方场上是否存在表侧表示的元素英雄 爆热女郎。
function c27191436.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1张表侧表示且卡号为58932615的「元素英雄 爆热女郎」，作为效果能否发动的条件。
	return Duel.IsExistingMatchingCard(c27191436.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义效果适用对象的筛选函数：卡片需为表侧表示、属于「元素英雄」系列、卡名不是「元素英雄 爆热女郎」、并且可以被加入手卡。
function c27191436.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and not c:IsCode(58932615) and c:IsAbleToHand()
end
-- 定义效果发动的目标处理函数：在发动时确认存在符合条件的目标；若存在，获取场上全部符合条件的目标怪兽，并设置将把这些怪兽加入手卡的操作信息。
function c27191436.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 当chk==0（效果发动合法性检查）时，检查场上是否存在至少1张满足filter条件的怪兽，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c27191436.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足filter条件（表侧表示的、元素英雄系列、不是爆热女郎、可加入手卡）的怪兽，作为效果处理时可能送回手卡的候选集合。
	local g=Duel.GetMatchingGroup(c27191436.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息：本次效果将把前面获取的怪兽集合g全部加入持有者手卡，分类为CATEGORY_TOHAND，数量为g中卡的数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 定义效果处理函数activate：在效果结算时重新获取场上所有满足条件的「元素英雄」怪兽，并将其全部送回持有者手卡。
function c27191436.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次获取场上所有满足filter条件的怪兽（防止发动后场上的情况发生变化）。
	local g=Duel.GetMatchingGroup(c27191436.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将获取到的所有满足条件的怪兽送入其持有者的手卡，移动原因是效果处理（REASON_EFFECT）。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
