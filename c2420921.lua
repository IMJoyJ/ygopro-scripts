--ライトロード・スピリット シャイア
-- 效果：
-- 墓地中每有1种名字带有「光道」的怪兽卡，这张卡的攻击力就上升300。每次自己的结束阶段时，将自己卡组最上方的2张卡送去墓地。
function c2420921.initial_effect(c)
	-- 墓地中每有1种名字带有「光道」的怪兽卡，这张卡的攻击力就上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c2420921.value)
	c:RegisterEffect(e1)
	-- 每次自己的结束阶段时，将自己卡组最上方的2张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetDescription(aux.Stringid(2420921,0))  --"从卡组送2张卡去墓地"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c2420921.discon)
	e2:SetTarget(c2420921.distg)
	e2:SetOperation(c2420921.disop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选墓地里名字带有「光道」的怪兽卡
function c2420921.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 计算墓地中不同名字的「光道」怪兽卡数量，并乘以300作为攻击力加成
function c2420921.value(e,c)
	-- 获取当前玩家墓地中所有名字带有「光道」的怪兽卡组成的组
	local g=Duel.GetMatchingGroup(c2420921.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*300
end
-- 判断是否为当前回合玩家触发效果
function c2420921.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否为回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 设置发动时的操作信息，指定将2张卡从卡组送去墓地
function c2420921.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，指定处理2张卡从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 效果发动时执行的操作，将卡组最上方的2张卡送去墓地
function c2420921.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行将卡组最上方2张卡送去墓地的操作
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
