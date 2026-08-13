--薔薇の刻印
-- 效果：
-- 从自己墓地把1只植物族怪兽除外，以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
-- ①：得到装备怪兽的控制权。
-- ②：自己结束阶段发动。这张卡的①的效果直到下次的自己准备阶段无效。
function c45247637.initial_effect(c)
	-- 从自己墓地把1只植物族怪兽除外，以对方场上1只表侧表示怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCost(c45247637.cost)
	e1:SetTarget(c45247637.target)
	e1:SetOperation(c45247637.operation)
	c:RegisterEffect(e1)
	-- ②：自己结束阶段发动。这张卡的①的效果直到下次的自己准备阶段无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45247637,0))  --"控制权转移"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c45247637.retcon)
	e2:SetOperation(c45247637.retop)
	c:RegisterEffect(e2)
	-- ①：得到装备怪兽的控制权。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_CONTROL)
	e4:SetCondition(c45247637.ctcon)
	e4:SetValue(c45247637.ctval)
	c:RegisterEffect(e4)
	-- 以对方场上1只表侧表示怪兽为对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c45247637.eqlimit)
	c:RegisterEffect(e5)
end
-- 发动代价的筛选条件：检查是否为植物族怪兽且可以除外。
function c45247637.costfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemove()
end
-- 发动代价：从自己墓地选择1只植物族怪兽除外。
function c45247637.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 非处理阶段时检查自己墓地是否存在1只可除外的植物族怪兽，满足才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c45247637.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足条件的植物族怪兽作为除外对象。
	local g=Duel.SelectMatchingCard(tp,c45247637.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的植物族怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 对象筛选条件：怪兽必须是表侧表示。
function c45247637.filter(c)
	return c:IsFaceup()
end
-- 取对象处理：选择对方场上1只表侧表示怪兽作为对象，并设置改变控制权与装备的操作信息。
function c45247637.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c45247637.filter(chkc) end
	-- 非处理阶段时检查对方场上是否存在1只表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c45247637.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要改变控制权的怪兽”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方场上选择1只表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c45247637.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将操作信息设为改变控制权，目标为所选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 将操作信息设为装备，目标为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：此卡只能装备给控制者不是这张卡持有者的怪兽，或已经装备的怪兽，从而限定为发动时选择的对方怪兽。
function c45247637.eqlimit(e,c)
	return e:GetHandlerPlayer()~=c:GetControler() or e:GetHandler():GetEquipTarget()==c
end
-- 效果处理：这张卡仍存在且对象仍在场时，将这张卡作为装备魔法卡装备给对象怪兽。
function c45247637.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将这张卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- ②效果的发动条件：自己的结束阶段。
function c45247637.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定发动者为当前回合玩家，即仅在自己回合的结束阶段发动。
	return tp==Duel.GetTurnPlayer()
end
-- ②效果处理：给这张卡设置标志，使其在下次自己的准备阶段前①的效果无效。
function c45247637.retop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(45247637,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
end
-- ①效果的控制权转移仅在未设置②效果的标志时生效，即②发动后①在下次准备阶段前无效。
function c45247637.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(45247637)==0
end
-- 将装备怪兽的控制权设置为这张卡的持有者（即这张卡的控制者）。
function c45247637.ctval(e,c)
	return e:GetHandlerPlayer()
end
