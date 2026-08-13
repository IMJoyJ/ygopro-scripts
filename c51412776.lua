--聖杯の継承
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地选1只「圣骑士」怪兽或者1张「圣剑」卡加入手卡。
-- ②：这张卡在墓地存在，有「圣剑」装备魔法卡装备的自己的「圣骑士」怪兽被战斗破坏送去墓地时才能发动。这张卡加入手卡。
function c51412776.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：从自己的卡组·墓地选1只「圣骑士」怪兽或者1张「圣剑」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51412776)
	e1:SetTarget(c51412776.target)
	e1:SetOperation(c51412776.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，有「圣剑」装备魔法卡装备的自己的「圣骑士」怪兽被战斗破坏送去墓地时才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetOperation(c51412776.checkop)
	c:RegisterEffect(e2)
	-- 这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+51412776)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,51412776)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c51412776.thcon)
	e3:SetTarget(c51412776.thtg)
	e3:SetOperation(c51412776.thop)
	c:RegisterEffect(e3)
end
-- 筛选可检索的卡：满足「圣骑士」怪兽或「圣剑」卡之一，且能够加入手卡的卡（用于从卡组·墓地检索）。
function c51412776.filter(c)
	return ((c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0x207a)) and c:IsAbleToHand()
end
-- ①效果发动前的合法性判断与操作信息预埋：若己方卡组·墓地存在符合条件的卡则可发动，并声明将要进行的操作是加入手牌（检索）。
function c51412776.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动时是否存在至少1张符合条件的卡（卡组·墓地的「圣骑士」怪兽或「圣剑」卡）。
	if chk==0 then return Duel.IsExistingMatchingCard(c51412776.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置本连锁的操作信息：将1张卡从卡组·墓地加入手牌（用于后续触发星尘龙、王家长眠之谷等效果判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：从己方卡组·墓地选择1张符合条件的卡（排除受王家长眠之谷影响的卡）加入手牌，并让对方确认。
function c51412776.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给己方玩家显示选择提示，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组·墓地选择1张满足条件且不受王家长眠之谷影响的卡（若存在王谷则其回收不受影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51412776.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌（检索或回收成功）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片（检索效果需要公开）。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定一张怪兽是否满足②的触发条件：它是「圣骑士」怪兽、因战斗破坏被送去墓地、控制者为tp，且装备区有「圣剑」装备魔法卡。
function c51412776.checkfilter(c,tp)
	return c:IsSetCard(0x107a) and c:IsReason(REASON_BATTLE) and c:IsControler(tp)
		and c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 监视场上怪兽离场事件：分别检查玩家0和玩家1是否有满足条件的『圣骑士』怪兽被战破；若有，则向墓地的这张卡发送自定义事件，记录可发动②的玩家（0、1或双方）。
function c51412776.checkop(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c51412776.checkfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c51412776.checkfilter,1,nil,1) then v=v+2 end
	if v>0 then
		local evp=({0,1,PLAYER_ALL})[v]
		-- 向墓地的这张卡触发自定义事件EVENT_CUSTOM+51412776，将战斗破坏发生的控制者信息写入ev，用于启动②效果的发动判定。
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+51412776,e,0,rp,ep,evp)
	end
end
-- ②效果的发动条件：仅当自定义事件记录的玩家（ev）是自己或双方时，自己才能发动（即只有被战破的圣骑士的控制者可以发动）。
function c51412776.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- ②效果发动时检查墓地中的这张卡能否加入手牌，并预设置操作信息。
function c51412776.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：这张卡将被加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与发动效果关联，则将其加入持有者手牌。
function c51412776.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将墓地中的这张卡加入持有者手牌。
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
