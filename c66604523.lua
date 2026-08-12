--エクシーズ・リバーサル
-- 效果：
-- 选择对方场上1只超量怪兽和自己场上1只超量怪兽才能发动。选择的怪兽的控制权交换。
function c66604523.initial_effect(c)
	-- 选择对方场上1只超量怪兽和自己场上1只超量怪兽才能发动。选择的怪兽的控制权交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c66604523.target)
	e1:SetOperation(c66604523.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示、可以改变控制权且其控制者场上有可用怪兽区域的超量怪兽
function c66604523.filter(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 判定卡片可以改变控制权，且该卡离开后其控制者场上有可用的怪兽区域（防止因格子限制无法交换）
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 效果发动时的对象选择与判定
function c66604523.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定对方场上是否存在至少1只满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c66604523.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 判定自己场上是否存在至少1只满足条件的超量怪兽
		and Duel.IsExistingTarget(c66604523.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的超量怪兽作为对象
	local g2=Duel.SelectTarget(tp,c66604523.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只满足条件的超量怪兽作为对象
	local g1=Duel.SelectTarget(tp,c66604523.filter,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁的操作信息，表示此效果包含改变2只卡片控制权的操作
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 效果处理的执行函数
function c66604523.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这两只怪兽的控制权
		Duel.SwapControl(a,b)
	end
end
