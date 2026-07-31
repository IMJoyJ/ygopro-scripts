--ドングリス
-- 效果：
-- 每次对方把怪兽特殊召唤，给这张卡放置1个橡子指示物。可以把这张卡放置的1个橡子指示物取除，选择对方场上存在的1只怪兽破坏。
function c13478040.initial_effect(c)
	c:EnableCounterPermit(0x17)
	-- 每次对方把怪兽特殊召唤，给这张卡放置1个橡子指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c13478040.ctop)
	c:RegisterEffect(e1)
	-- 可以把这张卡放置的1个橡子指示物取除，选择对方场上存在的1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13478040,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c13478040.descost)
	e2:SetTarget(c13478040.destg)
	e2:SetOperation(c13478040.desop)
	c:RegisterEffect(e2)
end
c13478040.mentioned_counter={
	[0x17]=true,
}
-- 定义筛选条件函数 cfilter，检查怪兽是否为特定玩家所特殊召唤，供后续效果判定使用。
function c13478040.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 连续效果的时点处理函数 ctop：当满足对手特殊召唤条件时，给自身添加1个橡子指示物。
function c13478040.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c13478040.cfilter,1,nil,1-tp) then
		e:GetHandler():AddCounter(0x17,1)
	end
end
-- 起动效果的费用检查与扣除函数 descost：确认当前卡是否有足够的橡子指示物可移除作为发动代价，随后移除1个橡子指示物以支付费用。
function c13478040.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x17,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x17,1,REASON_COST)
end
-- 起动效果的选卡目标判定函数 destg：检查对手场上的怪兽是否可作为对象，提示玩家选择并确定最终要破坏的目标卡片集合及数量信息。
function c13478040.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 判断当前连锁中是否存在至少一张满足条件的对方场上怪兽作为可选取的对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向当前效果的控制者显示选择提示，指示玩家从对手场上选择一个怪兽作为破坏对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 执行目标卡片的选择操作：在对方场上的怪兽区域中选取1张卡（不限种类），并将其设为后续处理的操作对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的效果分类信息为破坏类型，并记录已选定的目标卡片组及数量，用于效果结算时的判定依据。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 起动效果的时点处理函数 desop：在效果发动后、对象确定且费用支付完成后的连锁阶段执行，负责实际破坏已选定的目标怪兽。
function c13478040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前操作信息中获取第一张（也是唯一一张）被选定作为破坏对象的卡片引用。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因销毁刚才获取的目标卡片，完成橡子松鼠的二次发动能力的主要功能部分。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
