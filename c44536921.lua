--捕食計画
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「捕食植物」怪兽送去墓地才能发动。给场上的全部表侧表示怪兽各放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ②：这张卡在墓地存在的状态，自己把暗属性怪兽融合召唤的场合，把这张卡除外，以场上1张卡为对象才能发动。那张卡破坏。
function c44536921.initial_effect(c)
	-- 创建效果，设置效果类别为指示物，类型为激活，代码为自由连锁，提示时机为检查怪兽，限制次数为1次，设置发动代价为c44536921.cost，目标选择为c44536921.target，操作为c44536921.activate，并将效果注册到卡片。
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
	-- 创建效果，设置效果类别为破坏，类型为场地+诱发选发，代码为特殊召唤成功，作用范围为墓地，设置属性为可取对象和延迟生效，限制次数为1次，设置发动条件为c44536921.descon，设置代价为aux.bfgcost，目标选择为c44536921.destg，操作为c44536921.desop，并将效果注册到卡片。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,44536922)
	e2:SetCondition(c44536921.descon)
	-- 将这张卡除外 的过滤条件的简单写法，用在效果注册的 cost 里
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c44536921.destg)
	e2:SetOperation(c44536921.desop)
	c:RegisterEffect(e2)
end
c44536921.mentioned_counter={
	[0x1041]=true,
}
-- 定义一个过滤器函数 c44536921.costfilter，用于判断卡片是否为怪兽、是否属于0x10f3（捕食植物）系列，以及是否可以作为代价送去墓地。
function c44536921.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x10f3) and c:IsAbleToGraveAsCost()
end
-- 定义一个代价函数 c44536921.cost。如果检查标志 chk 为 0，则判断卡组中是否存在满足 c44536921.costfilter 的卡片；否则返回 true。提示玩家选择要送去墓地的卡片，然后从卡组中选择一张满足条件的卡片并将其送去墓地。
function c44536921.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足代价的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c44536921.costfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家发送提示信息，要求其选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择一张满足 c44536921.costfilter 的卡片。
	local g=Duel.SelectMatchingCard(tp,c44536921.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选定的卡片送去墓地作为代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义一个目标选择函数 c44536921.target。如果检查标志 chk 为 0，则判断场上是否存在可以添加指示物的卡片；否则返回 true。
function c44536921.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有可添加指示物的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1) end
end
-- 定义一个激活函数 c44536921.activate。获取效果发动者，从主要怪兽区和额外怪兽区获取所有可以添加指示物的卡片组，并遍历该组中的每张卡片。
function c44536921.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有可添加指示物的卡牌
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1041,1)
		if tc:IsLevelAbove(2) then
			-- 创建单次效果，改变等级。设置重置时机为事件结束+标准重置。设置发动条件为c44536921.lvcon，设置数值为1，将效果注册到目标卡片。
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
-- 定义一个条件函数 c44536921.lvcon，用于判断目标卡片是否拥有指示物。
function c44536921.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 定义一个过滤器函数 c44536921.cfilter，用于判断卡片是否为表侧表示、属性是否为暗属性、召唤类型是否为融合召唤以及召唤玩家是否为当前回合的玩家。
function c44536921.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:IsSummonPlayer(tp)
end
-- 定义一个发动条件函数 c44536921.descon。如果存在满足 c44536921.cfilter 的卡片，则返回 true。
function c44536921.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44536921.cfilter,1,nil,tp)
end
-- 定义一个目标选择函数 c44536921.destg。如果检查标志 chkc 为真，则判断目标卡是否在场上；如果检查标志 chk 为 0，则判断是否存在可作为目标的卡片；否则返回 true。提示玩家选择要破坏的卡片，并设置操作信息。
function c44536921.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查是否有可作为目标的卡牌
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送提示信息，要求其选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择一张目标卡片。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前处理的连锁的操作信息，类别为破坏效果，目标卡组为选定的卡片，数量为 1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义一个操作函数 c44536921.desop。获取当前连锁的第一个目标卡片，如果该卡片与效果相关，则以效果原因将其破坏。
function c44536921.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为理由破坏目标卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
