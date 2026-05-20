--罪宝の欺き
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把自己的手卡·场上1只怪兽解放才能发动。从卡组把1张「蓟花」卡加入手卡。
-- ②：怪兽被送去对方墓地的场合，若自己场上有「蓟花」怪兽存在则能发动。对方失去1500基本分，自己回复1500基本分。
-- ③：魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合的结束阶段才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化函数，注册这张卡的发动效果、①的检索效果、②的失去与回复基本分效果，以及③的送墓标记与结束阶段盖放效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己的手卡·场上1只怪兽解放才能发动。从卡组把1张「蓟花」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：怪兽被送去对方墓地的场合，若自己场上有「蓟花」怪兽存在则能发动。对方失去1500基本分，自己回复1500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"失去&回复基本分"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.lpcon)
	e3:SetTarget(s.lptg)
	e3:SetOperation(s.lpop)
	c:RegisterEffect(e3)
	-- ③：魔法与陷阱区域的表侧表示的这张卡被送去墓地的回合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- 结束阶段才能发动。这张卡在自己场上盖放。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"在自己场上盖放"
	e5:SetCategory(CATEGORY_SSET)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCountLimit(1,id+o*2)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
-- 过滤条件：怪兽卡
function s.cfilter1(c,tp)
	return c:IsType(TYPE_MONSTER)
end
-- ①号效果的发动代价：解放自己手卡·场上的一只怪兽
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·场上是否存在可解放的怪兽作为发动代价
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter1,1,REASON_COST,true,nil,tp) end
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家选择1张手卡或场上的怪兽作为解放
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter1,1,1,REASON_COST,true,nil,tp)
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的「蓟花」卡片
function s.thfilter(c)
	return c:IsSetCard(0x1bc) and c:IsAbleToHand()
end
-- ①号效果的发动准备：检查卡组中是否存在可检索的「蓟花」卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「蓟花」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的效果处理：从卡组选择1张「蓟花」卡加入手牌，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「蓟花」卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：属于对方玩家且送去墓地的怪兽卡
function s.cfilter2(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_MONSTER)
end
-- ②号效果的发动条件：有怪兽被送去对方的墓地
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,1-tp)
end
-- ②号效果的发动准备：检查自己场上是否存在表侧表示的「蓟花」怪兽，并设置回复生命值的操作信息
function s.lptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「蓟花」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsSetCard,Card.IsFaceup),tp,LOCATION_MZONE,0,1,nil,0x1bc) end
	-- 设置回复1500生命值的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1500)
end
-- ②号效果的效果处理：对方失去1500基本分，自己回复1500基本分
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方当前的生命值
	local lp=Duel.GetLP(1-tp)
	-- 将对方的生命值减少1500点（使其失去1500基本分）
	Duel.SetLP(1-tp,lp-1500)
	-- 如果对方的生命值确实减少了，则自己回复1500生命值
	if Duel.GetLP(1-tp)<lp then Duel.Recover(tp,1500,REASON_EFFECT) end
end
-- 标记效果的发动条件：这张卡在魔法与陷阱区域以表侧表示存在并被送去墓地
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 标记效果的效果处理：为这张卡注册一个持续到回合结束的标志，用于在结束阶段发动盖放效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③号效果的发动条件：这张卡在本回合内曾从魔陷区表侧表示送去墓地（检查标志是否存在）
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- ③号效果的发动准备：检查这张卡是否可以盖放，并设置卡片离开墓地的操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置将这张卡从墓地移出的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ③号效果的效果处理：在不受「王家长眠之谷」影响的情况下，将这张卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果这张卡仍存在于墓地且不受「王家长眠之谷」影响，则将其在自己场上盖放
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end
