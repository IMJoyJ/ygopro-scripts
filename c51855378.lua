--ジャンク・ブレーダー
-- 效果：
-- 可以把自己墓地存在的1只名字带有「废品」的怪兽从游戏中除外，这张卡的攻击力直到结束阶段时上升400。
function c51855378.initial_effect(c)
	-- 可以把自己墓地存在的1只名字带有「废品」的怪兽从游戏中除外，这张卡的攻击力直到结束阶段时上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51855378,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c51855378.cost)
	e1:SetOperation(c51855378.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡是名字带有「废品」的怪兽，并且可以作为代价除外。
function c51855378.cfilter(c)
	return c:IsSetCard(0x43) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：先检查自己墓地是否存在满足条件的「废品」怪兽，存在则让玩家选择1只，将其正面表示除外作为发动代价。
function c51855378.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己墓地是否存在至少1只符合过滤条件的「废品」怪兽可作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c51855378.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片（用于选择提示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只符合过滤条件的「废品」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c51855378.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：若这张卡仍表侧表示且与发动效果关联，则让它攻击力上升400，该上升持续到结束阶段。
function c51855378.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到结束阶段时上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
