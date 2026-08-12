--ライトロード・ドルイド オルクス
-- 效果：
-- 只要这张卡在场上表侧表示存在，双方玩家不能把名字带有「光道」的怪兽作为魔法·陷阱·效果怪兽的效果的对象。此外，每次自己的结束阶段发动。从自己卡组上面把2张卡送去墓地。
function c7183277.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，双方玩家不能把名字带有「光道」的怪兽作为魔法·陷阱·效果怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c7183277.etarget)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 此外，每次自己的结束阶段发动。从自己卡组上面把2张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetDescription(aux.Stringid(7183277,0))  --"从卡组送2张卡去墓地"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c7183277.discon)
	e2:SetTarget(c7183277.distg)
	e2:SetOperation(c7183277.disop)
	c:RegisterEffect(e2)
end
-- 过滤不能成为效果对象的目标，限定为名字带有「光道」的怪兽。
function c7183277.etarget(e,c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 判断是否在自己的结束阶段，作为效果发动的条件。
function c7183277.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己。
	return tp==Duel.GetTurnPlayer()
end
-- 设置结束阶段送墓效果的发动检测与操作信息。
function c7183277.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为将自己卡组上方的2张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 执行结束阶段送墓效果的具体操作。
function c7183277.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将自己卡组最上方的2张卡送去墓地。
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
