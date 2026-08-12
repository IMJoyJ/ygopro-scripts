--バーバリアン・エコーズ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只战士族·地属性·5星怪兽加入手卡。那个场合，再选自己1张手卡丢弃。
-- ②：1回合1次，场上的怪兽回到手卡的场合，可以从以下效果选择1个发动（伤害步骤也能发动）。
-- ●从卡组把1张「野蛮人之怒」或「野蛮人之吼」加入手卡。
-- ●场上1只表侧表示怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 将「野蛮人之怒」与「野蛮人之吼」记录在此卡的关联卡片列表中。
	aux.AddCodeList(c,42233477,78621186)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只战士族·地属性·5星怪兽加入手卡。那个场合，再选自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，场上的怪兽回到手卡的场合，可以从以下效果选择1个发动（伤害步骤也能发动）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索或怪兽变成里侧"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中等级5的战士族·地属性且能加入手牌的怪兽。
function s.filter(c)
	return c:IsLevel(5) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- 魔法卡发动时的效果处理函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的战士族·地属性·5星怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 如果卡组中存在满足条件的怪兽，询问玩家是否发动检索效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否从卡组把1只战士族·地属性·5星怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,sg)
		-- 中断当前效果处理，使后续的丢弃手牌处理不与检索同时进行。
		Duel.BreakEffect()
		-- 玩家选择自己1张手牌丢弃。
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 过滤条件：原本在怪兽区域的卡。
function s.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 触发条件：场上的怪兽回到手牌的场合。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 过滤条件：卡组中卡名为「野蛮人之怒」或「野蛮人之吼」且能加入手牌的卡。
function s.thfilter(c)
	return c:IsCode(42233477,78621186) and c:IsAbleToHand()
end
-- 过滤条件：场上表侧表示且可以变成里侧表示的怪兽。
function s.tsfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果②的发动准备与分支选择处理。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己卡组中是否存在「野蛮人之怒」或「野蛮人之吼」。
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查场上是否存在可以变成里侧守备表示的表侧表示怪兽。
	local b2=Duel.IsExistingMatchingCard(s.tsfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	-- 让玩家从可用的分支效果中选择一个。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,3)},  --"从卡组把1张「野蛮人之怒」或者「野蛮人之吼」加入手卡"
			{b2,aux.Stringid(id,4)})  --"场上1只表侧表示怪兽变成里侧守备表示"
	e:SetLabel(op)
	local g=nil
	if op==1 then
		-- 设置效果分类为检索卡组，并预估操作数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	end
	if op==2 then
		-- 设置效果分类为改变表示形式，并预估操作数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
		e:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	end
end
-- 效果②的分支效果执行函数。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组中选择1张「野蛮人之怒」或「野蛮人之吼」。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	if op==2 then
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 玩家选择场上1只表侧表示的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.tsfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 选中该怪兽并显示选择动画。
			Duel.HintSelection(g)
			-- 将选中的怪兽变成里侧守备表示。
			Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
		end
	end
end
