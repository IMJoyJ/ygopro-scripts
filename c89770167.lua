--炎熱刀プロミネンス
-- 效果：
-- 1回合1次，把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外才能发动。这张卡的攻击力直到结束阶段时上升300。这个效果在对方回合也能发动。
function c89770167.initial_effect(c)
	-- 1回合1次，把自己墓地存在的1只名字带有「熔岩」的怪兽从游戏中除外才能发动。这张卡的攻击力直到结束阶段时上升300。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89770167,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 设置发动条件为伤害步骤中伤害计算前（限制在伤害计算后不能发动）
	e1:SetCondition(aux.dscon)
	e1:SetCost(c89770167.atcost)
	e1:SetOperation(c89770167.atop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中名字带有「熔岩」且可以作为代价除外的怪兽
function c89770167.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：将自己墓地1只名字带有「熔岩」的怪兽除外
function c89770167.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只满足过滤条件的「熔岩」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89770167.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只满足过滤条件的「熔岩」怪兽
	local g=Duel.SelectMatchingCard(tp,c89770167.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若此卡在场上表侧表示存在，则直到结束阶段时其攻击力上升300
function c89770167.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
