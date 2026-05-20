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
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c58066722.destg)
	e2:SetOperation(c58066722.desop)
	c:RegisterEffect(e2)
end
c58066722.counter_add_list={0x100e}
-- 过滤条件：场上表侧表示且可以放置A指示物的怪兽
function c58066722.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(0x100e,2)
end
-- 效果①的发动准备（选择放置指示物的对象）
function c58066722.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c58066722.ctfilter(chkc) end
	-- 判断场上是否存在可以放置A指示物的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c58066722.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要放置指示物的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58066722.ctfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0)
end
-- 效果①的处理（给对象怪兽放置2个A指示物）
function c58066722.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x100e,2)
	end
end
-- 过滤条件：放置有A指示物的卡
function c58066722.desfilter(c)
	return c:GetCounter(0x100e)>0
end
-- 效果②的发动准备（选择破坏的对象）
function c58066722.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c58066722.desfilter(chkc) end
	-- 判断场上是否存在放置有A指示物的卡
	if chk==0 then return Duel.IsExistingTarget(c58066722.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张放置有A指示物的卡作为效果对象
	local g=Duel.SelectTarget(tp,c58066722.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理（破坏对象卡）
function c58066722.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏作为对象的卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
