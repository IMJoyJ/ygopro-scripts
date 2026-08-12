--フォトン・ハンド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「光子」怪兽或者「银河」怪兽存在的场合，支付1000基本分，以对方场上1只怪兽为对象才能发动。得到那只怪兽的控制权。发动时自己场上没有「银河眼光子龙」存在的场合，不是超量怪兽不能作为对象。
function c15520842.initial_effect(c)
	-- 创建效果，设置为发动时改变控制权，可取对象，自由时点，一回合只能发动一次，条件为己方场上存在光子或银河怪兽，支付1000基本分，选择对方场上一只怪兽为目标，发动时若己方场上没有银河眼光子龙则目标必须为超量怪兽
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
-- 过滤函数，检查己方场上是否存在表侧表示的光子或银河怪兽
function c15520842.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 效果发动条件，检查己方场上是否存在光子或银河怪兽
function c15520842.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在光子或银河怪兽
	return Duel.IsExistingMatchingCard(c15520842.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 支付费用函数，检查是否能支付1000基本分，若能则支付
function c15520842.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数，检查己方场上是否存在表侧表示的银河眼光子龙
function c15520842.geffilter(c)
	return c:IsFaceup() and c:IsCode(93717133)
end
-- 目标过滤函数，若己方场上存在银河眼光子龙或目标为超量怪兽，则目标可被选择
function c15520842.filter(c,tp)
	-- 检查己方场上是否存在银河眼光子龙
	return (Duel.IsExistingMatchingCard(c15520842.geffilter,tp,LOCATION_ONFIELD,0,1,nil)
		or (c:IsFaceup() and c:IsType(TYPE_XYZ))) and c:IsControlerCanBeChanged()
end
-- 设置效果目标，选择对方场上一只符合条件的怪兽作为目标
function c15520842.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c15520842.filter(chkc,tp) end
	-- 检查是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c15520842.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择一只符合条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c15520842.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息，记录将要改变控制权的怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理函数，获取目标怪兽并尝试获得其控制权
function c15520842.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获得目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end
