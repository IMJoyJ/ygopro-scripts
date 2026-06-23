--混沌の使者
-- 效果：
-- ①：自己·对方的战斗阶段把这张卡从手卡丢弃，以自己场上1只「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500，这个回合和那只怪兽进行战斗的对方怪兽的攻击力只在伤害计算时变成原本攻击力。
-- ②：自己·对方的结束阶段有这张卡在墓地存在的场合，从自己墓地把这张卡以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡加入手卡。
function c38695361.initial_effect(c)
	-- 效果①：自己·对方的战斗阶段把这张卡从手卡丢弃，以自己场上1只「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500，这个回合和那只怪兽进行战斗的对方怪兽的攻击力只在伤害计算时变成原本攻击力。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38695361,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c38695361.atkcon1)
	e1:SetCost(c38695361.atkcost)
	e1:SetTarget(c38695361.atktg1)
	e1:SetOperation(c38695361.atkop)
	c:RegisterEffect(e1)
	-- 效果②：自己·对方的结束阶段有这张卡在墓地存在的场合，从自己墓地把这张卡以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38695361,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCost(c38695361.thcost)
	e2:SetTarget(c38695361.thtg)
	e2:SetOperation(c38695361.thop)
	c:RegisterEffect(e2)
end
-- 判断当前是否处于战斗阶段（包括战斗阶段开始到战斗阶段结束），并且不能在伤害步骤发动。
function c38695361.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 如果当前阶段在战斗阶段开始到战斗阶段结束之间，并且满足不能在伤害步骤发动的条件，则返回真。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果①的发动费用：将此卡从手牌丢弃。
function c38695361.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手牌送去墓地作为发动费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选场上表侧表示的「混沌战士」或「暗黑骑士 盖亚」怪兽。
function c38695361.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10cf,0xbd)
end
-- 效果①的发动目标选择：选择场上1只符合条件的怪兽作为对象。
function c38695361.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38695361.atkfilter(chkc) end
	-- 检查是否有符合条件的怪兽可以作为目标。
	if chk==0 then return Duel.IsExistingTarget(c38695361.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的怪兽作为对象。
	Duel.SelectTarget(tp,c38695361.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：使目标怪兽攻击力上升1500，并设置伤害计算时对方怪兽攻击力变为原本攻击力的效果。
function c38695361.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:RegisterFlagEffect(38695361,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,0,1)
		-- 使目标怪兽的攻击力上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 设置伤害计算时对方怪兽攻击力变为原本攻击力的效果。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCondition(c38695361.atkcon2)
		e2:SetTarget(c38695361.atktg2)
		e2:SetValue(c38695361.atkval)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将效果注册到场上。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害计算时的触发条件：当前阶段为伤害计算阶段，并且目标怪兽有标记且有战斗对手。
function c38695361.atkcon2(e)
	local tc=e:GetLabelObject()
	-- 判断当前阶段是否为伤害计算阶段。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and tc:GetFlagEffect(38695361)~=0 and tc:GetBattleTarget()
end
-- 设定伤害计算时对方怪兽攻击力变为原本攻击力的目标。
function c38695361.atktg2(e,c)
	return c==e:GetLabelObject():GetBattleTarget()
end
-- 设定伤害计算时对方怪兽攻击力变为原本攻击力的值。
function c38695361.atkval(e,c)
	return c:GetBaseAttack()
end
-- 筛选属性为指定属性且可以作为费用除外的卡。
function c38695361.cfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
-- 筛选墓地中光属性和暗属性的怪兽。
function c38695361.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 效果②的发动费用：从墓地除外1只光属性和1只暗属性的怪兽。
function c38695361.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取墓地中符合条件的怪兽组。
	local g=Duel.GetMatchingGroup(c38695361.spcostfilter,tp,LOCATION_GRAVE,0,c)
	-- 检查是否有满足条件的2张怪兽可以除外。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张怪兽除外。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选中的怪兽除外作为发动费用。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果②的发动目标：将此卡加入手牌。
function c38695361.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将此卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将此卡加入手牌并确认。
function c38695361.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认此卡加入手牌。
		Duel.ConfirmCards(1-tp,c)
	end
end
