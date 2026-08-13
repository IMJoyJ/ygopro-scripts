--イビー
-- 效果：
-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，给与对方基本分1000分伤害。
function c32539892.initial_effect(c)
	-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32539892,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c32539892.drcon)
	e1:SetTarget(c32539892.drtg)
	e1:SetOperation(c32539892.drop)
	c:RegisterEffect(e1)
end
-- 触发条件判断：这张卡离开前在手牌，且是因对方玩家的卡片效果被丢弃去墓地。
function c32539892.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040 and rp==1-tp
end
-- 效果发动判定：无需选择对象，满足条件时返回true，并设置将造成伤害的操作信息。
function c32539892.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次连锁的操作信息：给对方玩家造成1000点伤害（伤害效果，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理时执行：给对方造成1000点伤害。
function c32539892.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果伤害的形式给对方玩家造成1000点基本分伤害。
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
