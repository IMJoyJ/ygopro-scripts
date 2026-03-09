--サイバー・ドラゴン・ズィーガー
-- 效果：
-- 包含「电子龙」的机械族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡没有攻击宣言的自己·对方的战斗阶段，以自己场上1只攻击力2100以上的机械族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2100。这个效果的发动后，直到回合结束时这张卡的战斗的双方的战斗伤害变成0。
function c46724542.initial_effect(c)
	-- 为该怪兽添加融合召唤时允许使用的素材卡牌代码，即电子龙（70095154）
	aux.AddMaterialCodeList(c,70095154)
	c:EnableReviveLimit()
	-- 设置连接召唤所需的条件：使用2只满足种族为机械族的卡片作为连接素材，并且其中至少包含一张电子龙（70095154）的卡片
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2,c46724542.lcheck)
	-- 使该怪兽在场上或墓地中时，其卡号被视为电子龙（70095154）
	aux.EnableChangeCode(c,70095154,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡没有攻击宣言的自己·对方的战斗阶段，以自己场上1只攻击力2100以上的机械族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2100。这个效果的发动后，直到回合结束时这张卡的战斗的双方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46724542,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,46724542)
	e2:SetCondition(c46724542.condition)
	e2:SetTarget(c46724542.target)
	e2:SetOperation(c46724542.operation)
	c:RegisterEffect(e2)
end
-- 连接召唤时检查所选素材中是否包含电子龙（70095154）的卡片
function c46724542.lcheck(g,lc)
	return g:IsExists(Card.IsLinkCode,1,nil,70095154)
end
-- 判断当前是否处于战斗阶段开始到战斗阶段结束之间，并且未在伤害步骤中发动效果，同时该卡没有进行过攻击宣言
function c46724542.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于战斗阶段开始到战斗阶段结束之间
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 判断当前未在伤害步骤中发动效果并且该卡没有进行过攻击宣言
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetAttackAnnouncedCount()<1
end
-- 过滤满足条件的怪兽：表侧表示、攻击力不低于2100、种族为机械族
function c46724542.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(2100) and c:IsRace(RACE_MACHINE)
end
-- 选择目标：选择自己场上满足条件的1只怪兽作为对象
function c46724542.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46724542.filter(chkc) end
	-- 判断是否能选择到满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c46724542.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为对象
	Duel.SelectTarget(tp,c46724542.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：为选中的目标怪兽增加攻击力和守备力，并使该卡在战斗阶段中不受战斗伤害
function c46724542.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽的攻击力上升2100点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
	if c:IsRelateToEffect(e) then
		-- 使该卡在战斗阶段中不受战斗伤害
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
		-- 使该卡在战斗阶段中避免受到战斗伤害
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetValue(1)
		c:RegisterEffect(e4)
	end
end
