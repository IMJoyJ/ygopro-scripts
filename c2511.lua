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
-- 支付将此卡从手卡丢弃的代价
function c2511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡丢入墓地作为发动①效果的代价
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 判断场上是否存在「拉比林斯迷宫」怪兽
function c2511.filter(c)
	return c:IsSetCard(0x17e) and c:IsFaceup()
end
-- 判断场上是否存在「拉比林斯迷宫」怪兽
function c2511.actcon(e)
	-- 判断场上是否存在「拉比林斯迷宫」怪兽
	return Duel.IsExistingMatchingCard(c2511.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 判断目标是否为陷阱卡
function c2511.acttg(e,c)
	return c:GetType()==TYPE_TRAP
end
-- 使自己在本回合可以于盖放的回合发动陷阱卡
function c2511.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 使自己在本回合可以于盖放的回合发动陷阱卡
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
	-- 注册使自己在本回合可以于盖放的回合发动陷阱卡的效果
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否为己方因支付代价而将卡送入墓地，且该卡为「拉比林斯迷宫」卡或通常陷阱卡
function c2511.tscon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local rc=re:GetHandler()
	return rp==tp and r&REASON_COST>0
		and (rc:IsSetCard(0x17e) and not rc:IsCode(2511) or re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:GetType()==TYPE_TRAP)
		and eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_HAND) and not eg:IsContains(e:GetHandler())
end
-- 判断此卡是否可以回手或特殊召唤
function c2511.tstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand()
		-- 判断此卡是否可以特殊召唤
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)) end
end
-- 处理②效果的发动选择
function c2511.tsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 检查是否因王家长眠之谷而无法发动此效果
	if aux.NecroValleyNegateCheck(c) then return end
	-- 检查此卡是否受王家长眠之谷保护
	if not aux.NecroValleyFilter()(c) then return end
	local b1=c:IsAbleToHand()
	-- 判断是否可以特殊召唤此卡
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 让玩家选择将此卡回手或特殊召唤
	local op=aux.SelectFromOptions(tp,{b1,1190},{b2,1152})
	if op==1 then
		-- 将此卡送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
	if op==2 then
		-- 将此卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
