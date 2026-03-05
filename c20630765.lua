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
	-- 记录连锁发生时这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 这张卡放置的魔石指示物每有1个，这张卡的守备力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c20630765.ctop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c20630765.defup)
	c:RegisterEffect(e2)
	-- 效果作用
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
-- 当连锁发动时，若发动的是怪兽卡且不是这张卡本身，则为这张卡添加1个魔石指示物
function c20630765.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and c~=e:GetHandler() and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
-- 每有1个魔石指示物，守备力上升300
function c20630765.defup(e,c)
	return c:GetCounter(0x16)*300
end
-- 支付1个魔石指示物作为费用
function c20630765.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以移除1个魔石指示物
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x16,1,REASON_COST) end
	-- 移除1个魔石指示物作为费用
	Duel.RemoveCounter(tp,1,0,0x16,1,REASON_COST)
end
-- 选择对方墓地存在的1张卡从游戏中除外
function c20630765.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查对方墓地是否存在可除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地的1张卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置操作信息，确定要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 将选中的卡从游戏中除外
function c20630765.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡从游戏中除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
