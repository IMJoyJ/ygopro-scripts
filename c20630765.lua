--魔石術師 クルード
-- 效果：
-- 1回合1次，每次这张卡以外的怪兽的效果发动，给这张卡放置1个魔石指示物（最多1个）。这张卡放置的魔石指示物每有1个，这张卡的守备力上升300。此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外。
function c20630765.initial_effect(c)
	c:EnableCounterPermit(0x16)
	c:SetCounterLimit(0x16,1)
	-- 1回合1次，每次这张卡以外的怪兽的效果发动，给这张卡放置1个魔石指示物（最多1个）。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 在怪兽效果发动的时点记录这张卡在场上存在，用于连锁处理结束时判定是否放置魔石指示物
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 1回合1次，每次这张卡以外的怪兽的效果发动，给这张卡放置1个魔石指示物（最多1个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c20630765.ctop)
	c:RegisterEffect(e1)
	-- 这张卡放置的魔石指示物每有1个，这张卡的守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c20630765.defup)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(20630765,0))  --"除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCost(c20630765.rmcost)
	e3:SetTarget(c20630765.rmtg)
	e3:SetOperation(c20630765.rmop)
	c:RegisterEffect(e3)
end
c20630765.mentioned_counter={
	[0x16]=true,
}
-- 连锁处理结束时，若处理的效果是这张卡以外的怪兽的效果且这张卡在连锁发生时已在场上，给这张卡放置1个魔石指示物
function c20630765.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and c~=e:GetHandler() and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
-- 返回这张卡放置的魔石指示物数量乘以300，作为这张卡的守备力上升值
function c20630765.defup(e,c)
	return c:GetCounter(0x16)*300
end
-- 作为效果的代价，取除自己场上存在的1个魔石指示物
function c20630765.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否能作为代价取除1个魔石指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x16,1,REASON_COST) end
	-- 作为代价取除自己场上存在的1个魔石指示物
	Duel.RemoveCounter(tp,1,0,0x16,1,REASON_COST)
end
-- 选择对方墓地存在的1张可除外的卡作为效果对象，并设置除外分类的操作信息
function c20630765.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可以除外并能成为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 向自己提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地存在的1张可以除外的卡，将其设置为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息：将选中的1张卡从对方墓地除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 取得效果对象卡，若该卡仍与效果相关，将其从游戏中除外
function c20630765.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将效果对象卡以表侧表示从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
