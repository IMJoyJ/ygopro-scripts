--ブラックポータン
-- 效果：
-- 自己场上有调整表侧表示存在的场合，这张卡不会被战斗破坏。自己场上表侧表示存在的调整从场上离开时，自己回复800基本分。
function c76218643.initial_effect(c)
	-- 自己场上有调整表侧表示存在的场合，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c76218643.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的调整从场上离开时，自己回复800基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76218643,0))  --"LP回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(c76218643.reccon)
	e2:SetTarget(c76218643.rectg)
	e2:SetOperation(c76218643.recop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的调整怪兽
function c76218643.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- 战斗不破效果的发生条件：自己场上存在表侧表示的调整怪兽
function c76218643.indcon(e)
	-- 检查自己场上是否存在至少1张表侧表示的调整怪兽
	return Duel.IsExistingMatchingCard(c76218643.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：原本是表侧表示且是调整怪兽的卡
function c76218643.filter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsType(TYPE_TUNER)
end
-- 回复效果的发动条件：离场的卡片中存在原本在自己场上表侧表示存在的调整怪兽
function c76218643.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c76218643.filter,1,nil,tp)
end
-- 回复效果的目标处理：设置回复基本分的效果参数
function c76218643.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为800（回复数值）
	Duel.SetTargetParam(800)
	-- 设置操作信息为：玩家回复800基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,800)
end
-- 回复效果的执行：获取目标玩家和回复数值，并执行回复
function c76218643.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应的基本分数值
	Duel.Recover(p,d,REASON_EFFECT)
end
