--リーフ・フェアリー
-- 效果：
-- 装备在这张卡上的1张装备卡送去墓地。对方玩家受到500分的伤害。
function c6979239.initial_effect(c)
	-- 装备在这张卡上的1张装备卡送去墓地。对方玩家受到500分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6979239,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c6979239.cost)
	e1:SetTarget(c6979239.target)
	e1:SetOperation(c6979239.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选装备在自身上且能作为代价送去墓地的卡片
function c6979239.filter(c,ec)
	return c:GetEquipTarget()==ec and c:IsAbleToGraveAsCost()
end
-- 代价处理：将装备在这张卡上的1张装备卡送去墓地
function c6979239.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查场上是否存在满足条件的装备卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6979239.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,e:GetHandler()) end
	-- 设置选择卡片时的提示信息为“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张装备在自身上的装备卡
	local g=Duel.SelectMatchingCard(tp,c6979239.filter,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,e:GetHandler())
	-- 将选中的装备卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标处理：设定伤害对象为对方玩家，伤害数值为500
function c6979239.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设定为效果的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害数值500设定为效果的对象参数
	Duel.SetTargetParam(500)
	-- 设置操作信息，表明此效果包含对对方玩家造成500点伤害的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：给与对方玩家500点伤害
function c6979239.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
