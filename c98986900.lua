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
-- 卡片的初始化处理，定义各个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,9)
	-- ①：每次对方把魔法卡以外的卡的效果发动，给这张卡放置1个魔力指示物（最多9个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	-- 设置操作为记录该卡在连锁发生时存在于场上
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
●从卡组把1张魔法卡或1只魔法师族效果怪兽加入手卡。
●从手卡·卡组把1只魔法师族怪兽特殊召唤。
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
s.mentioned_counter={
	[0x1]=true,
}
-- 效果的触发条件：发动的效果是怪兽或陷阱卡的效果，且是对方发动，并且该卡在连锁发动时存在于场上
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:IsActiveType(TYPE_TRAP+TYPE_MONSTER) and rp==1-tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 给这张卡放置1个魔力指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x1,1)
end
-- 如果是在检查阶段，则判断该卡是否因为战斗或效果被破坏，且不是代替破坏，且能取除1个超量素材
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 让玩家选择是否适用代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 取除这张卡的1个超量素材作为代替破坏
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
-- 检查并取除这张卡的3个魔力指示物作为发动代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	c:RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 加入手卡的过滤条件：是魔法卡，或者是魔法师族效果怪兽，且能加入手卡
function s.thfilter(c)
	return (c:IsType(TYPE_SPELL) or c:IsType(TYPE_EFFECT) and c:IsRace(RACE_SPELLCASTER)) and c:IsAbleToHand()
end
-- 特殊召唤的过滤条件：是魔法师族怪兽，且能被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：检查是否可以执行加入手卡或者特殊召唤操作
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己卡组中是否存在可以加入手卡的卡
		local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己场上是否有空余的怪兽区域
		local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己手卡或卡组中是否存在可以特殊召唤的怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
		return b1 or b2
	end
end
-- 效果处理：根据可执行的操作让玩家选择其中之一适用
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组中是否存在可以加入手卡的卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 判断自己场上是否有空余的怪兽区域
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡或卡组中是否存在可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
	if not (b1 or b2) then return end
	local op=aux.SelectFromOptions(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})  --"从卡组加入手卡/从手卡·卡组特殊召唤"
	if op==1 then
		-- 向玩家发送提示消息：请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张符合条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	else if op==2 then
		-- 向玩家发送提示消息：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或卡组中选择1只符合条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 将选中的怪兽特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	end
end
