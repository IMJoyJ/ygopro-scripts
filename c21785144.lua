--ライトロード・ドラゴン グラゴニス
-- 效果：
-- 这张卡的攻击力·守备力上升自己墓地存在的名字带有「光道」的怪兽卡种类×300的数值。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这张卡在自己场上表侧表示存在的场合，每次自己的结束阶段，从卡组上面把3张卡送去墓地。
function c21785144.initial_effect(c)
	-- 这张卡的攻击力·守备力上升自己墓地存在的名字带有「光道」的怪兽卡种类×300的数值。（对应攻击力上升效果）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c21785144.value)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力·守备力上升自己墓地存在的名字带有「光道」的怪兽卡种类×300的数值。（对应守备力上升效果）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c21785144.value)
	c:RegisterEffect(e2)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 这张卡在自己场上表侧表示存在的场合，每次自己的结束阶段，从卡组上面把3张卡送去墓地。
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
-- 过滤函数：筛选出自己墓地中持有卡名含有「光道」字段的怪兽卡。
function c21785144.filter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER)
end
-- 攻击力/守备力上升值的计算函数：获取自己墓地中名字带有「光道」的怪兽卡，按卡名分类计数种类数，再乘以300作为上升数值。
function c21785144.value(e,c)
	-- 获取当前效果持有者的控制者墓地中所有满足「光道」怪兽过滤条件的卡，组成一个卡组对象。
	local g=Duel.GetMatchingGroup(c21785144.filter,c:GetControler(),LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return ct*300
end
-- 诱发效果的发动条件：当前回合玩家必须是效果持有者，即只在己方回合（结束阶段）才会发动。
function c21785144.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果的控制者是否就是当前回合玩家，确保只在己方结束阶段满足发动条件。
	return tp==Duel.GetTurnPlayer()
end
-- 目标设定函数：该效果在发动时无需选择对象，直接判定可以处理，并设置本次操作信息为从卡组送去墓地。
function c21785144.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理包含“从卡组送去墓地”的效果分类，预计将控制者tp的卡组最上方3张送去墓地（不指定具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果处理函数：实际执行从控制者卡组上方丢弃3张卡送去墓地的动作。
function c21785144.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将玩家tp的卡组最上方3张卡送去墓地，完成从卡组送墓的调度。
	Duel.DiscardDeck(tp,3,REASON_EFFECT)
end
