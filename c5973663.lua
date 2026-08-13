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
	-- 此外，可以把这张卡放置的花指示物任意数量取除把以下效果发动。●1个：选择场上1只植物族怪兽，那个攻击力·守备力直到结束阶段时上升400。
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
	-- 此外，可以把这张卡放置的花指示物任意数量取除把以下效果发动。●2个：选择场上1张卡破坏。
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
	-- 此外，可以把这张卡放置的花指示物任意数量取除把以下效果发动。●3个：选择自己墓地1只植物族怪兽特殊召唤。
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
-- 破坏触发过滤器：判断被破坏的卡之前在怪兽区域以表侧表示存在，且在场时种族为植物族。
function c5973663.ctfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousRaceOnField(),RACE_PLANT)~=0
end
-- 触发条件：确认本次被破坏的卡中存在至少1张满足植物族怪兽过滤条件的卡。
function c5973663.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5973663.ctfilter,1,nil)
end
-- 触发处理：给这张卡放置1个花指示物。
function c5973663.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x18,1)
end
-- 发动代价：检查这张卡是否能取除1个花指示物，可以则向对方提示所选效果并实际取除1个花指示物作为代价。
function c5973663.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x18,1,REASON_COST) end
	-- 向对方玩家提示「对方选择了：」本次发动的效果内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveCounter(tp,0x18,1,REASON_COST)
end
-- 对象过滤器：判断卡片为表侧表示且种族为植物族。
function c5973663.filter1(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 目标函数：发动时确认双方怪兽区域存在可作为对象的表侧表示植物族怪兽，提示选择并选取1只作为对象，再设置攻击力变化的操作信息。
function c5973663.tg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c5973663.filter1(chkc) end
	-- 发动条件检测：确认双方怪兽区域存在至少1只能成为对象的表侧表示植物族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c5973663.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动方提示「请选择表侧表示的卡」的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己选择双方怪兽区域1只表侧表示的植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c5973663.filter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：声明本连锁将进行攻击力变化处理，对象为目标卡，数量为1（第三个参数500为脚本笔误，实际效果按400处理）。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,500)
end
-- 效果处理：取得对象卡，若其仍为表侧表示、与本效果关联且为植物族，则给予其攻击力·守备力上升400的效果，直到结束阶段。
function c5973663.op1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 那个攻击力·守备力直到结束阶段时上升400。
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
-- 发动代价：检查这张卡是否能取除2个花指示物，可以则向对方提示所选效果并实际取除2个花指示物作为代价。
function c5973663.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x18,2,REASON_COST) end
	-- 向对方玩家提示「对方选择了：」本次发动的效果内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveCounter(tp,0x18,2,REASON_COST)
end
-- 目标函数：发动时确认场上存在可作为对象的卡，提示选择并选取1张作为破坏对象，再设置破坏的操作信息。
function c5973663.tg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检测：确认双方场上存在至少1张能成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向发动方提示「请选择要破坏的卡」的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己选择场上1张卡作为破坏效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：声明本连锁将进行破坏处理，对象为目标卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得对象卡，若其仍与本效果关联，则以效果将其破坏。
function c5973663.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 发动代价：检查这张卡是否能取除3个花指示物，可以则向对方提示所选效果并实际取除3个花指示物作为代价。
function c5973663.cost3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x18,3,REASON_COST) end
	-- 向对方玩家提示「对方选择了：」本次发动的效果内容。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	e:GetHandler():RemoveCounter(tp,0x18,3,REASON_COST)
end
-- 对象过滤器：判断卡片为植物族且满足可以被特殊召唤的条件。
function c5973663.filter3(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：作为对象时需是自己墓地满足条件的植物族怪兽；发动时确认自己怪兽区域有空位且墓地存在可作为对象的可特殊召唤植物族怪兽。
function c5973663.tg3(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c5973663.filter3(chkc,e,tp) end
	-- 发动条件检测：确认自己的主要怪兽区域存在可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并确认自己墓地存在至少1只能成为对象且可特殊召唤的植物族怪兽。
		and Duel.IsExistingTarget(c5973663.filter3,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向发动方提示「请选择要特殊召唤的卡」的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己选择自己墓地1只可特殊召唤的植物族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c5973663.filter3,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：声明本连锁将进行特殊召唤处理，对象为目标卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若自己怪兽区域没有空位则中止；取得对象卡，若其仍与本效果关联且为植物族，则将其以表侧表示特殊召唤到自己场上。
function c5973663.op3(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再确认：若自己主要怪兽区域没有可用空位则直接中止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得当前连锁处理的效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_PLANT) then
		-- 将对象卡以表侧表示特殊召唤到自己场上（不无视召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
