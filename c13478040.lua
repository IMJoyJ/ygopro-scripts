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
-- 过滤函数：判断该卡是否是由指定玩家特殊召唤的怪兽
function c13478040.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 对方特殊召唤成功时触发的处理：若本次特殊召唤的怪兽中有对方特殊召唤的，给这张卡放置1个橡子指示物
function c13478040.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c13478040.cfilter,1,nil,1-tp) then
		e:GetHandler():AddCounter(0x17,1)
	end
end
-- 发动代价：确认这张卡可以取除1个橡子指示物后，将1个橡子指示物取除作为代价
function c13478040.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x17,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x17,1,REASON_COST)
end
-- 目标选择阶段：检查对方场上是否存在可作为对象的怪兽，提示请选择要破坏的卡，选择对方场上1只怪兽作为对象，并设置破坏效果的操作信息
function c13478040.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查对方场上是否存在至少1只可以成为效果对象的怪兽，以确认效果能否发动
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示消息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上玩家视角下对方场上存在的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为破坏效果，破坏对象为目标选择的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：取得当前连锁的对象怪兽，若其仍与本效果相关联，则以效果破坏将其破坏
function c13478040.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
