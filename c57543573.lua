--ワーム・イリダン
-- 效果：
-- 每次自己场上有卡被盖放，给这张卡放置1个虫指示物。可以通过把这张卡放置的2个虫指示物取除，选择对方场上1张卡破坏。
function c57543573.initial_effect(c)
	c:EnableCounterPermit(0xf)
	-- 每次自己场上有卡被盖放，给这张卡放置1个虫指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_MSET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c57543573.accon1)
	e1:SetOperation(c57543573.acop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SSET)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_CHANGE_POS)
	e3:SetCondition(c57543573.accon2)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c57543573.accon3)
	c:RegisterEffect(e4)
	-- 可以通过把这张卡放置的2个虫指示物取除，选择对方场上1张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(57543573,0))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCost(c57543573.descost)
	e5:SetTarget(c57543573.destg)
	e5:SetOperation(c57543573.desop)
	c:RegisterEffect(e5)
end
-- 判断被盖放的怪兽是否为自己场上的卡
function c57543573.accon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst():IsControler(tp)
end
-- 过滤出自己场上原本表侧表示且现在变为里侧表示的卡片
function c57543573.filter2(c,tp)
	return c:IsControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()
end
-- 判断是否存在自己场上的卡片变更为里侧表示（盖放）
function c57543573.accon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57543573.filter2,1,nil,tp)
end
-- 过滤出自己场上里侧表示的卡片
function c57543573.filter3(c,tp)
	return c:IsControler(tp) and c:IsFacedown()
end
-- 判断是否存在自己场上的卡片以里侧表示特殊召唤（盖放）
function c57543573.accon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57543573.filter3,1,nil,tp)
end
-- 给这张卡放置1个虫指示物
function c57543573.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xf,1)
end
-- 检查并取除这张卡上的2个虫指示物作为效果发动的代价
function c57543573.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xf,2,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0xf,2,REASON_COST)
end
-- 选择对方场上1张卡作为效果的对象，并设置破坏的操作信息
function c57543573.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 在效果发动时，检查对方场上是否存在可以作为对象的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张卡片作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏选中的对象卡片
function c57543573.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
