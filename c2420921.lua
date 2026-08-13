--ライトロード・スピリット シャイア
-- 效果：
-- 墓地中每有1种名字带有「光道」的怪兽卡，这张卡的攻击力就上升300。每次自己的结束阶段时，将自己卡组最上方的2张卡送去墓地。
function c2420921.initial_effect(c)
	-- 对应效果原文：“墓地中每有1种名字带有「光道」的怪兽卡，这张卡的攻击力就上升300。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c2420921.value)
	c:RegisterEffect(e1)
	-- 对应效果原文：“每次自己的结束阶段时，将自己卡组最上方的2张卡送去墓地。”
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
-- 定义过滤器：筛选出名字带有「光道」的怪兽卡，用于统计墓地中满足条件的怪兽种类数。
function c2420921.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力上升数值：取得己方墓地中所有名字带有「光道」的怪兽卡，按卡名去重得到种类数，乘以300作为攻击力提升值。
function c2420921.value(e,c)
	-- 获取己方墓地中所有满足「光道」怪兽条件的卡，存入临时组g中。
	local g=Duel.GetMatchingGroup(c2420921.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*300
end
-- 结束阶段效果的发动条件判定函数：仅当当前是这张卡的控制者自己的结束阶段时才满足发动条件。
function c2420921.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁处理时的回合玩家是否为这张卡的控制者，即只有自己的回合结束阶段才会触发。
	return tp==Duel.GetTurnPlayer()
end
-- 效果发动时的目标设定函数：在效果发动时无需选择对象，并设置本次操作将使己方卡组最上方2张卡送去墓地。
function c2420921.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣告本次效果包含将卡组送入墓地的分类，数量为2张，对象不确定故传nil。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 效果处理函数：实际执行将己方卡组最上方2张卡送去墓地的操作。
function c2420921.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将己方卡组最上方2张卡送去墓地，完成“将自己卡组最上方的2张卡送去墓地”的处理。
	Duel.DiscardDeck(tp,2,REASON_EFFECT)
end
