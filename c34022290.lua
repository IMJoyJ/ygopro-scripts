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
-- 特殊召唤规则的条件判断：当卡片从手卡进行特殊召唤时，确认自己主要怪兽区有空位且自己墓地没有怪兽存在。
function c34022290.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上主要怪兽区是否存在空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己墓地中不存在任何怪兽卡（即没有怪兽存在的场合）。
		and not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER)
end
-- 代价过滤函数：用于选取可作为发动代价的卡，条件为是自己控制的魔法卡且可以作为代价送去墓地。
function c34022290.cfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
-- 发动代价的检查与执行：从这张卡装备的自己场上装备魔法卡中选择1张，将其送去墓地作为发动代价；若不存在这样的卡则不能发动。
function c34022290.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEquipGroup():IsExists(c34022290.cfilter,1,nil,tp) end
	-- 弹出卡片选择提示，让玩家选择要送去墓地的装备魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():FilterSelect(tp,c34022290.cfilter,1,1,nil,tp)
	-- 将选择的装备魔法卡作为代价送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 对象过滤函数：对方墓地的怪兽且可以被除外。
function c34022290.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动时的取对象处理：选择对方墓地1～3只可除外的怪兽作为对象，并设置除外相关操作信息。
function c34022290.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c34022290.rmfilter(chkc) end
	-- 发动条件检查：对方墓地是否存在至少1只符合条件的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c34022290.rmfilter,tp,0,LOCATION_GRAVE,1,nil) end
	-- 弹出卡片选择提示，让玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地选择1～3只符合条件的怪兽，并登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c34022290.rmfilter,tp,0,LOCATION_GRAVE,1,3,nil)
	-- 设置操作信息，声明本次效果将除外所选择的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 效果处理：将仍与效果关联的对象怪兽除外；若除外数量大于0且本卡仍在场上，则攻击力上升除外数量×500直到回合结束。
function c34022290.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中登记的对象卡，并筛选出仍然与效果相关的卡片（如仍在墓地且没被无效等）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象怪兽以表侧表示除外，并记录实际除外的数量ct。
	local ct=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	local c=e:GetHandler()
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时上升这个效果除外的怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
