--ジャンク・ブレーダー
-- 效果：
-- 可以把自己墓地存在的1只名字带有「废品」的怪兽从游戏中除外，这张卡的攻击力直到结束阶段时上升400。
function c51855378.initial_effect(c)
	-- 效果原文内容：可以把自己墓地存在的1只名字带有「废品」的怪兽从游戏中除外，这张卡的攻击力直到结束阶段时上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51855378,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c51855378.cost)
	e1:SetOperation(c51855378.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选墓地里满足条件的「废品」怪兽（名字带废品、是怪兽卡、可以作为除外的代价）
function c51855378.cfilter(c)
	return c:IsSetCard(0x43) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果的发动费用处理，检查是否满足除外1只「废品」怪兽的条件并执行除外操作
function c51855378.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在自己墓地是否存在至少1张满足cfilter条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51855378.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡从墓地除外
	local g=Duel.SelectMatchingCard(tp,c51855378.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以正面表示的形式从游戏中除外作为效果的发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的发动处理，使自身攻击力上升400点直到结束阶段
function c51855378.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：这张卡的攻击力直到结束阶段时上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
