--サイコ・ヘルストランサー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。自己回复1200基本分。这个效果1回合只能使用1次。
function c45379225.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 把自己墓地存在的1只念动力族怪兽从游戏中除外发动。自己回复1200基本分。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45379225,0))  --"回复1200基本分"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c45379225.cost)
	e1:SetTarget(c45379225.target)
	e1:SetOperation(c45379225.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的念动力族怪兽，且可以作为除外的代价
function c45379225.filter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
-- 检查自己墓地是否存在满足条件的念动力族怪兽，若存在则选择1张除外
function c45379225.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1张满足条件的念动力族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45379225.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1张满足条件的念动力族怪兽从墓地除外
	local g=Duel.SelectMatchingCard(tp,c45379225.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的念动力族怪兽从游戏中除外作为效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的目标玩家和回复的基本分
function c45379225.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为使用效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1200
	Duel.SetTargetParam(1200)
	-- 设置效果操作信息为回复1200基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1200)
end
-- 执行效果，使目标玩家回复指定基本分
function c45379225.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
