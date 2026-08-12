--聖杯の継承
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从自己的卡组·墓地选1只「圣骑士」怪兽或者1张「圣剑」卡加入手卡。
-- ②：这张卡在墓地存在，有「圣剑」装备魔法卡装备的自己的「圣骑士」怪兽被战斗破坏送去墓地时才能发动。这张卡加入手卡。
function c51412776.initial_effect(c)
	-- ①：从自己的卡组·墓地选1只「圣骑士」怪兽或者1张「圣剑」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,51412776)
	e1:SetTarget(c51412776.target)
	e1:SetOperation(c51412776.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，有「圣剑」装备魔法卡装备的自己的「圣骑士」怪兽被战斗破坏送去墓地时才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetOperation(c51412776.checkop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
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
-- 过滤函数，用于检索满足条件的「圣骑士」怪兽或「圣剑」卡
function c51412776.filter(c)
	return ((c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0x207a)) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，检查是否满足检索条件
function c51412776.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c51412776.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示将要执行回手牌和检索的效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的发动处理函数，选择并把符合条件的卡加入手牌
function c51412776.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c51412776.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 用于判断是否满足②效果发动条件的过滤函数
function c51412776.checkfilter(c,tp)
	return c:IsSetCard(0x107a) and c:IsReason(REASON_BATTLE) and c:IsControler(tp)
		and c:GetEquipCount()>0 and c:GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x207a)
end
-- 当有怪兽离场时触发的处理函数，检查是否有符合条件的「圣骑士」怪兽被战斗破坏并装备了「圣剑」
function c51412776.checkop(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c51412776.checkfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c51412776.checkfilter,1,nil,1) then v=v+2 end
	if v>0 then
		local evp=({0,1,PLAYER_ALL})[v]
		-- 触发自定义事件，通知②效果可以发动
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+51412776,e,0,rp,ep,evp)
	end
end
-- 判断是否满足②效果发动条件
function c51412776.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- ②效果发动时的处理函数，设置操作信息
function c51412776.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示将要执行回手牌的效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的发动处理函数，把自身加入手牌
function c51412776.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身加入手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
