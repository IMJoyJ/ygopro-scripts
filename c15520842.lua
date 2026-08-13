--フォトン・ハンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，支付1000基本分，以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。发动时自己场上没有「银河眼光子龙」存在的场合，不是超量怪兽不能作为对象。
function c15520842.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，支付1000基本分，以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。发动时自己场上没有「银河眼光子龙」存在的场合，不是超量怪兽不能作为对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,15520842+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15520842.condition)
	e1:SetCost(c15520842.cost)
	e1:SetTarget(c15520842.target)
	e1:SetOperation(c15520842.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断怪兽是否为表侧表示，且属于「光子」或「银河」字段，用于后续检查己方场上是否存在满足发动条件的怪兽。
function c15520842.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 发动条件函数：检查己方主要怪兽区是否存在至少1只表侧表示的「光子」或「银河」怪兽，满足效果原文“自己场上有「光子」怪兽或者「银河」怪兽存在的场合”。
function c15520842.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上主要怪兽区是否存在至少1只满足cfilter过滤条件的表侧表示「光子」或「银河」怪兽。
	return Duel.IsExistingMatchingCard(c15520842.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价函数：先检查能否支付1000基本分，若能则实际支付，对应效果原文“支付1000基本分”。
function c15520842.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价确认阶段：检查当前玩家是否可以支付1000基本分，用于决定能否发动该效果。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际支付1000基本分作为发动效果的必要代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：判断怪兽是否为表侧表示，且卡名是「银河眼光子龙」（93717133），用于检测己方场上是否存在该卡来决定选对象限制。
function c15520842.geffilter(c)
	return c:IsFaceup() and c:IsCode(93717133)
end
-- 目标过滤函数：若己方场上存在表侧表示的「银河眼光子龙」，则可以选择任意可改变控制权的对方怪兽；否则只能选择表侧表示的超量怪兽，且该怪兽必须能够被改变控制权。对应“发动时自己场上没有「银河眼光子龙」存在的场合，不是超量怪兽不能作为对象”。
function c15520842.filter(c,tp)
	-- 判断己方场上（主要怪兽区+魔法陷阱区）是否存在至少1只表侧表示的「银河眼光子龙」，用于决定是否解除“只能选超量怪兽”的限制。
	return (Duel.IsExistingMatchingCard(c15520842.geffilter,tp,LOCATION_ONFIELD,0,1,nil)
		or (c:IsFaceup() and c:IsType(TYPE_XYZ))) and c:IsControlerCanBeChanged()
end
-- 效果发动时的目标选择函数：确认存在合法对象，提示玩家选择要改变控制权的对方场上1只怪兽，将其设为对象，并设置改变控制权的操作信息。
function c15520842.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c15520842.filter(chkc,tp) end
	-- 目标合法性确认：检查对方场上主要怪兽区是否存在至少1只满足filter条件（受「银河眼光子龙」影响的对象限制且可被改变控制权）的怪兽，作为“以对方场上1只怪兽为对象才能发动”的判定。
	if chk==0 then return Duel.IsExistingTarget(c15520842.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 显示选择提示，提示当前玩家选择要改变控制权的怪兽（HINTMSG_CONTROL）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上主要怪兽区选择1只满足filter条件的怪兽作为效果对象，并将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c15520842.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：本次效果将改变这1只怪兽的控制权，供后续连锁判定等系统逻辑使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数：取得发动时选择的对象怪兽，若该怪兽仍与效果存在关联，则获得其控制权，实现“得到那只怪兽的控制权”。
function c15520842.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁效果发动时选择的对方怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 让当前玩家获得那只怪兽的控制权，完成控制权转移。
		Duel.GetControl(tc,tp)
	end
end
