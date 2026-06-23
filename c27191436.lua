--バースト・リターン
-- 效果：
-- 「元素英雄 爆热女郎」在自己场上表侧表示存在时才能发动。场上的「元素英雄 爆热女郎」以外的名字带有「元素英雄」的怪兽全部回到持有者的手卡。
function c27191436.initial_effect(c)
	-- 为卡片添加元素英雄系列编码，用于后续效果判断
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 爆热女郎」在自己场上表侧表示存在时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c27191436.condition)
	e1:SetTarget(c27191436.target)
	e1:SetOperation(c27191436.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「元素英雄 爆热女郎」
function c27191436.cfilter(c)
	return c:IsFaceup() and c:IsCode(58932615)
end
-- 判断发动条件：场上是否存在表侧表示的「元素英雄 爆热女郎」
function c27191436.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c27191436.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：筛选场上表侧表示、名字带有元素英雄系列、但不是爆热女郎且能送入手卡的怪兽
function c27191436.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3008) and not c:IsCode(58932615) and c:IsAbleToHand()
end
-- 设置效果目标：检查场上是否存在满足filter条件的怪兽，并设置操作信息
function c27191436.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标阶段：确认场上是否存在至少1张满足filter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27191436.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取满足filter条件的场上怪兽数组
	local g=Duel.GetMatchingGroup(c27191436.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：指定将怪兽送入手卡的效果分类和目标数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果发动时执行的操作：将满足条件的怪兽送入持有者手卡
function c27191436.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足filter条件的场上怪兽数组
	local g=Duel.GetMatchingGroup(c27191436.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将目标怪兽以效果原因送入手卡
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
