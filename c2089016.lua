--先史遺産トゥスパ・ロケット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，从卡组·额外卡组把1只「先史遗产」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级或者阶级×200。
-- ②：场上的这张卡为素材作超量召唤的「No.」怪兽得到以下效果。
-- ●这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c2089016.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合，从卡组·额外卡组把1只「先史遗产」怪兽送去墓地，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时下降送去墓地的怪兽的等级或者阶级×200。
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
-- 设置效果标记，用于判断是否满足发动条件。
function c2089016.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数，用于筛选满足条件的「先史遗产」怪兽（等级或阶级大于等于1，且能作为墓地代价）。
function c2089016.costfilter(c)
	return c:IsSetCard(0x70) and c:IsType(TYPE_MONSTER) and (c:IsLevelAbove(1) or c:IsRankAbove(1)) and c:IsAbleToGraveAsCost()
end
-- 处理①效果的发动条件和选择目标，包括检索满足条件的怪兽并将其送去墓地，以及选择场上表侧表示的怪兽作为对象。
function c2089016.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查玩家是否拥有满足条件的「先史遗产」怪兽可作为墓地代价。
		return Duel.IsExistingMatchingCard(c2089016.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
			-- 检查场上是否存在至少1只表侧表示的怪兽作为效果对象。
			and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「先史遗产」怪兽并将其送去墓地。
	local g=Duel.SelectMatchingCard(tp,c2089016.costfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local val=g:GetFirst():GetLevel()
	if g:GetFirst():IsType(TYPE_XYZ) then val=g:GetFirst():GetRank() end
	e:SetLabel(val)
	-- 将选中的怪兽送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	-- 提示玩家选择场上表侧表示的怪兽作为对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上表侧表示的怪兽作为对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理①效果的发动后操作，将目标怪兽的攻击力下降。
function c2089016.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local val=e:GetLabel()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建攻击力变更效果，使目标怪兽的攻击力下降其等级或阶级×200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-val*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 判断是否为超量召唤作为素材的场合。
function c2089016.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ and e:GetHandler():GetReasonCard():IsSetCard(0x48)
end
-- 处理②效果的发动后操作，使超量召唤的「No.」怪兽获得额外攻击次数，并确保其具有效果怪兽类型。
function c2089016.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为超量召唤的「No.」怪兽添加额外攻击次数效果。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(2089016,1))  --"「先史遗产 图什帕火箭」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若超量召唤的「No.」怪兽不具有效果怪兽类型，则为其添加效果怪兽类型。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
