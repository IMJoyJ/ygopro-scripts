--ダイガスタ・イグルス
-- 效果：
-- 调整＋调整以外的名字带有「薰风」的怪兽1只以上
-- 1回合1次，自己的结束阶段时可以从自己墓地把1只风属性怪兽从游戏中除外，选择对方场上里侧表示存在的1张卡破坏。
function c10755984.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整（任意）加1只以上调整以外的名字带有「薰风」的怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- 对应效果原文：“1回合1次，自己的结束阶段时可以从自己墓地把1只风属性怪兽从游戏中除外，选择对方场上里侧表示存在的1张卡破坏。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10755984,0))  --"场上里侧表示存在的1张卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c10755984.condition)
	e1:SetCost(c10755984.cost)
	e1:SetTarget(c10755984.target)
	e1:SetOperation(c10755984.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数，用于判断当前是否符合效果发动时机（自己的结束阶段）。
function c10755984.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为自己（tp），确保只有在自己回合的结束阶段才能发动此效果。
	return Duel.GetTurnPlayer()==tp
end
-- 定义代价筛选函数：从自己墓地选择1只风属性怪兽，且该怪兽可以作为代价从游戏中除外。
function c10755984.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义代价支付函数：在发动时确认墓地存在符合条件的风属性怪兽，然后选择1只表侧表示除外作为发动代价。
function c10755984.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性检查：若为chk==0，返回自己墓地是否存在至少1张满足costfilter的风属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c10755984.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，提示玩家选择要除外的卡（用于选择界面的消息显示）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足costfilter的风属性怪兽，作为发动效果要除外的代价卡。
	local g=Duel.SelectMatchingCard(tp,c10755984.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的风属性怪兽表侧表示除外，支付发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义取对象筛选函数：选择对方场上的里侧表示存在的卡（怪兽·魔法·陷阱均可）。
function c10755984.filter(c)
	return c:IsFacedown()
end
-- 定义效果发动时的取对象处理：必须选择对方场上里侧表示存在的1张卡作为对象，并设置破坏的操作信息。
function c10755984.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c10755984.filter(chkc) end
	-- 发动时点合法性检查：确认对方场上是否存在里侧表示且能成为效果对象的卡。
	if chk==0 then return Duel.IsExistingTarget(c10755984.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张里侧表示的卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c10755984.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁处理操作信息，声明本次效果将破坏1张对方场上的卡，供相关卡牌互动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理函数：效果结算时检查对象卡是否仍为里侧表示且与效果有关联，若是则将其破坏。
function c10755984.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个（也是唯一一个）效果对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将取到的对象卡以卡牌效果的原因（REASON_EFFECT）破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
