--TG1－EM1
-- 效果：
-- 选择对方场上存在的1只怪兽和自己场上表侧表示存在的1只名字带有「科技属」的怪兽发动。选择的怪兽的控制权交换。
function c76641981.initial_effect(c)
	-- 选择对方场上存在的1只怪兽和自己场上表侧表示存在的1只名字带有「科技属」的怪兽发动。选择的怪兽的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c76641981.target)
	e1:SetOperation(c76641981.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的「科技属」怪兽，且该怪兽可以改变控制权，并且交换后其控制者场上有可用怪兽区域
function c76641981.filter1(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x27)
		-- 判定怪兽是否可以改变控制权，以及该怪兽离开后其控制者场上是否有可用的怪兽区域（防止因格子限制无法交换）
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤对方场上的怪兽，且该怪兽可以改变控制权，并且交换后其控制者场上有可用怪兽区域
function c76641981.filter2(c)
	local tp=c:GetControler()
	-- 判定怪兽是否可以改变控制权，以及该怪兽离开后其控制者场上是否有可用的怪兽区域
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果发动时的对象选择与合法性检测函数
function c76641981.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定对方场上是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c76641981.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 判定自己场上是否存在至少1只符合条件的表侧表示「科技属」怪兽
		and Duel.IsExistingTarget(c76641981.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合条件的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c76641981.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只符合条件的表侧表示「科技属」怪兽作为对象
	local g1=Duel.SelectTarget(tp,c76641981.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，表示此效果包含改变2只怪兽控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理函数，获取选择的对象并交换它们的控制权
function c76641981.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这两只怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
