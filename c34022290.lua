--ガーディアン・エアトス
-- 效果：
-- ①：自己墓地没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡装备的自己场上1张装备魔法卡送去墓地，以对方墓地最多3只怪兽为对象才能发动。那些怪兽除外。这张卡的攻击力直到回合结束时上升这个效果除外的怪兽数量×500。
function c34022290.initial_effect(c)
	-- ①：自己墓地没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c34022290.spcon)
	c:RegisterEffect(e1)
	-- ②：把这张卡装备的自己场上1张装备魔法卡送去墓地，以对方墓地最多3只怪兽为对象才能发动。那些怪兽除外。这张卡的攻击力直到回合结束时上升这个效果除外的怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34022290,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c34022290.rmcost)
	e2:SetTarget(c34022290.rmtg)
	e2:SetOperation(c34022290.rmop)
	c:RegisterEffect(e2)
end
-- 检查是否满足特殊召唤条件：场上存在空位且自己墓地没有怪兽
function c34022290.spcon(e,c)
	if c==nil then return true end
	-- 检查场上是否存在空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己墓地是否存在怪兽
		and not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 过滤函数：检查目标是否为自己的魔法卡且能作为费用送去墓地
function c34022290.cfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 效果处理时的费用支付：选择一张自己场上的装备魔法卡送去墓地
function c34022290.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c34022290.cfilter,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c34022290.cfilter,1,1,nil,tp)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数：检查目标是否为可除外的怪兽
function c34022290.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果处理时的发动条件与目标选择：选择对方墓地1~3只怪兽作为除外对象
function c34022290.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c34022290.rmfilter(chkc) end
	-- 检查是否至少存在1只对方墓地的怪兽
	if chk==0 then return Duel.IsExistingTarget(c34022290.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1~3只对方墓地的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,c34022290.rmfilter,tp,0,LOCATION_GRAVE,1,3,nil)
	-- 设置效果操作信息：将要除外的怪兽数量和位置记录到连锁信息中
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：将选中的怪兽除外，并根据除外数量提升自身攻击力
function c34022290.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中指定的目标卡片组，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将符合条件的怪兽除外
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将攻击力提升效果应用到自身
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
