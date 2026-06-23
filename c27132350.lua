--ファイヤーソーサラー
-- 效果：
-- 反转：自己的手卡随机选2张除外。对方受到800分的伤害。
function c27132350.initial_effect(c)
	-- 反转：自己的手卡随机选2张除外。对方受到800分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27132350,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetCost(c27132350.cost)
	e1:SetTarget(c27132350.target)
	e1:SetOperation(c27132350.operation)
	c:RegisterEffect(e1)
end
-- 检查是否满足除外2张手卡的费用条件
function c27132350.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足除外2张手卡的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,2,nil) end
	-- 获取满足除外条件的手卡组
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,nil)
	local rg=g:RandomSelect(tp,2)
	-- 将满足条件的手卡中随机选择2张除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 设置连锁目标玩家为对方玩家
function c27132350.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁目标参数为800
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为对对方造成800伤害
	Duel.SetTargetParam(800)
	-- 设置连锁操作信息为对对方造成800伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 处理连锁效果，对对方造成800伤害
function c27132350.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
