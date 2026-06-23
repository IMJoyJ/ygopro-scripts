--ダイガスタ・イグルス
-- 效果：
-- 调整＋调整以外的名字带有「薰风」的怪兽1只以上
-- 1回合1次，自己的结束阶段时可以从自己墓地把1只风属性怪兽从游戏中除外，选择对方场上里侧表示存在的1张卡破坏。
function c10755984.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的名字带有「薰风」的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSetCard,0x10),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己的结束阶段时可以从自己墓地把1只风属性怪兽从游戏中除外，选择对方场上里侧表示存在的1张卡破坏。
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
-- 判断是否为自己的结束阶段
function c10755984.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果发动者
	return Duel.GetTurnPlayer()==tp
end
-- 定义费用过滤条件，检查是否为风属性怪兽且可从墓地除外
function c10755984.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义效果的费用处理函数
function c10755984.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足费用条件，即墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c10755984.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择满足条件的1只怪兽从墓地除外
	local g=Duel.SelectMatchingCard(tp,c10755984.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义目标过滤条件，检查是否为里侧表示的卡
function c10755984.filter(c)
	return c:IsFacedown()
end
-- 定义效果的目标选择函数
function c10755984.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c10755984.filter(chkc) end
	-- 检查是否满足目标选择条件，即对方场上是否存在里侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(c10755984.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上1张里侧表示的卡作为目标
	local g=Duel.SelectTarget(tp,c10755984.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息，确定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果的发动处理函数
function c10755984.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
