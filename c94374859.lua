--押し売りゾンビ
-- 效果：
-- 每次自己场上的怪兽给与对方玩家战斗伤害，选择对方墓地存在的1张卡回到对方卡组最下面。
function c94374859.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己场上的怪兽给与对方玩家战斗伤害，选择对方墓地存在的1张卡回到对方卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94374859,0))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c94374859.condition)
	e2:SetTarget(c94374859.target)
	e2:SetOperation(c94374859.operation)
	c:RegisterEffect(e2)
end
-- 判断是否为自己场上的怪兽给与对方玩家战斗伤害
function c94374859.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():GetControler()==tp
end
-- 效果发动的对象选择与准备工作，确认对方墓地有卡可以回到卡组并进行选择
function c94374859.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	if chk==0 then return true end
	-- 在客户端提示玩家选择要放入卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地中1张可以回到卡组的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	if g:GetCount()>0 then
		-- 设置连锁操作信息，表明此效果包含将1张卡送回卡组的操作
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
end
-- 效果处理的执行，将选中的对象卡片送回卡组最下面
function c94374859.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因送回持有者卡组的最下面
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
