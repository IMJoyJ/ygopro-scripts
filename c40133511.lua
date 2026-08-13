--魂を喰らう者 バズー
-- 效果：
-- 可以从自己的墓地选最多3张怪兽从游戏中除外。每除外1张卡，在对方回合结束前，这张卡的攻击力上升300。这个效果在自己的回合只能用1次。
function c40133511.initial_effect(c)
	-- 可以从自己的墓地选最多3张怪兽从游戏中除外。每除外1张卡，在对方回合结束前，这张卡的攻击力上升300。这个效果在自己的回合只能用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40133511,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c40133511.cost)
	e1:SetOperation(c40133511.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：判定墓地中的怪兽卡是否满足作为代价除外的条件，即必须是怪兽卡且可以作为代价除外。
function c40133511.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：先检查是否有符合条件的墓地怪兽；再让玩家选择1~3张墓地怪兽表侧除外作为代价，并将除外数量存入效果标签。
function c40133511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1张符合条件的怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c40133511.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的怪兽中选出1~3张满足条件的卡，作为发动代价的对象。
	local cg=Duel.SelectMatchingCard(tp,c40133511.cfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 将选中的卡以表侧表示除外，除外原因为代价（REASON_COST）。
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	e:SetLabel(cg:GetCount())
end
-- 效果处理：取出记录的外除数量；若这张卡仍表侧存在于场上且与该效果相关，则给它赋予攻击力上升效果，上升值为数量×300，持续到对方回合结束（重置点设为第2个结束阶段）。
function c40133511.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 每除外1张卡，在对方回合结束前，这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(count*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
