--サイバース・アクセラレーター
-- 效果：
-- 衍生物以外的怪兽2只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：自己·对方的战斗阶段可以以这张卡所连接区1只电子界族怪兽为对象从以下效果选择1个发动。这个效果发动的回合，这张卡不能攻击。
-- ●那只怪兽的攻击力直到回合结束时上升2000。
-- ●这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c89238128.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只以上衍生物以外的怪兽作为素材。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2)
	-- ①：自己·对方的战斗阶段可以以这张卡所连接区1只电子界族怪兽为对象从以下效果选择1个发动。这个效果发动的回合，这张卡不能攻击。●那只怪兽的攻击力直到回合结束时上升2000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89238128,0))  --"攻击力上升"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,89238128)
	e1:SetCondition(c89238128.atkcon)
	e1:SetCost(c89238128.cost)
	e1:SetTarget(c89238128.atktg)
	e1:SetOperation(c89238128.atkop)
	c:RegisterEffect(e1)
	-- ①：自己·对方的战斗阶段可以以这张卡所连接区1只电子界族怪兽为对象从以下效果选择1个发动。这个效果发动的回合，这张卡不能攻击。●这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89238128,1))  --"多次攻击"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,89238128)
	e2:SetCondition(c89238128.excon)
	e2:SetCost(c89238128.cost)
	e2:SetTarget(c89238128.extg)
	e2:SetOperation(c89238128.exop)
	c:RegisterEffect(e2)
end
-- 效果1（攻击力上升）的发动条件判定函数：处于双方的战斗阶段，且不在伤害计算后。
function c89238128.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为战斗阶段。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
		-- 判定当前是否不在伤害计算后（允许在伤害步骤的其他时点发动）。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果发动的Cost判定与执行函数：检查自身本回合是否未宣言攻击，并使自身本回合不能攻击。
function c89238128.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 过滤出处于这张卡所连接区的表侧表示电子界族怪兽。
function c89238128.atkfilter(c,lg)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and lg and lg:IsContains(c)
end
-- 效果1（攻击力上升）的对象选择与目标确认函数。
function c89238128.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c89238128.atkfilter(chkc,lg) end
	-- 判定是否存在可作为效果1对象的、处于所连接区的表侧表示电子界族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c89238128.atkfilter,tp,LOCATION_MZONE,0,1,nil,lg) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择所连接区的1只表侧表示电子界族怪兽作为效果对象。
	Duel.SelectTarget(tp,c89238128.atkfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
end
-- 效果1（攻击力上升）的效果处理函数。
function c89238128.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- ●那只怪兽的攻击力直到回合结束时上升2000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(2000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
-- 效果2（多次攻击）的发动条件判定函数：处于双方的战斗阶段。
function c89238128.excon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为战斗阶段。
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 过滤出处于这张卡所连接区、尚未获得追加攻击怪兽效果的表侧表示电子界族怪兽。
function c89238128.exfilter(c,lg)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE) and c:GetEffectCount(EFFECT_EXTRA_ATTACK_MONSTER)==0 and lg and lg:IsContains(c)
end
-- 效果2（多次攻击）的对象选择与目标确认函数。
function c89238128.extg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lg=e:GetHandler():GetLinkedGroup()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c89238128.exfilter(chkc,lg) end
	-- 判定是否存在可作为效果2对象的、处于所连接区的表侧表示电子界族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c89238128.exfilter,tp,LOCATION_MZONE,0,1,nil,lg) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择所连接区的1只表侧表示电子界族怪兽作为效果对象。
	Duel.SelectTarget(tp,c89238128.exfilter,tp,LOCATION_MZONE,0,1,1,nil,lg)
end
-- 效果2（多次攻击）的效果处理函数。
function c89238128.exop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- ●这个回合，那只怪兽在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
