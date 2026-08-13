--エーリアン・バスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置2个A指示物。
-- ②：把墓地的这张卡除外，以有A指示物放置的1张卡为对象才能发动。那张卡破坏。这个效果在这张卡送去墓地的回合不能发动。
function c58066722.initial_effect(c)
	-- ①：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。给那只怪兽放置2个A指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58066722,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,58066722)
	e1:SetTarget(c58066722.cttg)
	e1:SetOperation(c58066722.ctop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以有A指示物放置的1张卡为对象才能发动。那张卡破坏。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58066722,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,58066723)
	-- 设定发动条件：这张卡送去墓地的回合不能发动这个效果
	e2:SetCondition(aux.exccon)
	-- 设定发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c58066722.destg)
	e2:SetOperation(c58066722.desop)
	c:RegisterEffect(e2)
end
c58066722.counter_add_list={0x100e}
c58066722.mentioned_counter={
	[0x100e]=true,
}
-- 定义过滤器：场上的表侧表示且可以放置2个A指示物的怪兽
function c58066722.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x100e,2)
end
-- 效果①的目标函数：选择场上1只表侧表示怪兽为对象，并设置指示物操作信息
function c58066722.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58066722.ctfilter(chkc) end
	-- 检查场上是否存在1只可以成为对象的表侧表示且可放置A指示物的怪兽
	if chk==0 then return Duel.IsExistingTarget(c58066722.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示：请选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 让玩家选择场上1只表侧表示且可放置A指示物的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58066722.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：本连锁将处理1次放置指示物的操作
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果①的处理函数：给作为对象的表侧表示怪兽放置2个A指示物
function c58066722.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁处理的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,2)
	end
end
-- 定义过滤器：有A指示物放置的卡
function c58066722.desfilter(c)
	return c:GetCounter(0x100e)>0
end
-- 效果②的目标函数：选择场上1张有A指示物放置的卡为对象，并设置破坏操作信息
function c58066722.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c58066722.desfilter(chkc) end
	-- 检查场上是否存在1张可以成为对象的有A指示物放置的卡
	if chk==0 then return Duel.IsExistingTarget(c58066722.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择提示：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张有A指示物放置的卡作为效果对象
	local g=Duel.SelectTarget(tp,c58066722.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：本连锁将破坏作为对象的那1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理函数：将作为对象的卡破坏
function c58066722.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将作为对象的卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
