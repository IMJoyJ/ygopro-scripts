--スピリット・バーナー
-- 效果：
-- 1回合1次，可以把装备怪兽变成守备表示。装备怪兽从场上回到手卡让这张卡被送去墓地时，给与对方基本分600分伤害。这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
function c50418970.initial_effect(c)
	-- 装备怪兽（这张卡作为装备魔法卡装备给怪兽的发动处理，对应原文中‘装备怪兽’的装备关系）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c50418970.target)
	e1:SetOperation(c50418970.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽（作为装备魔法卡，可以装备给怪兽，原文中‘装备怪兽’的前提）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 1回合1次，可以把装备怪兽变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(50418970,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c50418970.postg)
	e3:SetOperation(c50418970.posop)
	c:RegisterEffect(e3)
	-- 装备怪兽从场上回到手卡让这张卡被送去墓地时，给与对方基本分600分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50418970,1))  --"伤害"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c50418970.damcon)
	e4:SetTarget(c50418970.damtg)
	e4:SetOperation(c50418970.damop)
	c:RegisterEffect(e4)
	-- 这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(50418970,2))  --"加入手卡"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PREDRAW)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCondition(c50418970.retcon)
	e5:SetTarget(c50418970.rettg)
	e5:SetOperation(c50418970.retop)
	c:RegisterEffect(e5)
end
-- 发动时的取对象处理：选择场上1只表侧表示怪兽作为装备对象，并设置将这张卡装备的操作信息。
function c50418970.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：双方场上是否存在至少1只表侧表示怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择装备对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽作为装备对象，并将其登记为连锁对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次发动涉及将这张卡装备的处理，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联且对象怪兽仍表侧，则把这张卡装备给那只怪兽。
function c50418970.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 起动效果的发动条件检查：这张卡的装备怪兽是攻击表示且可以变更表示形式。
function c50418970.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsAttackPos() and ec:IsCanChangePosition() end
end
-- 效果处理：把装备怪兽变更为表侧守备表示。
function c50418970.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 变更装备怪兽的表示形式为表侧守备表示。
	Duel.ChangePosition(e:GetHandler():GetEquipTarget(),POS_FACEUP_DEFENSE)
end
-- 触发条件判断：这张卡因装备怪兽回到手卡而失去装备对象被送去墓地，且那只装备怪兽在手卡。
function c50418970.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_HAND)
end
-- 伤害效果的发动目标设置：将对方玩家设为伤害对象，伤害值为600，并登记伤害操作信息。
function c50418970.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的对象玩家设为对方玩家（作为伤害的承受者）。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为600（伤害数值）。
	Duel.SetTargetParam(600)
	-- 设置操作信息：本次效果处理将造成600点伤害，对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果处理：根据设定的对象玩家和伤害数值给对方造成600点效果伤害。
function c50418970.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中记录的伤害对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 代替抽卡效果的发动条件：当前是这张卡持有者的抽卡阶段，且该玩家为回合玩家。
function c50418970.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果持有者是否为当前回合玩家。
	return tp==Duel.GetTurnPlayer()
end
-- 代替抽卡效果的发动目标检查：玩家本回合可以进行通常抽卡，且这张卡能够加入手卡；并登记回手卡操作信息。
function c50418970.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当前玩家可以进行通常抽卡，且墓地中的这张卡能够加入手卡。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：本次处理将这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 代替抽卡的处理：若仍可通常抽卡，则放弃通常抽卡，将这张卡从墓地加入手卡，并让对方确认。
function c50418970.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前玩家已不能进行通常抽卡，则不执行代替抽卡。
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 让玩家放弃本回合的通常抽卡权利。
	aux.GiveUpNormalDraw(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡从墓地加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
