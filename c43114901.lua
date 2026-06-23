--ジェムナイト・サニクス
-- 效果：
-- 这张卡在墓地或者场上表侧表示存在的场合，当作通常怪兽使用。场上表侧表示存在的这张卡可以作当成通常召唤使用的再度召唤，这张卡变成当作效果怪兽使用并得到以下效果。
-- ●这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「宝石骑士」的卡加入手卡。
function c43114901.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●这张卡战斗破坏对方怪兽送去墓地时，可以从自己卡组把1张名字带有「宝石骑士」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43114901,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c43114901.thcon)
	e1:SetTarget(c43114901.thtg)
	e1:SetOperation(c43114901.thop)
	c:RegisterEffect(e1)
end
-- 判断是否满足效果发动条件，包括是否为再度召唤状态、被战斗破坏的怪兽是否为自身、是否在墓地且为战斗破坏
function c43114901.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前效果是否作用于再度召唤状态的二重怪兽
	if not aux.IsDualState(e) then return false end
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选卡组中名字带有「宝石骑士」且可以加入手牌的卡片
function c43114901.filter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 设置效果的发动目标，检查卡组中是否存在满足条件的卡片并设置操作信息
function c43114901.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c43114901.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡为1张加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，负责选择并把符合条件的卡加入手牌
function c43114901.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c43114901.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
