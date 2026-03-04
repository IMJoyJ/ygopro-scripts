--プレートクラッシャー
-- 效果：
-- 把自己场上存在的1张表侧表示的永续魔法或者永续陷阱卡送去墓地。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
function c114932.initial_effect(c)
	-- 效果原文：把自己场上存在的1张表侧表示的永续魔法或者永续陷阱卡送去墓地。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(114932,0))  --"伤害"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c114932.descost)
	e1:SetTarget(c114932.destg)
	e1:SetOperation(c114932.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选场上表侧表示的永续魔法或永续陷阱卡
function c114932.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
-- 效果的费用处理函数，检查是否满足支付费用的条件
function c114932.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c114932.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c114932.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标设定函数
function c114932.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁效果的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置操作信息为造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果的发动处理函数
function c114932.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成500点伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
