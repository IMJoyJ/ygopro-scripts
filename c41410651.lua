--斬機刀ナユタ
-- 效果：
-- 电子界族怪兽才能装备。这个卡名的①②的效果1回合各能使用1次。
-- ①：装备怪兽和对方怪兽进行战斗的伤害计算时，从卡组把1只「斩机」怪兽送去墓地才能发动。装备怪兽的攻击力直到回合结束时上升送去墓地的怪兽的攻击力数值。
-- ②：这张卡从魔法与陷阱区域送去墓地的场合，以「斩机刀 那由他」以外的自己墓地1张「斩机」卡为对象才能发动。那张卡加入手卡。
function c41410651.initial_effect(c)
	-- 电子界族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c41410651.target)
	e1:SetOperation(c41410651.activate)
	c:RegisterEffect(e1)
	-- ①：装备怪兽和对方怪兽进行战斗的伤害计算时，从卡组把1只「斩机」怪兽送去墓地才能发动。装备怪兽的攻击力直到回合结束时上升送去墓地的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,41410651)
	e2:SetCost(c41410651.atkcost)
	e2:SetCondition(c41410651.atkcon)
	e2:SetTarget(c41410651.atktg)
	e2:SetOperation(c41410651.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡从魔法与陷阱区域送去墓地的场合，以「斩机刀 那由他」以外的自己墓地1张「斩机」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,41410652)
	e3:SetCondition(c41410651.thcon)
	e3:SetTarget(c41410651.thtg)
	e3:SetOperation(c41410651.thop)
	c:RegisterEffect(e3)
	-- 电子界族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c41410651.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制的判定：判断候选怪兽是否为电子界族怪兽，仅电子界族怪兽才能装备此卡。
function c41410651.eqlimit(e,c)
	return c:IsRace(RACE_CYBERSE)
end
-- 装备发动时选择对象的过滤条件：怪兽需表侧表示且为电子界族。
function c41410651.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 装备魔法卡的发动处理：确认场上存在可装备的表侧表示电子界族怪兽后，选择1只作为装备对象，并设定装备效果的操作信息。
function c41410651.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件检查：场上是否存在至少1只表侧表示且为电子界族的怪兽可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c41410651.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择场上1只表侧表示电子界族怪兽作为此装备卡的装备对象（取对象）。
	Duel.SelectTarget(tp,c41410651.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设定效果处理时进行装备的操作信息：将此卡装备给对象怪兽（CATEGORY_EQUIP）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡和对象怪兽仍与效果关联且对象怪兽仍表侧表示，则将此卡装备给对象怪兽。
function c41410651.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给选择的对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ①效果的发动条件：装备怪兽与对方怪兽进行战斗的伤害计算时（存在对方表侧表示的战斗对象）。
function c41410651.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	return ec and tc and tc:IsFaceup() and tc:IsControler(1-tp)
end
-- ①效果的cost标记：设置label为1表示已进入cost处理，返回true允许发动（实际cost在target中送墓）。
function c41410651.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 筛选满足条件的「斩机」怪兽：属于「斩机」字段、原始攻击力大于0、可以作为cost送去墓地。
function c41410651.atkfilter(c)
	return c:IsSetCard(0x132) and c:GetBaseAttack()>0 and c:IsAbleToGraveAsCost()
end
-- ①效果的发动时点处理：确认卡组中有符合条件的「斩机」怪兽，选择1只送去墓地作为cost，并记录其攻击力数值。
function c41410651.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查卡组中是否存在至少1只满足条件的「斩机」怪兽可供送入墓地。
		return Duel.IsExistingMatchingCard(c41410651.atkfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 向玩家显示“请选择要送去墓地的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1只符合条件的「斩机」怪兽。
	local g=Duel.SelectMatchingCard(tp,c41410651.atkfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的「斩机」怪兽作为cost送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- ①效果处理：若装备怪兽仍表侧表示，则使其攻击力上升cost怪兽的攻击力数值，直到回合结束。
function c41410651.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local atk=e:GetLabel()
	if ec:IsFaceup() then
		-- 装备怪兽的攻击力直到回合结束时上升送去墓地的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：这张卡从魔法与陷阱区域送去墓地（即装备状态下的此卡被送入墓地）。
function c41410651.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- ②效果对象卡的筛选条件：自己墓地的「斩机」卡，且不是「斩机刀 那由他」本身，且可以加入手卡。
function c41410651.thfilter(c)
	return c:IsSetCard(0x132) and not c:IsCode(41410651) and c:IsAbleToHand()
end
-- ②效果的发动处理：确认自己墓地存在符合条件的「斩机」卡，选择1张作为对象，并设定加入手卡的操作信息。
function c41410651.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41410651.thfilter(chkc) end
	-- 发动条件检查：自己墓地是否存在至少1张符合条件的「斩机」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c41410651.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1张符合条件的「斩机」卡作为对象。
	local g=Duel.SelectTarget(tp,c41410651.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设定效果处理时将对象卡加入手卡的操作信息（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若对象卡仍与效果关联，则将其加入持有者的手卡。
function c41410651.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的墓地对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡（作为效果处理的结果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
