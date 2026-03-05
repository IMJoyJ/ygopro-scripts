--メガキャノン・ソルジャー
-- 效果：
-- 每把自己场上存在的2只怪兽作为祭品，给与对方基本分1500分伤害。
function c14702066.initial_effect(c)
	-- 每把自己场上存在的2只怪兽作为祭品，给与对方基本分1500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14702066,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c14702066.cost)
	e1:SetTarget(c14702066.target)
	e1:SetOperation(c14702066.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足解放2只怪兽的条件
function c14702066.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 选择满足条件的卡片组
	local sg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将目标怪兽特殊召唤
	Duel.Release(sg,REASON_COST)
end
-- 设置连锁处理的目标玩家
function c14702066.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标参数
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的操作信息
	Duel.SetTargetParam(1500)
	-- 设置连锁处理的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- 设置连锁处理的操作信息
function c14702066.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁信息中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
