--幻影騎士団マレヴォレンスサイス
-- 效果：
-- 暗属性3星怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「幻影骑士团」怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，自己把「超量龙」怪兽超量召唤的场合才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。
-- ③：这张卡被破坏的场合才能发动。超量怪兽以外的自己的除外状态的1张「幻影骑士团」卡加入手卡。
local s,id,o=GetID()
-- 初始化效果：注册超量召唤手续，以及①、②、③效果（从卡组特招怪兽效果、超量龙超量召唤时检索「升阶魔法」效果、被破坏时回收除外非超量卡片效果）。
function s.initial_effect(c)
	-- 设置超量召唤手续：暗属性3星怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组把1只「幻影骑士团」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，自己把「超量龙」怪兽超量召唤的场合才能发动。从卡组把1张「升阶魔法」魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合才能发动。超量怪兽以外的自己的除外状态的1张「幻影骑士团」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回收效果"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- ①效果的Cost代价处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤从卡组特殊召唤的怪兽：属于「幻影骑士团」系列的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的Target目标处理函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且卡组中存在可以特殊召唤的符合条件的「幻影骑士团」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的Operation具体操作处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若没有可用的怪兽区域空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只符合条件的「幻影骑士团」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤特殊召唤的怪兽：自己超量召唤成功的表侧表示的「超量龙」超量怪兽
function s.ocfilter(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_XYZ) and c:IsAllTypes(TYPE_XYZ+TYPE_MONSTER) and c:IsSetCard(0x2073) and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件函数：检测自己是否超量召唤了「超量龙」怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.ocfilter,1,nil,tp)
end
-- 过滤要加入手牌的魔法卡：属于「升阶魔法」系列的魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ②效果的Target目标处理函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的符合条件的「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的Operation具体操作处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「升阶魔法」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「升阶魔法」魔法卡送去手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤回收除外状态卡片的条件：除外状态的非超量怪兽的「幻影骑士团」卡片
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x10db) and not c:IsType(TYPE_XYZ) and c:IsAbleToHand()
end
-- ③效果的Target目标处理函数
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己除外状态的卡中是否存在符合条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置将除外卡片加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- ③效果的Operation具体操作处理函数
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张除外状态符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送去玩家的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
