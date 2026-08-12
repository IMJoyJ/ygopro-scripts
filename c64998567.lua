--カース・オブ・ディアベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「迪亚贝尔」怪兽2只以上存在的场合，把自己场上1只怪兽送去墓地才能发动。对方场上的表侧表示卡全部破坏。
-- ②：这张卡从手卡·卡组中送去墓地的场合或者从中除外的场合才能发动。从卡组把「恶魔迪亚贝尔的诅咒」以外的1张「迪亚贝尔」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡片发动、破坏对方场上所有表侧表示卡）和②效果（从手卡·卡组送墓或除外时检索「迪亚贝尔」魔陷）。
function s.initial_effect(c)
	-- ①：自己场上有「迪亚贝尔」怪兽2只以上存在的场合，把自己场上1只怪兽送去墓地才能发动。对方场上的表侧表示卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组中送去墓地的场合或者从中除外的场合才能发动。从卡组把「恶魔迪亚贝尔的诅咒」以外的1张「迪亚贝尔」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判定函数：自己场上是否存在2只以上表侧表示的「迪亚贝尔」怪兽。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少2只表侧表示且属于「迪亚贝尔」系列（0x19b）的怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,2,nil,0x19b)
end
-- ①效果的Cost过滤函数：筛选自己场上可以作为Cost送去墓地的怪兽。
function s.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动代价（Cost）处理函数：把自己场上1只怪兽送去墓地。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查自己场上是否存在至少1只可以作为Cost送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择自己场上1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价（Cost）送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动准备（Target）函数：检查对方场上是否存在表侧表示的卡，并设置破坏的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查对方场上是否存在至少1张表侧表示的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示的卡。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏对方场上所有的表侧表示卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ①效果的效果处理（Operation）函数：破坏对方场上所有的表侧表示卡。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有表侧表示的卡。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	-- 破坏获取到的所有表侧表示卡。
	Duel.Destroy(sg,REASON_EFFECT)
end
-- ②效果的发动条件判定函数：检查这张卡此前的位置是否是手卡或卡组。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- ②效果的检索卡片过滤函数：筛选卡组中除「恶魔迪亚贝尔的诅咒」以外的「迪亚贝尔」魔法·陷阱卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x19b) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target）函数：检查卡组中是否存在可检索的卡，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：检查卡组中是否存在满足过滤条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理（Operation）函数：从卡组选择1张满足条件的「迪亚贝尔」魔陷加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
