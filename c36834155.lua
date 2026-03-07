--フォトン・パイレーツ
-- 效果：
-- 自己的主要阶段时把自己墓地1只名字带有「光子」的怪兽从游戏中除外才能发动。这张卡的攻击力直到结束阶段时上升1000。「光子海盗」的效果1回合可以使用最多2次。
function c36834155.initial_effect(c)
	-- 效果原文内容：自己的主要阶段时把自己墓地1只名字带有「光子」的怪兽从游戏中除外才能发动。这张卡的攻击力直到结束阶段时上升1000。「光子海盗」的效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36834155,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2,36834155)
	e1:SetCost(c36834155.cost)
	e1:SetOperation(c36834155.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：名字带有「光子」的怪兽且可以作为除外的代价
function c36834155.cfilter(c)
	return c:IsSetCard(0x55) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：检查是否有满足条件的卡片并选择1张除外
function c36834155.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查以自己为视角的墓地是否存在至少1张满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c36834155.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择1张满足条件的卡从游戏中除外
	local g=Duel.SelectMatchingCard(tp,c36834155.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 效果作用：将选中的卡从游戏中除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果作用：使自身攻击力上升1000点直到结束阶段
function c36834155.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：这张卡的攻击力直到结束阶段时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
