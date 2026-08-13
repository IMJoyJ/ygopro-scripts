--生贄の祭壇
-- 效果：
-- 选择自己场上1只怪兽送去墓地。自己回复与此怪兽原本攻击力数值相同的基本分。
function c21070956.initial_effect(c)
	-- 选择自己场上1只怪兽送去墓地。自己回复与此怪兽原本攻击力数值相同的基本分。
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
-- 定义过滤器，用于选择自己场上1只可以作为代价送去墓地、且卡面记载攻击力大于0的怪兽。
function c21070956.filter(c)
	return c:IsAbleToGraveAsCost() and c:GetTextAttack()>0
end
-- 定义代价函数：先确认存在可选的怪兽，再提示玩家选择1只，记录其攻击力到效果标签，然后将该怪兽作为代价送去墓地。
function c21070956.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段，确认自己场上是否存在满足过滤条件的怪兽，以决定效果能否发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c21070956.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家显示选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只满足过滤条件的怪兽，作为发动代价要送去墓地的卡片。
	local g=Duel.SelectMatchingCard(tp,c21070956.filter,tp,LOCATION_MZONE,0,1,1,nil);
	local atk=g:GetFirst():GetTextAttack()
	e:SetLabel(atk)
	-- 将选择的怪兽送去墓地，送墓原因是作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义目标阶段函数：确认代价已合法支付后，设定回复对象为自己、回复数值为记录的原本攻击力，并设置回复相关的操作信息。
function c21070956.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 将当前连锁的对象玩家设置为发动者自己，即LP回复的目标是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为之前记录的怪兽原本攻击力，作为后续回复的数值。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置操作信息，表明这是一个回复LP的效果，回复对象为发动者自己，预计回复值为记录的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,e:GetLabel())
end
-- 定义效果处理函数：从连锁信息中取出对象玩家和回复量，并为该玩家回复对应LP。
function c21070956.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家和对象参数，即回复目标和回复量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家回复对应的LP，回复原因是卡的效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
