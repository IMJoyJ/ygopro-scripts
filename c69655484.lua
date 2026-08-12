--Em影絵師シャドー・メイカー
-- 效果：
-- 5星怪兽×3
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，从卡组把1只「娱乐法师」怪兽送去墓地才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。
-- ②：这张卡为对象的效果发动时，把这张卡1个超量素材取除才能发动。从额外卡组把1只「娱乐法师 影绘师」特殊召唤。
-- ③：这张卡的超量素材全部被取除的场合才能发动。从自己墓地把1只「娱乐法师」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：设置超量召唤手续，并注册①②③效果
function s.initial_effect(c)
	-- 开启全局标记以监听超量素材被取除的事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 添加超量召唤手续：5星怪兽×3
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，从卡组把1只「娱乐法师」怪兽送去墓地才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索「升阶魔法」"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡为对象的效果发动时，把这张卡1个超量素材取除才能发动。从额外卡组把1只「娱乐法师 影绘师」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤「娱乐法师 影绘师」"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡的超量素材全部被取除的场合才能发动。从自己墓地把1只「娱乐法师」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤墓地"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_DETACH_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中可以送去墓地的「娱乐法师」怪兽
function s.costfilter(c)
	return c:IsSetCard(0xc6) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- ①效果的发动代价：取除1个超量素材，并将卡组1只「娱乐法师」怪兽送去墓地
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付代价：这张卡有1个以上的超量素材，且卡组存在可送去墓地的「娱乐法师」怪兽
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_DECK,0,1,nil) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的「娱乐法师」怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：卡组中可以加入手牌的「升阶魔法」魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组是否存在「升阶魔法」魔法卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在可以加入手牌的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组将1张「升阶魔法」魔法卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「升阶魔法」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：这张卡成为效果的对象时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被作为对象的卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return tg and tg:IsContains(c)
end
-- ②效果的发动代价：取除这张卡的1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：额外卡组中可以特殊召唤的同名卡「娱乐法师 影绘师」
function s.spfilter(c,e,tp)
	return c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且自身额外卡组怪兽区域有可用的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备：检查额外卡组是否存在可特殊召唤的同名卡，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以特殊召唤的「娱乐法师 影绘师」
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：从额外卡组特殊召唤1只「娱乐法师 影绘师」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中第一张满足条件的「娱乐法师 影绘师」
	local tg=Duel.GetFirstMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将该怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：这张卡的超量素材数量为0
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():GetCount()==0
end
-- 过滤条件：墓地中可以特殊召唤的「娱乐法师」怪兽
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0xc6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动准备：检查怪兽区域是否有空位，且墓地是否存在可特殊召唤的「娱乐法师」怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且墓地存在可以特殊召唤的「娱乐法师」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果的处理：从自己墓地特殊召唤1只「娱乐法师」怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时场上没有可用的怪兽区域空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只不受「王家长眠之谷」影响的「娱乐法师」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
