--二角獣レーム
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，从对方卡组上面把2张卡送去墓地。
function c58685438.initial_effect(c)
	-- 这张卡作为同调召唤的素材送去墓地的场合，从对方卡组上面把2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58685438,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c58685438.ddcon)
	e1:SetTarget(c58685438.ddtg)
	e1:SetOperation(c58685438.ddop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡当前在墓地，且作为同调素材送去墓地
function c58685438.ddcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 设置效果发动的目标玩家为对方，并设置卡组送墓的操作信息
function c58685438.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将效果的目标玩家设置为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息，表示该效果包含将对方卡组最上方的2张卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,2)
end
-- 执行效果处理：获取目标玩家，并将其卡组最上方的2张卡送去墓地
function c58685438.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即对方）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 因效果将目标玩家卡组最上方的2张卡送去墓地
	Duel.DiscardDeck(p,2,REASON_EFFECT)
end
