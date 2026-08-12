--超熱血球児
-- 效果：
-- 场上有这张卡以外的炎属性怪兽存在的场合，每有1张，这张卡的攻击力上升1000。每把这张卡以外的1只炎属性怪兽送去墓地，给与对方基本分500分的伤害。
function c67934141.initial_effect(c)
	-- 场上有这张卡以外的炎属性怪兽存在的场合，每有1张，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c67934141.val)
	c:RegisterEffect(e1)
	-- 每把这张卡以外的1只炎属性怪兽送去墓地，给与对方基本分500分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67934141,0))  --"给与对方1000伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c67934141.damcost)
	e2:SetTarget(c67934141.damtg)
	e2:SetOperation(c67934141.damop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的炎属性怪兽
function c67934141.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 计算攻击力上升数值的函数
function c67934141.val(e,c)
	-- 返回场上除自身以外的表侧表示炎属性怪兽数量乘以1000的数值
	return Duel.GetMatchingGroupCount(c67934141.filter,c:GetControler(),LOCATION_MZONE,LOCATION_MZONE,c)*1000
end
-- 过滤场上表侧表示、可作为代价送去墓地的炎属性怪兽
function c67934141.costfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 伤害效果的发动代价处理函数
function c67934141.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段0，检查场上是否存在除自身以外的、可作为代价送去墓地的表侧表示炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c67934141.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张除自身以外的、场上表侧表示的炎属性怪兽
	local g=Duel.SelectMatchingCard(tp,c67934141.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 伤害效果的发动准备（确定目标玩家和伤害数值）
function c67934141.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的参数为500（伤害数值）
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息，表示该效果会给与对方500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,500)
end
-- 伤害效果的实际处理函数
function c67934141.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成相应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
