--幻惑の見習い魔術師
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻惑之见习魔术师」以外的1只幻想魔族怪兽加入手卡。
-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召规则，②召唤·特召成功时检索幻想魔族怪兽，③自身与战斗怪兽不被战破。
function s.initial_effect(c)
	-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。这个卡名的①的方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「幻惑之见习魔术师」以外的1只幻想魔族怪兽加入手卡。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索幻想魔族怪兽"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(s.indtg)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件判定：检查怪兽区域是否有空位，以及手卡中是否存在除自身以外的至少1张卡。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区域是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在除这张卡以外的至少1张卡（作为丢弃的代价）。
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的具体操作：丢弃1张手卡作为代价，然后特殊召唤自身。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要丢弃的手卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家从手卡选择除这张卡以外的1张卡。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,c)
	-- 将选中的卡作为代价丢弃送去墓地。
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中除「幻惑之见习魔术师」以外的、可以加入手卡的幻想魔族怪兽。
function s.filter(c)
	return not c:IsCode(id) and c:IsRace(RACE_ILLUSION) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在符合条件的怪兽，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在除「幻惑之见习魔术师」以外的幻想魔族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理：从卡组选择1只符合条件的幻想魔族怪兽加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的幻想魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 战斗不破坏效果的目标过滤：适用于自身以及与自身进行战斗的对方怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
