--サイバー・ドラゴン・ズィーガー
-- 效果：
-- 包含「电子龙」的机械族怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「电子龙」使用。
-- ②：这张卡没有攻击宣言的自己·对方的战斗阶段，以自己场上1只攻击力2100以上的机械族怪兽为对象才能发动。那只怪兽的攻击力·守备力直到回合结束时上升2100。这个效果的发动后，直到回合结束时这张卡的战斗的双方的战斗伤害变成0。
function c46724542.initial_effect(c)
	-- 为这张卡声明连接素材包含卡号70095154（「电子龙」），将其加入素材卡名列表，以便相关素材条件判定。
	aux.AddMaterialCodeList(c,70095154)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用2只机械族连接怪兽作为素材，且必须包含1只卡号70095154（「电子龙」）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2,c46724542.lcheck)
	-- 为这张卡注册卡名变更效果：在场上·墓地存在时卡名当作「电子龙」使用。
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
-- 连接素材追加检查：确认素材组中存在至少1只卡号70095154（「电子龙」）的怪兽。
function c46724542.lcheck(g,lc)
	return g:IsExists(Card.IsLinkCode,1,nil,70095154)
end
-- 效果发动条件：处于自己或对方的战斗阶段，且满足伤害步骤内可发动条件，并且这张卡本回合尚未进行攻击宣言。
function c46724542.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段处于战斗阶段开始到战斗阶段结束之间，满足“战斗阶段”的时点要求。
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
		-- 满足伤害步骤限制条件（非伤害步骤或伤害计算前），且这张卡本回合没有攻击宣言过。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetAttackAnnouncedCount()<1
end
-- 对象过滤条件：表侧表示的机械族怪兽，且攻击力在2100以上。
function c46724542.filter(c)
	return c:IsFaceup() and c:IsAttackAbove(2100) and c:IsRace(RACE_MACHINE)
end
-- 效果发动时的对象选择处理：校验指定对象是否合法，确认存在可选对象后，选择自己场上1只符合条件的表侧表示机械族怪兽作为对象。
function c46724542.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c46724542.filter(chkc) end
	-- 发动前检查：自己场上是否存在至少1只满足条件的表侧表示机械族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c46724542.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择表侧表示的卡”的提示信息，引导玩家选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只符合条件的表侧表示机械族怪兽，并将其设为当前连锁的效果对象。
	Duel.SelectTarget(tp,c46724542.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 那只怪兽的攻击力·守备力直到回合结束时上升2100。这个效果的发动后，直到回合结束时这张卡的战斗的双方的战斗伤害变成0。
function c46724542.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到回合结束时上升2100。
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
		-- 这个效果的发动后，直到回合结束时这张卡的战斗的双方的战斗伤害变成0。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
		-- 这个效果的发动后，直到回合结束时这张卡的战斗的双方的战斗伤害变成0。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetValue(1)
		c:RegisterEffect(e4)
	end
end
