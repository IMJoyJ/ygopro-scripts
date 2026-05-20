--バイオファルコン
-- 效果：
-- 这张卡在场上表侧表示存在的场合自己场上存在的机械族怪兽被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1000以下的机械族怪兽加入手卡。
function c74130411.initial_effect(c)
	-- 这张卡在场上表侧表示存在的场合自己场上存在的机械族怪兽被战斗破坏送去墓地时，可以从自己卡组把1只攻击力1000以下的机械族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74130411,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c74130411.thcon)
	e1:SetTarget(c74130411.thtg)
	e1:SetOperation(c74130411.thop)
	c:RegisterEffect(e1)
end
-- 过滤条件：原本控制者为自己、被战斗破坏并送去墓地的机械族怪兽
function c74130411.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsRace(RACE_MACHINE) and c:IsReason(REASON_BATTLE)
end
-- 发动条件：被战斗破坏送去墓地的卡中存在满足过滤条件的怪兽
function c74130411.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74130411.cfilter,1,nil,tp)
end
-- 过滤条件：卡组中攻击力1000以下的机械族怪兽且可以加入手卡
function c74130411.filter(c)
	return c:IsAttackBelow(1000) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果发动靶向：检查卡组中是否存在符合条件的卡，并设置检索的操作信息
function c74130411.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c74130411.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的怪兽加入手卡并给对方确认
function c74130411.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c74130411.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
