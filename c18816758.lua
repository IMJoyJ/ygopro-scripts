--侵略の波動
-- 效果：
-- 让自己场上表侧表示存在的1只上级召唤成功的名字带有「侵入魔鬼」的怪兽回到手卡发动。选择对方场上存在的1张卡破坏。
function c18816758.initial_effect(c)
	-- 创建效果，设置为发动时点，类型为魔陷发动，具有取对象效果，破坏效果分类，设置费用、目标和发动处理
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c18816758.cost)
	e1:SetTarget(c18816758.target)
	e1:SetOperation(c18816758.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选自己场上表侧表示、名字带有「侵入魔鬼」、上级召唤成功且能送入手牌的怪兽
function c18816758.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x100a)
		and c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsAbleToHandAsCost()
end
-- 费用处理函数，检查自己场上是否存在满足条件的怪兽，若有则选择一张送入手牌作为费用
function c18816758.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18816758.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1张怪兽送入手牌
	local g=Duel.SelectMatchingCard(tp,c18816758.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽送入手牌作为费用
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 目标选择函数，设置目标为对方场上的任意1张卡
function c18816758.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定破坏效果将要处理的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 发动处理函数，若目标卡存在则将其破坏
function c18816758.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
