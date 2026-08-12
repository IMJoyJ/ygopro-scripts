--スピリット・バーナー
-- 效果：
-- 1回合1次，可以把装备怪兽变成守备表示。装备怪兽从场上回到手卡让这张卡被送去墓地时，给与对方基本分600分伤害。这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
function c50418970.initial_effect(c)
	-- 装备怪兽从场上回到手卡让这张卡被送去墓地时，给与对方基本分600分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c50418970.target)
	e1:SetOperation(c50418970.operation)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在的场合，可以作为自己的抽卡阶段时进行通常抽卡的代替，把这张卡加入手卡。
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
-- 检测是否有满足条件的怪兽作为装备对象
function c50418970.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否能选择目标怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时要执行的装备操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 将装备卡装备给选中的怪兽
function c50418970.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断装备怪兽是否处于攻击表示且可以改变表示形式
function c50418970.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsAttackPos() and ec:IsCanChangePosition() end
end
-- 将装备怪兽变为守备表示
function c50418970.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备怪兽变为守备表示
	Duel.ChangePosition(e:GetHandler():GetEquipTarget(),POS_FACEUP_DEFENSE)
end
-- 判断该卡因失去装备对象而进入墓地且装备怪兽在手牌中
function c50418970.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_HAND)
end
-- 设置伤害效果的目标玩家和伤害值
function c50418970.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设定伤害效果的伤害值为600
	Duel.SetTargetParam(600)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 对目标玩家造成指定伤害
function c50418970.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否为当前回合玩家触发此效果
function c50418970.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 检测玩家是否可以进行通常抽卡并判断该卡能否送入手卡
function c50418970.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以进行通常抽卡且该卡能被送去手卡
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and e:GetHandler():IsAbleToHand() end
	-- 设置将该卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行将该卡加入手卡的效果处理
function c50418970.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测玩家是否可以进行通常抽卡
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使指定玩家在当前回合放弃通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认该卡
		Duel.ConfirmCards(1-tp,c)
	end
end
