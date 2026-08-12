--ヴァイロン・フィラメント
-- 效果：
-- 名字带有「大日」的怪兽才能装备。装备怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。场上表侧表示存在的这张卡被送去墓地的场合，可以从自己卡组把1张名字带有「大日」的魔法卡加入手卡。
function c90592429.initial_effect(c)
	-- 名字带有「大日」的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c90592429.target)
	e1:SetOperation(c90592429.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(c90592429.lmop)
	c:RegisterEffect(e2)
	-- 名字带有「大日」的怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c90592429.eqlimit)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地的场合，可以从自己卡组把1张名字带有「大日」的魔法卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90592429,0))  --"检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c90592429.thcon)
	e4:SetTarget(c90592429.thtg)
	e4:SetOperation(c90592429.thop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备在名字带有「大日」的怪兽上
function c90592429.eqlimit(e,c)
	return c:IsSetCard(0x30)
end
-- 过滤条件：场上表侧表示的名字带有「大日」的怪兽
function c90592429.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x30)
end
-- 装备魔法卡发动时的效果处理，选择场上1只表侧表示的「大日」怪兽作为对象
function c90592429.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c90592429.filter(chkc) end
	-- 检查场上是否存在可以装备的、表侧表示的「大日」怪兽
	if chk==0 then return Duel.IsExistingTarget(c90592429.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的「大日」怪兽作为装备对象
	Duel.SelectTarget(tp,c90592429.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，操作对象为这张卡本身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功时的效果处理，将这张卡装备给选择的怪兽
function c90592429.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 装备怪兽攻击时，注册限制对方发动魔陷的效果
function c90592429.lmop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前进行攻击的怪兽是否为这张卡的装备怪兽，若不是则不处理
	if Duel.GetAttacker()~=e:GetHandler():GetEquipTarget() then return end
	-- 对方直到伤害步骤结束时魔法·陷阱卡不能发动。场上表侧表示存在的这张卡被送去墓地的场合，可以从自己卡组把1张名字带有「大日」的魔法卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c90592429.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册该限制效果，使对方在伤害步骤结束前不能发动魔法·陷阱卡
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的卡片类型过滤：仅限制魔法·陷阱卡的发动
function c90592429.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 检索效果的发动条件：这张卡在场上表侧表示存在并被送去墓地
function c90592429.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中名字带有「大日」的魔法卡，且能加入手卡
function c90592429.thfilter(c)
	return c:IsSetCard(0x30) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在符合条件的卡，并设置操作信息
function c90592429.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张名字带有「大日」的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c90592429.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，从卡组选择1张「大日」魔法卡加入手卡并给对方确认
function c90592429.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中选择1张符合条件的「大日」魔法卡
	local g=Duel.SelectMatchingCard(tp,c90592429.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的那张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
