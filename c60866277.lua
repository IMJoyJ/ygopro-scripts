--地殻変動
-- 效果：
-- 自己选择2个属性。对方从那之中选择1个。场上表侧表示存在的选择的属性的怪兽全部破坏。
function c60866277.initial_effect(c)
	-- 自己选择2个属性。对方从那之中选择1个。场上表侧表示存在的选择的属性的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c60866277.target)
	e1:SetOperation(c60866277.operation)
	c:RegisterEffect(e1)
end
-- 定义破坏筛选条件：场上表侧表示且属性与所选择属性（att）一致的怪兽才能被破坏。
function c60866277.desfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 发动条件与目标设定：检查场上是否存在至少两种不同属性的表侧表示怪兽，确认满足发动条件后，设置破坏效果的操作信息。
function c60866277.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得双方场上主要怪兽区域所有表侧表示怪兽的集合，用于后续统计场上存在的属性种类。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then
		if g:GetCount()==0 then return false end
		local tc=g:GetFirst()
		local att=0
		while tc do
			att=bit.bor(att,tc:GetAttribute())
			tc=g:GetNext()
		end
		return bit.band(att,att-1)~=0
	end
	-- 设置操作信息，将该效果标记为破坏效果，候选对象为场上所有表侧表示怪兽，数量记为1（表示至少可能破坏1只），供其他卡片响应此效果。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：重新获取场上表侧表示怪兽，统计其属性，若属性不足两种则结束处理；然后由自己从这些属性中宣言2个，再由对方从这2个属性中宣言1个，最后破坏场上所有符合该属性的表侧表示怪兽。
function c60866277.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次取得场上所有表侧表示怪兽，用于统计当时场上存在的属性，以决定可选属性范围。
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if sg:GetCount()==0 then return false end
	local tc=sg:GetFirst()
	local att=0
	while tc do
		att=bit.bor(att,tc:GetAttribute())
		tc=sg:GetNext()
	end
	if bit.band(att,att-1)==0 then return end
	-- 向自己发送提示消息，提示接下来需要选择要宣言的属性。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让自己从场上表侧表示怪兽拥有的所有属性中选出2个属性，结果保存为att1（属性位组合值）。
	local att1=Duel.AnnounceAttribute(tp,2,att)
	-- 向对方发送提示消息，提示对方需要从自己已选的属性中选择1个。
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让对方从自己选出的2个属性（att1）中选出1个属性，结果保存为att2。
	local att2=Duel.AnnounceAttribute(1-tp,1,att1)
	-- 筛选出场上表侧表示且属性为att2的怪兽集合，作为最终要被破坏的对象。
	local g=Duel.GetMatchingGroup(c60866277.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,att2)
	-- 将刚才筛选出的所有符合条件的怪兽以效果原因（REASON_EFFECT）全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
