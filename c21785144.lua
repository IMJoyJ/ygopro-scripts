--ライトロード・ドラゴン グラゴニス
-- 效果：
-- 这张卡的攻击力·守备力上升自己墓地存在的名字带有「光道」的怪兽卡种类×300的数值。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这张卡在自己场上表侧表示存在的场合，每次自己的结束阶段，从卡组上面把3张卡送去墓地。
function c21785144.initial_effect(c)
	-- 效果原文：这张卡的攻击力上升自己墓地存在的名字带有「光道」的怪兽卡种类×300的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c21785144.value)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡的守备力上升自己墓地存在的名字带有「光道」的怪兽卡种类×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c21785144.value)
	c:RegisterEffect(e2)
	-- 效果原文：这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 效果原文：这张卡在自己场上表侧表示存在的场合，每次自己的结束阶段，从卡组上面把3张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetDescription(aux.Stringid(21785144,0))  --"从卡组送3张卡去墓地"
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c21785144.discon)
	e4:SetTarget(c21785144.distg)
	e4:SetOperation(c21785144.disop)
	c:RegisterEffect(e4)
end
-- 检索满足条件的卡片组：名字带有「光道」的怪兽卡。
function c21785144.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 计算满足条件的卡片种类数并乘以300作为攻击力和守备力的提升值。
function c21785144.value(e,c)
	-- 检索满足条件的卡片组：自己墓地存在的名字带有「光道」的怪兽卡。
	local g=Duel.GetMatchingGroup(c21785144.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*300
end
-- 判断是否为当前回合玩家触发效果。
function c21785144.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家触发效果。
	return tp==Duel.GetTurnPlayer()
end
-- 设置连锁操作信息：从卡组送3张卡去墓地。
function c21785144.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：从卡组送3张卡去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 执行效果：从卡组上面把3张卡送去墓地。
function c21785144.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行效果：从卡组上面把3张卡送去墓地。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
