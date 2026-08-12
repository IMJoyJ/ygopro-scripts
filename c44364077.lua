--EMヘイタイガー
-- 效果：
-- 「娱乐伙伴 士兵虎」的效果1回合只能使用1次。
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只「娱乐伙伴」灵摆怪兽加入手卡。
function c44364077.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只「娱乐伙伴」灵摆怪兽加入手卡。
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
-- 判断是否满足效果发动条件：自身参与战斗且战斗破坏的怪兽在墓地且为怪兽卡
function c44364077.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 过滤函数：检索满足条件的「娱乐伙伴」灵摆怪兽（可加入手牌）
function c44364077.filter(c)
	return c:IsSetCard(0x9f) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 设置效果的发动目标：从卡组检索1只符合条件的灵摆怪兽
function c44364077.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：卡组中是否存在至少1张符合条件的灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44364077.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将要从卡组检索1张灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数：提示选择并检索符合条件的灵摆怪兽加入手牌
function c44364077.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c44364077.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
