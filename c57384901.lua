--亜空間ジャンプ装置
-- 效果：
-- 自己场上1只怪兽和对方场上1只放置有A指示物的怪兽控制权交换。
function c57384901.initial_effect(c)
	-- 自己场上1只怪兽和对方场上1只放置有A指示物的怪兽控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c57384901.target)
	e1:SetOperation(c57384901.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上可以改变控制权且有可用怪兽区域的怪兽
function c57384901.filter1(c)
	local tp=c:GetControler()
	-- 判定卡片是否可以改变控制权，且该卡离开后其控制者场上仍有可用的怪兽区域
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤对方场上放置有A指示物、可以改变控制权且有可用怪兽区域的怪兽
function c57384901.filter2(c)
	local tp=c:GetControler()
	-- 判定卡片是否放置有A指示物、可以改变控制权，且该卡离开后其控制者场上仍有可用的怪兽区域
	return c:GetCounter(0x100e)>0 and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果发动的目标选择与合法性检测
function c57384901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只满足条件的放置有A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(c57384901.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c57384901.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只放置有A指示物的怪兽作为对象
	local g2=Duel.SelectTarget(tp,c57384901.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只怪兽作为对象
	local g1=Duel.SelectTarget(tp,c57384901.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置当前连锁的操作信息为改变2张卡片的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理的执行函数
function c57384901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为该效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这两只怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
