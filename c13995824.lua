--ボルテック・バイコーン
-- 效果：
-- 兽族调整＋调整以外的怪兽1只以上
-- 这张卡被对方破坏的场合，双方玩家从卡组上面把7张卡送去墓地。
function c13995824.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为兽族，调整以外的怪兽至少1只（没有额外上限），作为同调素材才能进行同调召唤。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡被对方破坏的场合，双方玩家从卡组上面把7张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13995824,0))  --"卡组破坏"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c13995824.ddcon)
	e1:SetTarget(c13995824.ddtg)
	e1:SetOperation(c13995824.ddop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定：这张卡被对方（rp==1-tp）破坏，并且这张卡在破坏前的控制者为我方（tp），满足时才可发动。
function c13995824.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动时的合法检测：chk==0时返回true表示满足发动条件；随后设置本次效果的操作信息，供规则检测使用。
function c13995824.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的操作信息：该效果涉及双方玩家（PLAYER_ALL）从卡组将7张卡送去墓地，由于不取对象，对象暂设为0。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,PLAYER_ALL,7)
end
-- 效果处理时的操作：双方玩家分别从卡组上方将7张卡送去墓地。
function c13995824.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 当前效果持有者tp从卡组上方把7张卡送去墓地，原因为效果。
	Duel.DiscardDeck(tp,7,REASON_EFFECT)
	-- 对方玩家（1-tp）从卡组上方把7张卡送去墓地，原因为效果。
	Duel.DiscardDeck(1-tp,7,REASON_EFFECT)
end
