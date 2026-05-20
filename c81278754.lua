--裏ガエル
-- 效果：
-- 这张卡1回合只有1次可以变成里侧守备表示。这张卡反转时，可以让最多有自己场上表侧表示存在的名字带有「青蛙」的怪兽数量的对方场上存在的怪兽回到持有者手卡。
function c81278754.initial_effect(c)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81278754,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c81278754.target)
	e1:SetOperation(c81278754.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，可以让最多有自己场上表侧表示存在的名字带有「青蛙」的怪兽数量的对方场上存在的怪兽回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81278754,1))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetTarget(c81278754.rettg)
	e2:SetOperation(c81278754.retop)
	c:RegisterEffect(e2)
end
-- 起动效果的发动准备：检查自身是否能转为里侧守备表示且本回合未发动过此效果，注册回合内只能发动一次的标记，并设置改变表示形式的操作信息
function c81278754.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(81278754)==0 end
	c:RegisterFlagEffect(81278754,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：将1张自身卡片改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 起动效果的处理：若这张卡仍在场上且呈表侧表示，则将其转为里侧守备表示
function c81278754.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡转为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：自己场上表侧表示的名字带有「青蛙」的怪兽
function c81278754.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12)
end
-- 反转效果的发动准备：检查自己场上是否存在表侧表示的「青蛙」怪兽，且对方场上是否存在可回手牌的怪兽，并设置回手牌的操作信息
function c81278754.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的名字带有「青蛙」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c81278754.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在至少1只可以回到手牌的怪兽
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：将对方场上的怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
-- 反转效果的处理：计算自己场上表侧表示的「青蛙」怪兽数量，让玩家选择最多该数量的对方场上的怪兽回到持有者手卡
function c81278754.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算自己场上表侧表示的名字带有「青蛙」的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c81278754.cfilter,tp,LOCATION_MZONE,0,nil)
	if ct==0 then return end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1张到最多ct张（自己场上表侧表示「青蛙」怪兽数量）可以回到手牌的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,ct,nil)
	-- 为选中的卡片显示被选择的动画效果
	Duel.HintSelection(g)
	-- 将选中的怪兽送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
