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
	-- ②：把这张卡的妖仙指示物任意数量取除才能发动。取除数量的以下效果适用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27918963,0))  --"取除指示物"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,27918963)
	e4:SetTarget(c27918963.target)
	e4:SetOperation(c27918963.operation)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断是否为表侧表示的「妖仙兽」怪兽
function c27918963.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 判断是否有「妖仙兽」怪兽被召唤或特殊召唤成功
function c27918963.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27918963.cfilter,1,nil)
end
-- 给这张卡放置1个妖仙指示物
function c27918963.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x33,1)
end
-- 过滤函数，用于判断是否为「妖仙兽」怪兽且可以加入手牌
function c27918963.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
-- 过滤函数，用于判断是否为「妖仙兽」怪兽且可以加入手牌
function c27918963.filter2(c)
	return c:IsSetCard(0xb3) and c:IsAbleToHand()
end
-- 设置效果的发动条件和选择效果类型，根据是否有足够指示物和满足条件的卡来决定是否可以发动效果
function c27918963.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():IsCanRemoveCounter(tp,0x33,1,REASON_COST)
		-- 检查自己场上是否存在至少1只表侧表示的「妖仙兽」怪兽
		and Duel.IsExistingMatchingCard(c27918963.filter1,tp,LOCATION_MZONE,0,1,nil)
	local b2=e:GetHandler():IsCanRemoveCounter(tp,0x33,3,REASON_COST)
		-- 检查自己卡组或墓地是否存在至少1张「妖仙兽」卡
		and Duel.IsExistingMatchingCard(c27918963.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 让玩家选择发动效果类型：攻击上升或加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(27918963,1),aux.Stringid(27918963,2))  --"攻击上升/加入手卡"
	elseif b1 then
		-- 让玩家选择发动效果类型：攻击上升
		op=Duel.SelectOption(tp,aux.Stringid(27918963,1))  --"攻击上升"
	else
		-- 让玩家选择发动效果类型：加入手卡
		op=Duel.SelectOption(tp,aux.Stringid(27918963,2))+1  --"加入手卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:GetHandler():RemoveCounter(tp,0x33,1,REASON_COST)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:GetHandler():RemoveCounter(tp,0x33,3,REASON_COST)
		-- 设置效果处理时要处理的卡的信息，用于检索卡组或墓地的「妖仙兽」卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- 处理效果发动后的操作，根据选择的效果类型执行不同的效果
function c27918963.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 获取自己场上所有表侧表示的「妖仙兽」怪兽
		local g=Duel.GetMatchingGroup(c27918963.filter1,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		while tc do
			-- 给目标怪兽的攻击力加上300
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组或墓地选择1张「妖仙兽」卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27918963.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方看到被加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
