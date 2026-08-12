--修験の妖社
-- 效果：
-- 「修验的妖社」的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，每次「妖仙兽」怪兽召唤·特殊召唤，给这张卡放置1个妖仙指示物。
-- ②：把这张卡的妖仙指示物任意数量取除才能发动。取除数量的以下效果适用。
-- ●1个：自己场上的「妖仙兽」怪兽的攻击力直到回合结束时上升300。
-- ●3个：从自己的卡组·墓地选1张「妖仙兽」卡加入手卡。
function c27918963.initial_effect(c)
	c:EnableCounterPermit(0x33)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，每次「妖仙兽」怪兽召唤·特殊召唤，给这张卡放置1个妖仙指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c27918963.ctcon)
	e2:SetOperation(c27918963.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 「修验的妖社」的②的效果1回合只能使用1次。②：把这张卡的妖仙指示物任意数量取除才能发动。取除数量的以下效果适用。●1个：自己场上的「妖仙兽」怪兽的攻击力直到回合结束时上升300。●3个：从自己的卡组·墓地选1张「妖仙兽」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27918963,0))  --"取除指示物"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,27918963)
	e4:SetTarget(c27918963.target)
	e4:SetOperation(c27918963.operation)
	c:RegisterEffect(e4)
end
c27918963.mentioned_counter={
	[0x33]=true,
}
-- 过滤条件：表侧表示的「妖仙兽」怪兽。
function c27918963.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 发动条件：这次召唤·特殊召唤成功的怪兽中存在表侧表示的「妖仙兽」怪兽。
function c27918963.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27918963.cfilter,1,nil)
end
-- 效果处理：给这张卡放置1个妖仙指示物。
function c27918963.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x33,1)
end
-- 过滤条件：场上表侧表示的「妖仙兽」怪兽（攻击力上升的对象）。
function c27918963.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 过滤条件：可以加入手卡的「妖仙兽」卡。
function c27918963.filter2(c)
	return c:IsSetCard(0xb3) and c:IsAbleToHand()
end
-- ②效果的目标处理：检查能否取除1个或3个妖仙指示物并存在对应对象，让玩家选择要适用的效果，然后取除相应数量的指示物作为代价。
function c27918963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():IsCanRemoveCounter(tp,0x33,1,REASON_COST)
		-- 并且自己怪兽区域存在表侧表示的「妖仙兽」怪兽。
		and Duel.IsExistingMatchingCard(c27918963.filter1,tp,LOCATION_MZONE,0,1,nil)
	local b2=e:GetHandler():IsCanRemoveCounter(tp,0x33,3,REASON_COST)
		-- 并且自己的卡组·墓地存在可以加入手卡的「妖仙兽」卡。
		and Duel.IsExistingMatchingCard(c27918963.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个效果都能适用时，让玩家选择要适用的效果（攻击力上升或加入手卡）。
		op=Duel.SelectOption(tp,aux.Stringid(27918963,1),aux.Stringid(27918963,2))  --"攻击上升/加入手卡"
	elseif b1 then
		-- 只能取除1个指示物时，让玩家选择攻击力上升效果。
		op=Duel.SelectOption(tp,aux.Stringid(27918963,1))  --"攻击上升"
	else
		-- 只能取除3个指示物时，让玩家选择加入手卡效果（+1使选项序号与效果编号对应）。
		op=Duel.SelectOption(tp,aux.Stringid(27918963,2))+1  --"加入手卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:GetHandler():RemoveCounter(tp,0x33,1,REASON_COST)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:GetHandler():RemoveCounter(tp,0x33,3,REASON_COST)
		-- 设置操作信息：预计从自己卡组·墓地把1张卡加入手卡，用于连锁处理检测。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- ②效果的处理：若选择了攻击力上升，则使自己场上所有「妖仙兽」怪兽攻击力上升300直到回合结束；否则从卡组·墓地选1张「妖仙兽」卡加入手卡并给对方确认。
function c27918963.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 取得自己怪兽区域所有表侧表示的「妖仙兽」怪兽。
		local g=Duel.GetMatchingGroup(c27918963.filter1,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- ●1个：自己场上的「妖仙兽」怪兽的攻击力直到回合结束时上升300。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	else
		-- 向玩家提示请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己的卡组·墓地选1张不受王家长眠之谷影响的可以加入手卡的「妖仙兽」卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27918963.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 以效果原因把选择的卡加入持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
