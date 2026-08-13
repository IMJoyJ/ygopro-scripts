--先史遺産トゥスパ・ロケット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，从卡组·额外卡组把1只「先史遗产」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级或者阶级×200。
-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。
-- ●这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c2089016.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合，从卡组·额外卡组把1只「先史遗产」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级或者阶级×200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2089016,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,2089016)
	e1:SetCost(c2089016.atkcost)
	e1:SetTarget(c2089016.atktg)
	e1:SetOperation(c2089016.atkop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。●这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,2089017)
	e3:SetCondition(c2089016.effcon)
	e3:SetOperation(c2089016.effop)
	c:RegisterEffect(e3)
end
-- 代价函数：将标签设为100作为已支付送墓代价的标记，返回true允许效果发动；送墓代价的实际选择和处理在target函数中完成。
function c2089016.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 判定卡组·额外卡组的卡是否能作为代价：须为「先史遗产」怪兽、拥有等级或阶级，且可以被送去墓地作为代价。
function c2089016.costfilter(c)
	return c:IsSetCard(0x70) and c:IsType(TYPE_MONSTER) and (c:IsLevelAbove(1) or c:IsRankAbove(1)) and c:IsAbleToGraveAsCost()
end
-- 发动时的目标处理：确认已满足送墓代价且卡组/额外存在符合条件的「先史遗产」怪兽、场上有表侧表示怪兽可取对象后，选择1只「先史遗产」怪兽送去墓地，再选择场上1只表侧表示怪兽作为效果对象。
function c2089016.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查卡组·额外卡组中是否存在至少1只满足costfilter的「先史遗产」怪兽可以作为代价送去墓地。
		return Duel.IsExistingMatchingCard(c2089016.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
			-- 检查双方主要怪兽区是否存在至少1只表侧表示怪兽可以作为效果对象。
			and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	e:SetLabel(0)
	-- 显示选择提示：请选择要送去墓地的卡，用于随后从卡组·额外卡组选择「先史遗产」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组·额外卡组中选择1只满足costfilter的「先史遗产」怪兽，作为代价送去墓地。
	local g=Duel.SelectMatchingCard(tp,c2089016.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local val=g:GetFirst():GetLevel()
	if g:GetFirst():IsType(TYPE_XYZ) then val=g:GetFirst():GetRank() end
	e:SetLabel(val)
	-- 将选择的「先史遗产」怪兽送去墓地，作为效果的发动代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
	-- 显示选择提示：请选择场上1只表侧表示怪兽作为效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果对象，并将其登记为当前连锁的对象（取对象效果）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：取得对象怪兽及记录的等级/阶级数值，若对象怪兽仍表侧表示且与效果关联，则使其攻击力直到回合结束时下降该数值×200。
function c2089016.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时要适用的对象怪兽（发动时选择的场上表侧表示怪兽）。
	local tc=Duel.GetFirstTarget()
	local val=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级或者阶级×200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②效果的触发条件：这张卡作为超量素材被使用（REASON_XYZ），且超量召唤出的怪兽是「No.」怪兽。
function c2089016.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():IsSetCard(0x48)
end
-- ②效果处理：为超量召唤出的「No.」怪兽赋予‘同1次战斗阶段中最多2次可以向怪兽攻击’的效果；若该怪兽不是效果怪兽，则额外使其变成效果怪兽以正确持有该效果。
function c2089016.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(2089016,1))  --"「先史遗产 图什帕火箭」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
