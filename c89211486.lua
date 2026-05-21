--ジェネクス・ドクター
-- 效果：
-- ①：把自己场上1只表侧表示的「次世代控制员」解放，以场上1张卡为对象才能发动。那张卡破坏。
function c89211486.initial_effect(c)
	-- ①：把自己场上1只表侧表示的「次世代控制员」解放，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89211486,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c89211486.cost)
	e1:SetTarget(c89211486.target)
	e1:SetOperation(c89211486.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：场上表侧表示的「次世代控制员」
function c89211486.cfilter(c)
	return c:IsFaceup() and c:IsCode(68505803)
end
-- 处理发动代价：检查并解放自己场上1只表侧表示的「次世代控制员」
function c89211486.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的满足过滤条件的卡片
	if chk==0 then return Duel.CheckReleaseGroup(tp,c89211486.cfilter,1,e:GetHandler()) end
	-- 让玩家选择自己场上1只满足过滤条件的可解放卡片
	local sg=Duel.SelectReleaseGroup(tp,c89211486.cfilter,1,1,e:GetHandler())
	-- 将选择的卡片作为发动代价解放
	Duel.Release(sg,REASON_COST)
end
-- 处理效果的发动准备：确认并选择场上1张卡作为对象，并注册破坏操作信息
function c89211486.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为效果对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择要破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张卡作为该效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息，表明将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理效果的实际执行：若对象卡片仍适用则将其破坏
function c89211486.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
