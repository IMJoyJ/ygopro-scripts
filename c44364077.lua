--EMヘイタイガー
-- 效果：
-- 「娱乐伙伴 士兵虎」的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只「娱乐伙伴」灵摆怪兽加入手卡。
function c44364077.initial_effect(c)
	-- 「娱乐伙伴 士兵虎」的效果1回合只能使用1次。①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只「娱乐伙伴」灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44364077,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCountLimit(1,44364077)
	e1:SetCondition(c44364077.condition)
	e1:SetTarget(c44364077.target)
	e1:SetOperation(c44364077.operation)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：本卡自身仍与本次战斗相关联（即没有因战斗而离场），战斗对象位于墓地且为怪兽，满足“这张卡战斗破坏对方怪兽送去墓地时”。
function c44364077.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 定义检索过滤条件：卡组中存在符合“娱乐伙伴”字段、灵摆怪兽且可以被加入手卡的卡。
function c44364077.filter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 效果发动时的目标阶段处理：先确认卡组中是否有符合条件的卡（决定能否发动），再设置本次操作信息为从卡组检索1张加入手卡。
function c44364077.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 仅在发动时点（chk==0）检查卡组中是否存在至少1张满足条件的卡，作为效果可否发动的合法性判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c44364077.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把持有者tp的卡组中的1张卡加入手卡，但具体卡片效果处理时才确定，因此targets为nil，用于连锁检测和星尘龙等卡片的应对。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的操作：从己方卡组选择1张符合条件的“娱乐伙伴”灵摆怪兽加入手卡，并向对手确认。
function c44364077.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家弹出选择提示，提示语为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组中选出1张满足检索过滤条件的卡（必须是符合条件的“娱乐伙伴”灵摆怪兽）。
	local g=Duel.SelectMatchingCard(tp,c44364077.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选出的卡送入其持有者的手卡，操作原因为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对手确认，以公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
