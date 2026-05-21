--グラビ・クラッシュドラゴン
-- 效果：
-- ①：把自己场上1张表侧表示的永续魔法卡送去墓地，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
function c9391354.initial_effect(c)
	-- ①：把自己场上1张表侧表示的永续魔法卡送去墓地，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9391354,0))  --"怪兽破坏"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c9391354.descost)
	e1:SetTarget(c9391354.destg)
	e1:SetOperation(c9391354.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示且可以作为代价送去墓地的永续魔法卡
function c9391354.cfilter(c)
	return c:IsFaceup() and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and c:IsAbleToGraveAsCost()
end
-- 发动代价：将自己场上1张表侧表示的永续魔法卡送去墓地
function c9391354.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张满足条件的永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c9391354.cfilter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张满足条件的永续魔法卡
	local g=Duel.SelectMatchingCard(tp,c9391354.cfilter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动目标：选择对方场上1只怪兽作为对象，并设置破坏操作信息
function c9391354.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏作为对象的怪兽
function c9391354.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该对象怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
