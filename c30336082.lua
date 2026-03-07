--盃満ちる燦幻荘
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，自己主要阶段1内，自己场上的龙族·炎属性怪兽不受对方发动的效果影响。
-- ②：自己主要阶段才能发动。从卡组把1只「天杯龙」怪兽加入手卡。那之后，选自己1张手卡丢弃。
-- ③：战斗阶段中这张卡被破坏的场合，以自己场上1只龙族同调怪兽为对象才能发动。那只怪兽的攻击力变成2倍。
function c30336082.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己主要阶段1内，自己场上的龙族·炎属性怪兽不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c30336082.indcon)
	e2:SetTarget(c30336082.indtg)
	e2:SetValue(c30336082.efilter)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。从卡组把1只「天杯龙」怪兽加入手卡。那之后，选自己1张手卡丢弃。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30336082,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,30336082)
	e3:SetTarget(c30336082.thtg)
	e3:SetOperation(c30336082.thop)
	c:RegisterEffect(e3)
	-- ③：战斗阶段中这张卡被破坏的场合，以自己场上1只龙族同调怪兽为对象才能发动。那只怪兽的攻击力变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30336082,2))  --"攻击力变成2倍"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCondition(c30336082.atkcon)
	e4:SetTarget(c30336082.atktg)
	e4:SetOperation(c30336082.atkop)
	c:RegisterEffect(e4)
end
-- 判断是否处于主要阶段1且为当前回合玩家
function c30336082.indcon(e)
	-- 判断是否处于主要阶段1且为当前回合玩家
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 判断目标怪兽是否为龙族且为炎属性
function c30336082.indtg(e,c)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断效果是否由对方发动且已激活
function c30336082.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 过滤满足条件的「天杯龙」怪兽
function c30336082.filter(c)
	return c:IsSetCard(0x1aa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索和丢弃手卡的效果信息
function c30336082.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c30336082.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡从卡组加入手牌的效果信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置丢弃手卡的效果信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 执行检索与丢弃手卡效果
function c30336082.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c30336082.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 确认卡已加入手牌后执行丢弃手卡操作
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 选择丢弃的手卡
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
		-- 将选中的手卡丢弃至墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 判断是否处于战斗阶段
function c30336082.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 判断目标怪兽是否为龙族同调怪兽
function c30336082.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_DRAGON)
end
-- 设置攻击力变化效果的目标选择
function c30336082.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30336082.atkfilter(chkc) end
	-- 检查是否存在满足条件的攻击目标
	if chk==0 then return Duel.IsExistingTarget(c30336082.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的攻击目标
	Duel.SelectTarget(tp,c30336082.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行攻击力翻倍效果
function c30336082.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置目标怪兽攻击力变为2倍
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(tc:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
