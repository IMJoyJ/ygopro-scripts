--ソーラーレイ
-- 效果：
-- 对对方造成数值与自己场上存在的光属性怪兽数量×600点等同的伤害。
function c44472639.initial_effect(c)
	-- 对对方造成数值与自己场上存在的光属性怪兽数量×600点等同的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x1c1)
	e1:SetTarget(c44472639.target)
	e1:SetOperation(c44472639.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在光属性怪兽
function c44472639.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
-- 效果处理时点，检查是否满足发动条件并计算伤害值
function c44472639.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c44472639.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 计算场上光属性怪兽数量并乘以600得到伤害值
	local dam=Duel.GetMatchingGroupCount(c44472639.filter,tp,LOCATION_MZONE,0,nil)*600
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为计算出的伤害值
	Duel.SetTargetParam(dam)
	-- 设置操作信息为对对方造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果发动时点，获取目标玩家并造成伤害
function c44472639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 再次计算场上光属性怪兽数量并乘以600得到伤害值
	local dam=Duel.GetMatchingGroupCount(c44472639.filter,tp,LOCATION_MZONE,0,nil)*600
	-- 以效果原因对指定玩家造成相应伤害
	Duel.Damage(p,dam,REASON_EFFECT)
end
