--混沌の使者
-- 效果：
-- ①：自己·对方的战斗阶段把这张卡从手卡丢弃，以自己场上1只「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500，这个回合和那只怪兽进行战斗的对方怪兽的攻击力只在伤害计算时变成原本攻击力。
-- ②：自己·对方的结束阶段有这张卡在墓地存在的场合，从自己墓地把这张卡以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡加入手卡。
function c38695361.initial_effect(c)
	-- ①：自己·对方的战斗阶段把这张卡从手卡丢弃，以自己场上1只「混沌战士」怪兽或者「暗黑骑士 盖亚」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500，这个回合和那只怪兽进行战斗的对方怪兽的攻击力只在伤害计算时变成原本攻击力。
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
	-- ②：自己·对方的结束阶段有这张卡在墓地存在的场合，从自己墓地把这张卡以外的光属性和暗属性的怪兽各1只除外才能发动。这张卡加入手卡。
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
-- 效果①的发动条件判定：当前处于战斗阶段（从战斗阶段开始到战斗阶段结束），且满足伤害步骤中只能在伤害计算前发动的限制（非伤害步骤或尚未进行伤害计算）。
function c38695361.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段并存入局部变量ph，用于后续战斗阶段判断。
	local ph=Duel.GetCurrentPhase()
	-- 综合判断当前是否为战斗阶段且满足伤害步骤条件限制，作为效果①可发动的阶段条件。
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果①的代价处理：先检查此卡是否满足从手卡丢弃的条件；满足时将此卡丢弃送入墓地，作为发动代价。
function c38695361.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 以“代价+丢弃”为理由，将效果持有者（此卡）从手卡送去墓地，支付丢弃代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 对象选择过滤条件：怪兽须为表侧表示，且属于「混沌战士」或「暗黑骑士 盖亚」系列。
function c38695361.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10cf,0xbd)
end
-- 效果①的取对象处理：若为连锁中对象合法性检查则确认对象是否合法；若为发动时检查则确认场上是否存在1只符合条件的表侧怪兽；存在则提示选择并让玩家选择自己场上1只符合条件的怪兽作为效果对象。
function c38695361.atktg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38695361.atkfilter(chkc) end
	-- 发动条件检查：确认自己场上是否存在至少1只满足atkfilter的表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c38695361.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送选择提示消息，提示玩家选择表侧表示的卡（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足atkfilter的表侧表示怪兽，并将其设为效果的对象。
	Duel.SelectTarget(tp,c38695361.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：获取对象怪兽；若对象仍与效果关联且表侧表示，则给对象登记本回合标记，使其攻击力上升1500，并额外施加一个持续到回合结束的效果——与该对象战斗的对方怪兽在伤害计算时攻击力变成原本攻击力。
function c38695361.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的第一个效果对象（即选择的那只怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		tc:RegisterFlagEffect(38695361,RESET_EVENT+0x1220000+RESET_PHASE+PHASE_END,0,1)
		-- 那只怪兽的攻击力直到回合结束时上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合和那只怪兽进行战斗的对方怪兽的攻击力只在伤害计算时变成原本攻击力。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_SET_ATTACK_FINAL)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCondition(c38695361.atkcon2)
		e2:SetTarget(c38695361.atktg2)
		e2:SetValue(c38695361.atkval)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 将e2这个“对方怪兽攻击力变成原本攻击力”的持续效果注册到场上，生效玩家为tp，持续到回合结束。
		Duel.RegisterEffect(e2,tp)
	end
end
-- e2效果的适用条件判定：当前处于伤害计算步骤，且被保护的对象怪兽仍带有本回合标记，并且正在与对方怪兽进行战斗。
function c38695361.atkcon2(e)
	local tc=e:GetLabelObject()
	-- 判断当前阶段是否为伤害计算步骤（PHASE_DAMAGE_CAL）。
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
		and tc:GetFlagEffect(38695361)~=0 and tc:GetBattleTarget()
end
-- 筛选e2效果影响的目标：只作用于与所指定的对象怪兽当前进行战斗的对方怪兽。
function c38695361.atktg2(e,c)
	return c==e:GetLabelObject():GetBattleTarget()
end
-- 将适用怪兽的攻击力设定为其原本攻击力（返回基础攻击力）。
function c38695361.atkval(e,c)
	return c:GetBaseAttack()
end
-- 过滤函数：检查怪兽是否满足指定属性且可作为代价除外（用于效果②除外素材的筛选）。
function c38695361.cfilter(c,att)
	return c:IsAttribute(att) and c:IsAbleToRemoveAsCost()
end
-- 效果②代价素材过滤：怪兽须为光属性或暗属性，且能够作为代价除外。
function c38695361.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 效果②的代价处理：从自己墓地获取除这张卡以外、可作为代价除外的光/暗属性怪兽集合；若存在“光属性1只+暗属性1只”的组合则让玩家选择这2张卡，并以表侧表示除外作为代价。
function c38695361.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己墓地中除这张卡以外，能够作为代价除外且属性为光或暗的怪兽集合。
	local g=Duel.GetMatchingGroup(c38695361.spcostfilter,tp,LOCATION_GRAVE,0,c)
	-- 代价检查：判断该集合中是否能选出2张卡，满足一张为光属性、另一张为暗属性（使用aux.gfcheck进行组合检查）。
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK) end
	-- 发送选择提示消息，提示玩家选择要除外的卡（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从集合中选择光属性1只、暗属性1只共2张卡，作为本次代价要除外的对象。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	-- 将选中的2张卡以表侧表示除外（从墓地移除），支付效果②的发动代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
end
-- 效果②的目标确认：检查此卡当前是否可以被加入手卡；可以则设置操作信息，确定处理结果为回手卡。
function c38695361.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理信息：将此卡作为要加入手卡的对象，数量为1，处理时加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的处理：若此卡仍与效果关联，则将其加入持有者手卡，并向对方玩家展示这张卡。
function c38695361.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送去持有者手卡（从墓地加入手卡），原因记为效果处理。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）确认这张卡，展示其已加入手卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
