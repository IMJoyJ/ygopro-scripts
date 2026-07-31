--世界樹
-- 效果：
-- 每次场上的植物族怪兽被破坏，给这张卡放置1个花指示物。此外，可以把这张卡放置的花指示物任意数量取除把以下效果发动。
-- ●1个：选择场上1只植物族怪兽，那个攻击力·守备力直到结束阶段时上升400。
-- ●2个：选择场上1张卡破坏。
-- ●3个：选择自己墓地1只植物族怪兽特殊召唤。
function c5973663.initial_effect(c)
	c:EnableCounterPermit(0x18)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次场上的植物族怪兽被破坏，给这张卡放置1个花指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c5973663.ctcon)
	e2:SetOperation(c5973663.ctop)
	c:RegisterEffect(e2)
	-- ●1个：选择场上1只植物族怪兽，那个攻击力·守备力直到结束阶段时上升400。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetDescription(aux.Stringid(5973663,0))  --"1个：攻守上升"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c5973663.cost1)
	e3:SetTarget(c5973663.tg1)
	e3:SetOperation(c5973663.op1)
	c:RegisterEffect(e3)
	-- ●2个：选择场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetDescription(aux.Stringid(5973663,1))  --"2个：卡片破坏"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c5973663.cost2)
	e4:SetTarget(c5973663.tg2)
	e4:SetOperation(c5973663.op2)
	c:RegisterEffect(e4)
	-- ●3个：选择自己墓地1只植物族怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetDescription(aux.Stringid(5973663,2))  --"3个：特殊召唤"
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c5973663.cost3)
	e5:SetTarget(c5973663.tg3)
	e5:SetOperation(c5973663.op3)
	c:RegisterEffect(e5)
end
c5973663.mentioned_counter={
	[0x18]=true,
}
-- 放置指示物过滤条件：场上被破坏前为表侧表示的植物族怪兽
function c5973663.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)~=0
end
-- 放置指示物发动条件：存在满足条件的被破坏怪兽
function c5973663.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5973663.ctfilter,1,nil)
end
-- 放置指示物处理：给这张卡放置1个花指示物
function c5973663.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x18,1)
end
-- 效果1Cost：去除这张卡1个花指示物
function c5973663.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x18,1,REASON_COST) end
	-- 向对方提示选择的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveCounter(tp,0x18,1,REASON_COST)
end
-- 效果1目标过滤条件：场上的表侧表示植物族怪兽
function c5973663.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 效果1发动准备：选择场上1只表侧表示植物族怪兽为对象
function c5973663.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5973663.filter1(chkc) end
	-- 发动条件检查：场上是否存在表侧表示植物族怪兽
	if chk==0 then return Duel.IsExistingTarget(c5973663.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示植物族怪兽作为对象
	local g=Duel.SelectTarget(tp,c5973663.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：变更1只怪兽的攻击力
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,500)
end
-- 效果1处理：目标怪兽攻击力·守备力直到结束阶段上升400
function c5973663.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 目标怪兽攻击力上升400直到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(400)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- 效果2Cost：去除这张卡2个花指示物
function c5973663.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x18,2,REASON_COST) end
	-- 向对方提示选择的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveCounter(tp,0x18,2,REASON_COST)
end
-- 效果2发动准备：选择场上1张卡为对象
function c5973663.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在任意卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果2处理：破坏选中的目标卡
function c5973663.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果3Cost：去除这张卡3个花指示物
function c5973663.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x18,3,REASON_COST) end
	-- 向对方提示选择的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveCounter(tp,0x18,3,REASON_COST)
end
-- 效果3目标过滤条件：自己墓地可特殊召唤的植物族怪兽
function c5973663.filter3(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果3发动准备：选择自己墓地1只植物族怪兽为对象
function c5973663.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c5973663.filter3(chkc,e,tp) end
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己墓地是否存在满足条件的植物族怪兽
		and Duel.IsExistingTarget(c5973663.filter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只植物族怪兽作为对象
	local g=Duel.SelectTarget(tp,c5973663.filter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果3处理：将选中的墓地植物族怪兽特殊召唤
function c5973663.op3(e,tp,eg,ep,ev,re,r,rp)
	-- 检查主要怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将目标怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
