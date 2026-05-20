--幻影騎士団ラギッドグローブ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的这张卡为素材作超量召唤的暗属性怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。这张卡的攻击力上升1000。
-- ②：把墓地的这张卡除外才能发动。从卡组把1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡送去墓地。
function c63821877.initial_effect(c)
	-- ①：场上的这张卡为素材作超量召唤的暗属性怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCountLimit(1,63821877)
	e1:SetCondition(c63821877.efcon)
	e1:SetOperation(c63821877.efop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1张「幻影骑士团」卡或者「幻影」魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63821877,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,63821878)
	-- 把墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c63821877.tgtg)
	e2:SetOperation(c63821877.tgop)
	c:RegisterEffect(e2)
end
-- 检查是否作为超量召唤素材，且超量召唤的怪兽是否为暗属性
function c63821877.efcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_XYZ and c:GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
-- 为超量召唤的暗属性怪兽注册得到的效果，若该怪兽不是效果怪兽则为其添加“效果怪兽”类型
function c63821877.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合发动。这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(63821877,0))  --"这张卡的攻击力上升1000（幻影骑士团 破手套）"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c63821877.atkcon)
	e1:SetTarget(c63821877.atktg)
	e1:SetOperation(c63821877.atkop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ①：场上的这张卡为素材作超量召唤的暗属性怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 检查该怪兽是否是通过超量召唤特殊召唤
function c63821877.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 攻击力上升效果的发动准备，向对方玩家提示发动了该效果
function c63821877.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示选择发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 攻击力上升效果的处理：使该怪兽的攻击力上升1000
function c63821877.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤卡组中满足条件的「幻影骑士团」卡片或「幻影」魔法·陷阱卡
function c63821877.tgfilter(c)
	return (c:IsSetCard(0x10db) or (c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToGrave()
end
-- 检查卡组中是否存在可送去墓地的目标卡片，并设置送去墓地的操作信息
function c63821877.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c63821877.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为“从卡组将1张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 从卡组选择1张满足条件的卡送去墓地
function c63821877.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c63821877.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
