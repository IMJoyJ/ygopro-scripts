--六武の門
-- 效果：
-- ①：每次「六武众」怪兽召唤·特殊召唤给这张卡放置2个武士道指示物。
-- ②：可以把自己场上的武士道指示物的以下数量取除，那个效果发动。
-- ●2个：以场上1只「六武众」效果怪兽或者「紫炎」效果怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
-- ●4个：从自己的卡组·墓地选1只「六武众」怪兽加入手卡。
-- ●6个：以自己墓地1只「紫炎」效果怪兽为对象才能发动。那只怪兽特殊召唤。
function c27970830.initial_effect(c)
	c:EnableCounterPermit(0x3)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次「六武众」怪兽召唤·特殊召唤给这张卡放置2个武士道指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(c27970830.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ●2个：以场上1只「六武众」效果怪兽或者「紫炎」效果怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetDescription(aux.Stringid(27970830,0))  --"●2个：攻击力上升"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c27970830.cost1)
	e4:SetTarget(c27970830.tg1)
	e4:SetOperation(c27970830.op1)
	c:RegisterEffect(e4)
	-- ●4个：从自己的卡组·墓地选1只「六武众」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetDescription(aux.Stringid(27970830,1))  --"●4个：「六武众」怪兽加入手卡"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c27970830.cost2)
	e5:SetTarget(c27970830.tg2)
	e5:SetOperation(c27970830.op2)
	c:RegisterEffect(e5)
	-- ●6个：以自己墓地1只「紫炎」效果怪兽为对象才能发动。那只怪兽特殊召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetDescription(aux.Stringid(27970830,2))  --"●6个：「紫炎」怪兽特殊召唤"
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCost(c27970830.cost3)
	e6:SetTarget(c27970830.tg3)
	e6:SetOperation(c27970830.op3)
	c:RegisterEffect(e6)
end
c27970830.counter_add_list={0x3}
c27970830.mentioned_counter={
	[0x3]=true,
}
-- 过滤函数，用于判断是否为表侧表示的「六武众」怪兽
function c27970830.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 当有「六武众」怪兽被召唤或特殊召唤时，给这张卡放置2个武士道指示物
function c27970830.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c27970830.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x3,2)
	end
end
-- 效果发动时的费用处理，移除2个武士道指示物
function c27970830.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除2个武士道指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,2,REASON_COST) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 实际移除2个武士道指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x3,2,REASON_COST)
end
-- 过滤函数，用于选择表侧表示的「六武众」或「紫炎」效果怪兽
function c27970830.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x103d,0x20) and c:IsType(TYPE_EFFECT)
end
-- 设置效果目标，选择一只符合条件的怪兽
function c27970830.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27970830.filter1(chkc) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c27970830.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择一张表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一只符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c27970830.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要改变攻击力的怪兽
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,500)
end
-- 处理效果，给目标怪兽加上500点攻击力
function c27970830.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个临时的攻击力提升效果并注册到目标怪兽上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
-- 效果发动时的费用处理，移除4个武士道指示物
function c27970830.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除4个武士道指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,4,REASON_COST) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 实际移除4个武士道指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x3,4,REASON_COST)
end
-- 过滤函数，用于选择「六武众」怪兽并能加入手牌
function c27970830.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x103d) and c:IsAbleToHand()
end
-- 设置效果目标，从卡组或墓地选择一只「六武众」怪兽
function c27970830.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否存在符合条件的「六武众」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27970830.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，记录将要加入手牌的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 处理效果，从卡组或墓地选择一只「六武众」怪兽加入手牌
function c27970830.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一只符合条件的「六武众」怪兽加入手牌
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27970830.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果发动时的费用处理，移除6个武士道指示物
function c27970830.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除6个武士道指示物作为费用
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,6,REASON_COST) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 实际移除6个武士道指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x3,6,REASON_COST)
end
-- 过滤函数，用于选择「紫炎」效果怪兽并能特殊召唤
function c27970830.filter3(c,e,tp)
	return c:IsSetCard(0x20) and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，从墓地选择一只符合条件的「紫炎」怪兽
function c27970830.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c27970830.filter3(chkc,e,tp) end
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的「紫炎」怪兽作为目标
		and Duel.IsExistingTarget(c27970830.filter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择一张要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只符合条件的「紫炎」怪兽作为目标
	local g=Duel.SelectTarget(tp,c27970830.filter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，记录将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果，将目标怪兽特殊召唤到场上
function c27970830.op3(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁的效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
