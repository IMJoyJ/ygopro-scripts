--生贄の祭壇
-- 效果：
-- 选择自己场上1只怪兽送去墓地。自己回复与此怪兽原本攻击力数值相同的基本分。
function c21070956.initial_effect(c)
	-- 创建效果，设置为发动时点，具有玩家目标属性，发动类型为自由时点，需要支付代价，设置目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c21070956.cost)
	e1:SetTarget(c21070956.target)
	e1:SetOperation(c21070956.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选可以作为代价送去墓地且原本攻击力大于0的怪兽
function c21070956.filter(c)
	return c:IsAbleToGraveAsCost() and c:GetTextAttack()>0
end
-- 效果的代价处理函数，检查是否有满足条件的怪兽可作为代价送去墓地，若有则提示选择并执行送去墓地操作
function c21070956.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足代价条件，即场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21070956.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的1只怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c21070956.filter,tp,LOCATION_MZONE,0,1,1,nil);
	local atk=g:GetFirst():GetTextAttack()
	e:SetLabel(atk)
	-- 将选中的怪兽送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置效果的目标，包括目标玩家和目标参数
function c21070956.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置效果的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为之前记录的怪兽攻击力
	Duel.SetTargetParam(e:GetLabel())
	-- 设置效果操作信息，表示将进行回复基本分的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 效果处理函数，获取连锁中的目标玩家和参数并执行回复基本分操作
function c21070956.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end
