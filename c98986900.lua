--セレマテック・クラティス
-- 效果：
-- 8星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：每次对方把魔法卡以外的卡的效果发动，给这张卡放置1个魔力指示物（最多9个）。
-- ②：把这张卡3个魔力指示物取除才能发动。从以下效果让1个适用。
-- ●从卡组把1张魔法卡或1只魔法师族效果怪兽加入手卡。
-- ●从手卡·卡组把1只魔法师族怪兽特殊召唤。
-- ③：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
local s,id,o=GetID()
-- 初始化函数：设置XYZ召唤手续、魔力指示物上限，并注册卡片的所有效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置XYZ召唤手续：8星怪兽×2
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,9)
	-- ①：每次对方把魔法卡以外的卡的效果发动，给这张卡放置1个魔力指示物（最多9个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	-- 在连锁发生时，标记这张卡在场上存在
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：每次对方把魔法卡以外的卡的效果发动，给这张卡放置1个魔力指示物（最多9个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetTarget(s.dreptg)
	e3:SetOperation(s.drepop)
	c:RegisterEffect(e3)
	-- ②：把这张卡3个魔力指示物取除才能发动。从以下效果让1个适用。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.cost)
	e4:SetTarget(s.stg)
	e4:SetOperation(s.sop)
	c:RegisterEffect(e4)
end
-- 检查发动效果的卡是否为魔法卡以外（怪兽或陷阱），是否由对方发动，且连锁发生时此卡已在场上
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_MONSTER) and rp==1-tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 给这张卡放置1个魔力指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 检查自身是否因战斗或效果将被破坏，且自身拥有至少1个超量素材
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 取除这张卡的1个超量素材作为代替破坏的执行
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
-- 效果②的Cost：取除这张卡的3个魔力指示物
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	c:RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 过滤条件：卡组中的魔法卡，或者魔法师族效果怪兽
function s.thfilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_EFFECT) and c:IsRace(RACE_SPELLCASTER)) and c:IsAbleToHand()
end
-- 过滤条件：手卡或卡组中的魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查是否能适用“从卡组检索”或“从手卡·卡组特召”中的至少一个效果
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查卡组中是否存在可检索的魔法卡或魔法师族效果怪兽
		local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查己方怪兽区域是否有空位
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡或卡组中是否存在可特殊召唤的魔法师族怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		return b1 or b2
	end
end
-- 效果②的处理：让玩家选择适用“检索”或“特殊召唤”中的一个，并执行对应操作
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在可检索的卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查己方怪兽区域是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在可特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
	if not (b1 or b2) then return end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})  --"从卡组加入手卡/从手卡·卡组特殊召唤"
	if op==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	else if op==2 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从手卡或卡组选择1只满足条件的魔法师族怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
end
