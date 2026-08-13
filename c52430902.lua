--サイコジャンパー
-- 效果：
-- 支付1000基本分并选择对方场上表侧表示存在的1只怪兽，那只怪兽和「念力跳跃者」以外的自己场上表侧表示存在的1只念动力族怪兽的控制权交换。选择的怪兽在这个回合不能作表示形式的改变。这个效果1回合只能使用1次。
function c52430902.initial_effect(c)
	-- 支付1000基本分并选择对方场上表侧表示存在的1只怪兽，那只怪兽和「念力跳跃者」以外的自己场上表侧表示存在的1只念动力族怪兽的控制权交换。选择的怪兽在这个回合不能作表示形式的改变。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52430902,0))  --"交换控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c52430902.cost)
	e1:SetTarget(c52430902.target)
	e1:SetOperation(c52430902.operation)
	c:RegisterEffect(e1)
end
-- 定义代价函数：发动效果前需支付1000基本分，若无法支付则不能发动。
function c52430902.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认玩家能否支付1000基本分，若可以则返回true，否则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 实际扣除玩家1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：选择自己场上「念力跳跃者」以外的表侧念动力族怪兽，要求其表侧表示、种族为念动力族、卡名不是「念力跳跃者」、可改变控制权，且该怪兽离场后自己场上仍有空置的主要怪兽区。
function c52430902.filter1(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsCode(52430902)
		-- 追加过滤条件：该怪兽可以改变控制权，且离场后其控制者的主要怪兽区仍有空位，以保证交换后对方怪兽能放置到自己场上。
		and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤函数：选择对方场上表侧表示的怪兽，要求其表侧表示、可改变控制权，且该怪兽离场后对方场上仍有空置的主要怪兽区。
function c52430902.filter2(c)
	local tp=c:GetControler()
	-- 过滤条件：对方怪兽需表侧表示、可改变控制权，且离场后其控制者场上仍有空置的主要怪兽区。
	return c:IsFaceup() and c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 定义目标选择函数：在效果发动合法性检查时，确认对方场上有1只符合filter2条件的表侧怪兽，且自己场上有1只符合filter1条件的念动力族怪兽，两者都存在才允许发动。
function c52430902.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只满足filter2条件的表侧怪兽，作为可选择的交换对象。
	if chk==0 then return Duel.IsExistingTarget(c52430902.filter2,tp,0,LOCATION_MZONE,1,nil)
		-- 同时检查自己场上是否存在至少1只满足filter1条件的念动力族怪兽（「念力跳跃者」以外），作为另一个交换对象；若双方候选都存在，则效果可以发动。
		and Duel.IsExistingTarget(c52430902.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示信息，提示玩家选择自己场上要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只符合filter1条件的念动力族怪兽作为对象，并将其加入连锁对象。
	local g1=Duel.SelectTarget(tp,c52430902.filter1,tp,LOCATION_MZONE,0,1,1,nil)
	-- 再次显示选择提示信息，提示玩家选择对方场上要改变控制权的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只符合filter2条件的怪兽作为对象，并将其加入连锁对象。
	local g2=Duel.SelectTarget(tp,c52430902.filter2,tp,0,LOCATION_MZONE,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，标明此效果将以合并后的g1（两只怪兽）作为改变控制权的对象，数量为2，供后续效果处理和相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 定义效果处理函数：获取连锁对象，确认两只怪兽仍表侧表示且与当前效果关联后，尝试交换它们的控制权；若交换成功，则给两只怪兽各注册一个‘本回合不能改变表示形式’的持续效果。
function c52430902.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的目标怪兽组，包含之前选择的己方念动力族怪兽和对方怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsFaceup() and tc1:IsRelateToEffect(e) and tc2:IsFaceup() and tc2:IsRelateToEffect(e) then
		-- 尝试交换两只怪兽的控制权，若交换成功则继续处理后续效果。
		if Duel.SwapControl(tc1,tc2) then
			-- 对应效果原文：选择的怪兽在这个回合不能作表示形式的改变。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc1:RegisterEffect(e1)
			local e2=e1:Clone()
			tc2:RegisterEffect(e2)
		end
	end
end
