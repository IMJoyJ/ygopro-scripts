--リサイクル
-- 效果：
-- 在自己准备阶段支付300基本分，就可从存在于自己墓地的卡里选择1张怪兽卡以外的卡放回卡组最下方。
function c96316857.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 在自己准备阶段支付300基本分，就可从存在于自己墓地的卡里选择1张怪兽卡以外的卡放回卡组最下方。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96316857,0))  --"返回卡组"
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c96316857.rccon)
	e2:SetCost(c96316857.rccost)
	e2:SetTarget(c96316857.rctg)
	e2:SetOperation(c96316857.rcop)
	c:RegisterEffect(e2)
end
-- 定义效果发动条件函数，判断是否在自己的准备阶段
function c96316857.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义效果发动代价函数，支付300基本分
function c96316857.rccost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查玩家是否能支付300基本分
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 支付300基本分作为发动代价
	Duel.PayLPCost(tp,300)
end
-- 定义过滤条件：可以回到卡组且不为怪兽卡的卡
function c96316857.filter(c)
	return c:IsAbleToDeck() and not c:IsType(TYPE_MONSTER)
end
-- 定义效果目标函数，选择自己墓地1张怪兽以外的卡作为对象并设置操作信息
function c96316857.rctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c96316857.filter(chkc) end
	-- 在发动效果时，检查自己墓地是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c96316857.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 在客户端弹出提示信息，要求玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张满足条件的卡作为效果对象
	local g=Duel.SelectTarget(tp,c96316857.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，准备将1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 定义效果运行函数，将选择的对象卡放回卡组最下方
function c96316857.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因放回持有者卡组的最下方
		Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
