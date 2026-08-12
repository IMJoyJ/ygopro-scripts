--捕食計画
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「捕食植物」怪兽送去墓地才能发动。给场上的全部表侧表示怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：这张卡在墓地存在的状态，自己把暗属性怪兽融合召唤的场合，把这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
function c44536921.initial_effect(c)
	-- ①：从卡组把1只「捕食植物」怪兽送去墓地才能发动。给场上的全部表侧表示怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,44536921)
	e1:SetCost(c44536921.cost)
	e1:SetTarget(c44536921.target)
	e1:SetOperation(c44536921.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己把暗属性怪兽融合召唤的场合，把这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,44536922)
	e2:SetCondition(c44536921.descon)
	-- ②效果的代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44536921.destg)
	e2:SetOperation(c44536921.desop)
	c:RegisterEffect(e2)
end
c44536921.mentioned_counter={
	[0x1041]=true,
}
-- 代价过滤函数：筛选可以作为代价送去墓地的「捕食植物」怪兽。
function c44536921.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10f3) and c:IsAbleToGraveAsCost()
end
-- ①效果的代价处理：确认卡组有满足条件的卡，让玩家选择并送去墓地。
function c44536921.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组是否存在1只可以作为代价送去墓地的「捕食植物」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44536921.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的「捕食植物」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c44536921.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 把选择的怪兽作为代价从卡组送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的目标检查函数：确认场上有可以放置捕食指示物的怪兽。
function c44536921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方怪兽区是否存在至少1只可以放置1个捕食指示物的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1) end
end
-- ①效果处理：给场上全部可以放置的怪兽各放置1个捕食指示物，并给2星以上的怪兽注册等级变成1星的效果。
function c44536921.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方怪兽区全部可以放置1个捕食指示物的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(c44536921.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
end
-- 等级变化效果的适用条件：该怪兽放置有捕食指示物。
function c44536921.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 触发过滤函数：筛选自己把暗属性怪兽融合召唤成功上场的怪兽。
function c44536921.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：这次特殊召唤中是否存在自己融合召唤的暗属性怪兽。
function c44536921.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44536921.cfilter,1,nil,tp)
end
-- ②效果的目标选择：以场上1张卡为对象，并设置破坏的操作信息。
function c44536921.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 发动条件检查：场上是否存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息：确定要破坏作为对象的那1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象卡，若仍与效果相关则将其破坏。
function c44536921.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 把作为对象的那张卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
