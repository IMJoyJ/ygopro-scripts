--ライトロード・メイデン ミネルバ
-- 效果：
-- ①：这张卡召唤时才能发动。把持有自己墓地的「光道」怪兽种类数量以下的等级的1只龙族·光属性怪兽从卡组加入手卡。
-- ②：这张卡从手卡·卡组送去墓地的场合发动。从自己卡组上面把1张卡送去墓地。
-- ③：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
function c40164421.initial_effect(c)
	-- ①：这张卡召唤时才能发动。把持有自己墓地的「光道」怪兽种类数量以下的等级的1只龙族·光属性怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40164421,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40164421.thtg)
	e1:SetOperation(c40164421.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡·卡组送去墓地的场合发动。从自己卡组上面把1张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40164421,1))  --"送墓"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c40164421.discon)
	e2:SetTarget(c40164421.distg)
	e2:SetOperation(c40164421.disop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段发动。从自己卡组上面把2张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40164421,2))  --"送墓"
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c40164421.discon2)
	e3:SetTarget(c40164421.distg2)
	e3:SetOperation(c40164421.disop2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选墓地中的「光道」怪兽
function c40164421.cfilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 过滤函数，用于筛选等级不超过指定值、种族为龙族、属性为光属性且能加入手牌的怪兽
function c40164421.thfilter(c,lv)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 效果处理时的条件判断，检查卡组中是否存在满足条件的怪兽
function c40164421.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家墓地中所有「光道」怪兽的集合
		local g=Duel.GetMatchingGroup(c40164421.cfilter,tp,LOCATION_GRAVE,0,nil)
		local ct=g:GetClassCount(Card.GetCode)
		-- 检查卡组中是否存在满足条件的怪兽
		return Duel.IsExistingMatchingCard(c40164421.thfilter,tp,LOCATION_DECK,0,1,nil,ct)
	end
	-- 设置效果处理信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行检索并加入手牌的操作
function c40164421.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家墓地中所有「光道」怪兽的集合
	local g=Duel.GetMatchingGroup(c40164421.cfilter,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的怪兽
	local sg=Duel.SelectMatchingCard(tp,c40164421.thfilter,tp,LOCATION_DECK,0,1,1,nil,ct)
	if sg:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 判断效果发动条件，确保该卡是从手卡或卡组送去墓地
function c40164421.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- 设置效果处理信息，表示将从卡组送去墓地1张卡
function c40164421.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置效果处理信息，表示将从卡组送去墓地1张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 效果处理函数，执行从卡组送去墓地的操作
function c40164421.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 从指定玩家卡组最上方送去墓地指定数量的卡
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end
-- 判断效果发动条件，确保是当前回合玩家的结束阶段
function c40164421.discon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置效果处理信息，表示将从卡组送去墓地2张卡
function c40164421.distg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息，表示将从卡组送去墓地2张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 效果处理函数，执行从卡组送去墓地2张卡的操作
function c40164421.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前回合玩家卡组最上方送去墓地2张卡
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
