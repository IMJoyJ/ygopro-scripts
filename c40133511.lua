--魂を喰らう者 バズー
-- 效果：
-- 可以从自己的墓地选最多3张怪兽从游戏中除外。每除外1张卡，在对方回合结束前，这张卡的攻击力上升300。这个效果在自己的回合只能用1次。
function c40133511.initial_effect(c)
	-- 创建一个起动效果，效果描述为攻击上升，属于攻击变化类别，发动位置为主怪兽区，一回合只能发动一次，需要支付除外墓地怪兽作为代价，发动时执行operation函数
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
-- 过滤函数，用于筛选可以作为除外代价的怪兽卡
function c40133511.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果的代价函数，检查是否满足除外条件并选择1到3张怪兽卡除外
function c40133511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外条件，即自己墓地是否存在至少1张怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(c40133511.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1到3张满足条件的卡
	local cg=Duel.SelectMatchingCard(tp,c40133511.cfilter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 将选中的卡从游戏中除外作为代价
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	e:SetLabel(cg:GetCount())
end
-- 效果的发动函数，根据除外卡的数量提升攻击力
function c40133511.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 创建一个持续效果，使该卡的攻击力上升count*300点，持续到对方回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(count*300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
