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
-- 过滤函数：判断卡是否为表侧表示的「六武众」怪兽
function c27970830.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 效果处理：若本次召唤·特殊召唤的怪兽中有表侧表示的「六武众」怪兽，则给这张卡放置2个武士道指示物
function c27970830.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c27970830.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x3,2)
	end
end
-- 代价函数：检查能否取除2个武士道指示物，能则取除并提示对方发动的效果
function c27970830.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为代价取除的2个武士道指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,2,REASON_COST) end
	-- 向对方提示自己发动的是哪个效果（取除2个武士道指示物的效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 作为代价把自己场上的2个武士道指示物取除
	Duel.RemoveCounter(tp,1,0,0x3,2,REASON_COST)
end
-- 过滤函数：判断卡是否为表侧表示的「六武众」效果怪兽或「紫炎」效果怪兽
function c27970830.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x103d,0x20) and c:IsType(TYPE_EFFECT)
end
-- 目标函数：确认场上存在符合条件的怪兽后，选择1只作为效果对象，并设置攻击力上升500的操作信息
function c27970830.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c27970830.filter1(chkc) end
	-- 检查场上是否存在可以成为效果对象的「六武众」效果怪兽或「紫炎」效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c27970830.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家提示选择1只表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 以场上1只「六武众」效果怪兽或「紫炎」效果怪兽为对象
	local g=Duel.SelectTarget(tp,c27970830.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息：对目标怪兽进行攻击力上升500的处理
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,500)
end
-- 效果处理：取得目标怪兽，若其仍表侧表示且与本效果相关，则使其攻击力直到回合结束时上升500
function c27970830.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
-- 代价函数：检查能否取除4个武士道指示物，能则取除并提示对方发动的效果
function c27970830.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为代价取除的4个武士道指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,4,REASON_COST) end
	-- 向对方提示自己发动的是哪个效果（取除4个武士道指示物的效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 作为代价把自己场上的4个武士道指示物取除
	Duel.RemoveCounter(tp,1,0,0x3,4,REASON_COST)
end
-- 过滤函数：判断卡是否为可以加入手卡的「六武众」怪兽
function c27970830.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x103d) and c:IsAbleToHand()
end
-- 目标函数：确认自己的卡组·墓地存在可以加入手卡的「六武众」怪兽，并设置加入手卡的操作信息
function c27970830.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己的卡组·墓地是否存在可以加入手卡的「六武众」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27970830.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置本连锁的操作信息：从自己的卡组·墓地把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从自己的卡组·墓地选1只「六武众」怪兽（经王家长眠之谷过滤）加入手卡，并展示给对方确认
function c27970830.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地选1只可以加入手卡且不受王家长眠之谷影响的「六武众」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27970830.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡加入持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 代价函数：检查能否取除6个武士道指示物，能则取除并提示对方发动的效果
function c27970830.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为代价取除的6个武士道指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x3,6,REASON_COST) end
	-- 向对方提示自己发动的是哪个效果（取除6个武士道指示物的效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 作为代价把自己场上的6个武士道指示物取除
	Duel.RemoveCounter(tp,1,0,0x3,6,REASON_COST)
end
-- 过滤函数：判断卡是否为可以特殊召唤的「紫炎」效果怪兽
function c27970830.filter3(c,e,tp)
	return c:IsSetCard(0x20) and c:IsType(TYPE_EFFECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：检查主怪兽区有空位且自己墓地存在符合条件的怪兽，然后以1只「紫炎」效果怪兽为对象并设置特殊召唤的操作信息
function c27970830.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c27970830.filter3(chkc,e,tp) end
	-- 检查自己的主怪兽区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以成为效果对象且可以特殊召唤的「紫炎」效果怪兽
		and Duel.IsExistingTarget(c27970830.filter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只可以特殊召唤的「紫炎」效果怪兽为对象
	local g=Duel.SelectTarget(tp,c27970830.filter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的操作信息：把目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：主怪兽区无空位则中止，否则把仍与本效果相关的目标怪兽特殊召唤到自己场上
function c27970830.op3(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己的主怪兽区没有可用空格则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得本连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 把目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
