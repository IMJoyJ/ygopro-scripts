--ラヴァルのマグマ砲兵
-- 效果：
-- 从手卡把1只炎属性怪兽送去墓地发动。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
function c46404281.initial_effect(c)
	-- 创建一个起动效果，效果描述为“给与对方500伤害”，属于伤害类别，发动方式为起动效果，影响对象为对方玩家，发动位置为主怪兽区，每回合最多发动2次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46404281,0))  --"给与对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c46404281.damcost)
	e1:SetTarget(c46404281.damtg)
	e1:SetOperation(c46404281.damop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选手牌中属性为炎且可以作为cost送去墓地的怪兽
function c46404281.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 效果的cost处理函数，检查是否满足cost条件并选择一张符合条件的卡送去墓地
function c46404281.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在手牌中是否存在至少1张满足条件的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46404281.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家提示“请选择要送去墓地的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张满足条件的炎属性怪兽作为cost
	local g=Duel.SelectMatchingCard(tp,c46404281.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽送去墓地作为发动效果的代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置该效果的目标为对方玩家，伤害值为500，并记录操作信息
function c46404281.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为500点伤害
	Duel.SetTargetParam(500)
	-- 设置操作信息为造成500点伤害的效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果的发动处理函数，根据连锁信息获取目标玩家和伤害值并执行伤害效果
function c46404281.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
