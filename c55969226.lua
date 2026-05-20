--青竜の召喚士
-- 效果：
-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只龙族·战士族·魔法师族的通常怪兽加入手卡。
function c55969226.initial_effect(c)
	-- ①：这张卡从场上送去墓地的场合才能发动。从卡组把1只龙族·战士族·魔法师族的通常怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55969226,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c55969226.condition)
	e1:SetTarget(c55969226.target)
	e1:SetOperation(c55969226.operation)
	c:RegisterEffect(e1)
end
-- 检查这张卡是否是从场上送去墓地
function c55969226.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中属于龙族、战士族或魔法师族的通常怪兽，且可以加入手牌
function c55969226.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON+RACE_WARRIOR+RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 效果发动的目标确认与操作信息设置
function c55969226.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55969226.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行：从卡组选择1张符合条件的卡加入手牌并给对方确认
function c55969226.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c55969226.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
