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
-- 筛选自己场上表侧表示的光属性怪兽，用于计算数量。
function c44472639.filter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsFaceup()
end
-- 效果发动时的目标处理函数：检查发动条件，计算伤害值并设置对象玩家与参数，登记操作信息。
function c44472639.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否存在至少1只表侧表示的光属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c44472639.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 计算自己场上表侧表示的光属性怪兽数量×600作为伤害值。
	local dam=Duel.GetMatchingGroupCount(c44472639.filter,tp,LOCATION_MZONE,0,nil)*600
	-- 将本效果的对象玩家设为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算出的伤害值作为效果参数存入连锁信息。
	Duel.SetTargetParam(dam)
	-- 登记操作信息：本连锁将造成伤害，对象玩家为对方，伤害数值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理函数：从连锁信息取出对象玩家，按当前场上光属性怪兽数量重新计算伤害，并给予对方伤害。
function c44472639.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出事先设定的对象玩家（对方）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 在效果处理时重新计算伤害值，以反应连锁处理过程中场上怪兽数量的变化。
	local dam=Duel.GetMatchingGroupCount(c44472639.filter,tp,LOCATION_MZONE,0,nil)*600
	-- 给予对方玩家dam点效果伤害。
	Duel.Damage(p,dam,REASON_EFFECT)
end
