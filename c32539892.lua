--イビー
-- 效果：
-- 这张卡被对方的卡的效果从手卡丢弃去墓地时，给与对方基本分1000分伤害。
function c32539892.initial_effect(c)
	-- 诱发必发效果，对应一速的【……发动】
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
-- 这张卡被对方的卡的效果从手卡丢弃去墓地时
function c32539892.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,0x4040)==0x4040 and rp==1-tp
end
-- 将对方基本分1000分伤害设为效果处理目标
function c32539892.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息此操作信息包含了效果处理中确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 给与对方基本分1000分伤害
function c32539892.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 以reason原因给与玩家造成value的伤害，返回实际收到的伤害值
	Duel.Damage(1-tp,1000,REASON_EFFECT)
end
