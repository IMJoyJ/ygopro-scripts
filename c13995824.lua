--ボルテック・バイコーン
-- 效果：
-- 兽族调整＋调整以外的怪兽1只以上
-- 这张卡被对方破坏的场合，双方玩家从卡组上面把7张卡送去墓地。
function c13995824.initial_effect(c)
	-- 添加同调召唤手续，要求1只兽族调整和1只以上调整以外的怪兽作为素材
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
-- 效果发动时的条件判断函数，判断是否为对方破坏且破坏前控制者为当前玩家
function c13995824.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
-- 效果发动时的处理目标设置函数，设置将双方各7张卡送去墓地
function c13995824.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定将双方玩家的卡组各7张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,PLAYER_ALL,7)
end
-- 效果发动时的处理效果函数，执行将卡组最上端7张卡送去墓地的操作
function c13995824.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前玩家卡组最上端7张卡送去墓地
	Duel.DiscardDeck(tp,7,REASON_EFFECT)
	-- 将对方玩家卡组最上端7张卡送去墓地
	Duel.DiscardDeck(1-tp,7,REASON_EFFECT)
end
