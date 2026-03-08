--斬機刀ナユタ
-- 效果：
-- 电子界族怪兽才能装备。这个卡名的①②的效果1回合各能使用1次。
-- ①：装备怪兽和对方怪兽进行战斗的伤害计算时，从卡组把1只「斩机」怪兽送去墓地才能发动。装备怪兽的攻击力直到回合结束时上升送去墓地的怪兽的攻击力数值。
-- ②：这张卡从魔法与陷阱区域送去墓地的场合，以「斩机刀 那由他」以外的自己墓地1张「斩机」卡为对象才能发动。那张卡加入手卡。
function c41410651.initial_effect(c)
	-- ①：装备怪兽和对方怪兽进行战斗的伤害计算时，从卡组把1只「斩机」怪兽送去墓地才能发动。装备怪兽的攻击力直到回合结束时上升送去墓地的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c41410651.target)
	e1:SetOperation(c41410651.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡从魔法与陷阱区域送去墓地的场合，以「斩机刀 那由他」以外的自己墓地1张「斩机」卡为对象才能发动。那张卡加入手卡。
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
	-- 电子界族怪兽才能装备。这个卡名的①②的效果1回合各能使用1次。
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
	-- 装备对象必须为电子界族怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c41410651.eqlimit)
	c:RegisterEffect(e4)
end
-- 设置装备对象为电子界族怪兽
function c41410651.eqlimit(e,c)
	return c:IsRace(RACE_CYBERSE)
end
-- 过滤满足条件的电子界族怪兽
function c41410651.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 选择装备目标怪兽
function c41410651.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查是否存在满足条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(c41410651.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,c41410651.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡牌效果执行
function c41410651.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判断是否满足攻击力提升效果发动条件
function c41410651.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local tc=ec:GetBattleTarget()
	return ec and tc and tc:IsFaceup() and tc:IsControler(1-tp)
end
-- 设置攻击力提升效果的发动成本
function c41410651.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤满足条件的「斩机」怪兽
function c41410651.atkfilter(c)
	return c:IsSetCard(0x132) and c:GetBaseAttack()>0 and c:IsAbleToGraveAsCost()
end
-- 攻击力提升效果的发动处理
function c41410651.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查是否存在满足条件的「斩机」怪兽
		return Duel.IsExistingMatchingCard(c41410651.atkfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示选择送去墓地的「斩机」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择送去墓地的「斩机」怪兽
	local g=Duel.SelectMatchingCard(tp,c41410651.atkfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetAttack())
end
-- 攻击力提升效果的发动处理
function c41410651.atkop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local atk=e:GetLabel()
	if ec:IsFaceup() then
		-- 为装备怪兽增加攻击力
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
-- 判断是否满足墓地效果发动条件
function c41410651.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤满足条件的「斩机」卡
function c41410651.thfilter(c)
	return c:IsSetCard(0x132) and not c:IsCode(41410651) and c:IsAbleToHand()
end
-- 选择墓地中的「斩机」卡
function c41410651.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41410651.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地「斩机」卡
	if chk==0 then return Duel.IsExistingTarget(c41410651.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示选择加入手牌的「斩机」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择加入手牌的「斩机」卡
	local g=Duel.SelectTarget(tp,c41410651.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置墓地效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 墓地效果的发动处理
function c41410651.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的墓地目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
