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
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44536921.destg)
	e2:SetOperation(c44536921.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断卡组中是否存在满足条件的「捕食植物」怪兽（怪兽卡、可作为墓地费用、属于捕食植物卡组）
function c44536921.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10f3) and c:IsAbleToGraveAsCost()
end
-- 效果发动时的费用处理，选择1只满足条件的「捕食植物」怪兽送去墓地
function c44536921.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在至少1张满足costfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44536921.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c44536921.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的处理目标确认，检查场上是否存在至少1只可以放置捕食指示物的怪兽
function c44536921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：场上是否存在至少1只可以放置捕食指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1) end
end
-- 效果发动时的处理操作，给场上所有表侧表示怪兽放置1个捕食指示物，并对等级2以上的怪兽变更等级为1星
function c44536921.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有可以放置捕食指示物的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 等级变更效果，将等级2以上的怪兽等级变为1星
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
-- 等级变更效果的触发条件，当怪兽拥有捕食指示物时触发
function c44536921.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 过滤函数，用于判断场上是否有暗属性、融合召唤成功的怪兽
function c44536921.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
end
-- 效果发动的条件判断，检查是否有暗属性融合召唤成功的怪兽
function c44536921.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44536921.cfilter,1,nil,tp)
end
-- 效果发动时的处理目标确认，选择场上1张卡作为破坏对象
function c44536921.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否满足发动条件：场上是否存在至少1张可破坏的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果发动时的处理操作，破坏选中的卡
function c44536921.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
