--ヴァイロン・デルタ
-- 效果：
-- 调整＋调整以外的光属性怪兽1只以上
-- 这张卡表侧守备表示存在的场合，自己的结束阶段时可以从自己卡组选择1张装备魔法卡加入手卡。
function c45215453.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的光属性怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- 这张卡表侧守备表示存在的场合，自己的结束阶段时可以从自己卡组选择1张装备魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45215453,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c45215453.thcon)
	e1:SetTarget(c45215453.thtg)
	e1:SetOperation(c45215453.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断函数，判断是否为自己的结束阶段且自身为守备表示
function c45215453.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为效果持有者且自身处于守备表示
	return Duel.GetTurnPlayer()==tp and e:GetHandler():IsDefensePos()
end
-- 过滤函数，用于筛选可加入手牌的装备魔法卡
function c45215453.filter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，检查卡组中是否存在满足条件的装备魔法卡并设置操作信息
function c45215453.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张装备魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c45215453.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将从卡组检索1张装备魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，选择并把装备魔法卡加入手牌并确认对方查看
function c45215453.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or c:IsAttackPos() or not c:IsRelateToEffect(e) then return end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c45215453.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的装备魔法卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
