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
c57384901.mentioned_counter={
	[0x100e]=true,
}
-- 检查怪兽是否满足自己场上交换对象的条件：可以改变控制权，且其离场后该控制者场上仍有可用的主要怪兽区
function c57384901.filter1(c)
	local tp=c:GetControler()
	-- 该怪兽可以改变控制权，且该怪兽离开场上后，其控制者场上仍有可用的主要怪兽区
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 检查怪兽是否满足对方场上交换对象的条件：放置有A指示物、可以改变控制权，且其离场后该控制者场上仍有可用的主要怪兽区
function c57384901.filter2(c)
	local tp=c:GetControler()
	-- 该怪兽放置有A指示物，可以改变控制权，且该怪兽离开场上后，其控制者场上仍有可用的主要怪兽区
	return c:GetCounter(0x100e)>0 and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 发动条件判定：对方场上存在1只以上放置有A指示物且可交换控制权的怪兽，且自己场上存在1只以上可交换控制权的怪兽
function c57384901.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 对方怪兽区存在1只以上放置有A指示物且可以改变控制权并能成为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c57384901.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 并且自己怪兽区存在1只以上可以改变控制权并能成为效果对象的怪兽
		and Duel.IsExistingTarget(c57384901.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向发动玩家提示：请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 以对方场上1只放置有A指示物且可以改变控制权的怪兽为对象
	local g2=Duel.SelectTarget(tp,c57384901.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	-- 向发动玩家提示：请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 以自己场上1只可以改变控制权的怪兽为对象
	local g1=Duel.SelectTarget(tp,c57384901.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁的操作信息：分类为改变控制权，处理对象为作为对象的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理：若作为对象的2只怪兽都仍与本效果关联，则交换这2只怪兽的控制权
function c57384901.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这2只怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
