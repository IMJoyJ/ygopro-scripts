--白銀の城の狂時計
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。这个回合，自己场上有「拉比林斯迷宫」怪兽存在的场合，自己可以把1张通常陷阱卡在盖放的回合发动。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在的状态，为让自己把「白银之城的狂时钟」以外的「拉比林斯迷宫」卡的效果或者通常陷阱卡发动而让手卡的卡被送去墓地的场合才能发动。这张卡加入手卡或特殊召唤。
function c2511.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。这个回合，自己场上有「拉比林斯迷宫」怪兽存在的场合，自己可以把1张通常陷阱卡在盖放的回合发动。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2511,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,2511)
	e1:SetCost(c2511.cost)
	e1:SetOperation(c2511.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，为让自己把「白银之城的狂时钟」以外的「拉比林斯迷宫」卡的效果或者通常陷阱卡发动而让手卡的卡被送去墓地的场合才能发动。这张卡加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2511,1))  --"这张卡加入手卡或特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,2512)
	e2:SetCondition(c2511.tscon)
	e2:SetTarget(c2511.tstg)
	e2:SetOperation(c2511.tsop)
	c:RegisterEffect(e2)
end
-- ①效果的代价处理：检查手牌中的这张卡能否被丢弃；若可以，则将其从手卡丢弃作为发动代价。
function c2511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将这张卡以“丢弃”＋“代价”的原因从手卡送入墓地，完成①效果的发动代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：用于判断场上是否存在表侧表示且属于「拉比林斯迷宫」字段的卡（在怪兽区即为该字段怪兽）。
function c2511.filter(c)
	return c:IsSetCard(0x17e) and c:IsFaceup()
end
-- ①效果所赋予的“盖放回合可发动陷阱”这一效果的适用条件：存在满足c2511.filter的卡。
function c2511.actcon(e)
	-- 检查己方主要怪兽区是否存在至少1张表侧表示的「拉比林斯迷宫」怪兽。
	return Duel.IsExistingMatchingCard(c2511.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 匹配效果目标必须是通常陷阱卡（此处以类型等于TYPE_TRAP判断）。
function c2511.acttg(e,c)
	return c:GetType()==TYPE_TRAP
end
-- ①效果处理时：为当前玩家场上（魔陷区）注册一个仅在结束阶段前有效的持续效果，使满足条件时通常陷阱可在盖放的回合发动。
function c2511.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上有「拉比林斯迷宫」怪兽存在的场合，自己可以把1张通常陷阱卡在盖放的回合发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(2511,2))  --"适用「白银之城的狂时钟」的效果来发动"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_SZONE,0)
	e1:SetCountLimit(1)
	e1:SetCondition(c2511.actcon)
	e1:SetTarget(c2511.acttg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将设置好的“盖放回合可发动通常陷阱”的效果注册给当前玩家，使该效果实际生效。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件：这张卡在墓地存在，且自己为了发动「白银之城的狂时钟」以外的「拉比林斯迷宫」卡效果或通常陷阱卡，而把手卡中的卡作为代价/原因送去墓地，且该组送去墓地的卡中不含这张自身；同时要求发动方是自己。
function c2511.tscon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rp==tp and r&REASON_COST>0
		and (rc:IsSetCard(0x17e) and not rc:IsCode(2511) or re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:GetType()==TYPE_TRAP)
		and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_HAND) and not eg:IsContains(e:GetHandler())
end
-- ②效果发动时的目标检查：确认这张卡至少满足“可以加入手卡”或“可以特殊召唤”中的一种，否则无法发动。
function c2511.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 检查自己场上是否有可用怪兽区，并且这张卡能否被当前效果特殊召唤（同时检查召唤条件和苏生限制）。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)) end
end
-- ②效果处理：结合王家长眠之谷的影响，让玩家从“加入手卡”和“特殊召唤”中选择一项并执行。
function c2511.tsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 若这张卡处于王家长眠之谷适用中且当前连锁可被无效，则自动无效该连锁并中断本次效果处理。
	if aux.NecroValleyNegateCheck(c) then return end
	-- 再次确认这张卡不受王家长眠之谷的影响；若受影响则不能进行加入手卡/特殊召唤操作，直接返回。
	if not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 判断选项“特殊召唤”是否可用：需要自己怪兽区有空位且这张卡满足特殊召唤条件。
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 弹出选择菜单，让玩家从“加入手卡”（选项1）和“特殊召唤”（选项2）中选择一项，op记录选择结果。
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	if op==1 then
		-- 将这张卡加入其持有者的手卡，作为效果处理后“加入手卡”的结算。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	if op==2 then
		-- 将这张卡以表侧表示特殊召唤到当前玩家（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
