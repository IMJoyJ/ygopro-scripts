--魔石術師 クルード
-- 效果：
-- 1回合1次，每次这张卡以外的怪兽的效果发动，给这张卡放置1个魔石指示物（最多1个）。这张卡放置的魔石指示物每有1个，这张卡的守备力上升300。此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外。
function c20630765.initial_effect(c)
	c:EnableCounterPermit(0x16)
	c:SetCounterLimit(0x16,1)
	-- 1回合1次，每次这张卡以外的怪兽的效果发动，给这张卡放置1个魔石指示物（最多1个）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 记录当前连锁中该卡在场上存在（用于后续EVENT_CHAIN_SOLVED时判断是否触发指示物放置）
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c20630765.ctop)
	c:RegisterEffect(e1)
	-- 这张卡放置的魔石指示物每有1个，这张卡的守备力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c20630765.defup)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，可以把自己场上存在的1个魔石指示物取除，选择对方墓地存在的1张卡从游戏中除外
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
-- 当其他怪兽效果发动并解决后，若该卡在事件触发时已在场且未被连锁处理，则为其添加1个魔石指示物
function c20630765.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and c~=e:GetHandler() and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x16,1)
	end
end
-- 返回该卡当前魔石指示物数量乘以300作为守备力修正值
function c20630765.defup(e,c)
	return c:GetCounter(0x16)*300
end
-- 检查并支付1个魔石指示物作为发动除外效果的代价
function c20630765.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp是否能以REASON_COST为原因移除己方场上的魔石指示物（0x16）共1个
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x16,1,REASON_COST) end
	-- 以REASON_COST为原因从己方场上的魔石指示物位置移除1个魔石指示物
	Duel.RemoveCounter(tp,1,0,0x16,1,REASON_COST)
end
-- 选择对方墓地1张可被除外的卡作为目标
function c20630765.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- 检查是否存在对方墓地1张可被除外的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 弹出提示‘请选择要除外的卡’供玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1张可被除外的卡作为目标卡组g
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置当前连锁的操作信息：CATEGORY_REMOVE分类，目标为g，数量1，目标玩家为对方(1-tp)，目标位置为墓地
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
end
-- 获取连锁目标卡并将其以正面表示除外
function c20630765.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡（即rmtg中选择的卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以REASON_EFFECT为原因将目标卡POS_FACEUP除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
