--D-HERO ダンクガイ
-- 效果：
-- 可以从手卡把1张名字带有「命运英雄」的卡送去墓地，给与对方基本分500分伤害。
function c93431862.initial_effect(c)
	-- 可以从手卡把1张名字带有「命运英雄」的卡送去墓地，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93431862,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c93431862.damcost)
	e1:SetTarget(c93431862.damtg)
	e1:SetOperation(c93431862.damop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手牌中名字带有「命运英雄」且能作为代价送去墓地的卡
function c93431862.cfilter(c)
	return c:IsSetCard(0xc008) and c:IsAbleToGraveAsCost()
end
-- 代价处理：从手卡将1张「命运英雄」卡送去墓地
function c93431862.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张满足过滤条件的「命运英雄」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c93431862.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手牌中1张满足过滤条件的「命运英雄」卡
	local g=Duel.SelectMatchingCard(tp,c93431862.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标处理：设置对方玩家为伤害对象，并声明500点伤害的操作信息
function c93431862.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为：给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：获取目标玩家和伤害数值，并给与对方玩家伤害
function c93431862.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
