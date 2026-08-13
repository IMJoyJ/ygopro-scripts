--ウォークライ・メテオラゴン
-- 效果：
-- ①：这张卡不会被对方的效果破坏。
-- ②：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。这个回合，那只对方怪兽以及原本卡名和那只对方怪兽相同的怪兽的效果无效化。
-- ③：1回合1次，自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
function c10497636.initial_effect(c)
	-- ①：这张卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	-- 设置该效果的判定函数为aux.indoval，当破坏效果来自对方玩家时返回true，使这张卡不会被对方的效果破坏。
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的攻击宣言时才能发动。这个回合，那只对方怪兽以及原本卡名和那只对方怪兽相同的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10497636,0))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c10497636.discon)
	e2:SetTarget(c10497636.distg)
	e2:SetOperation(c10497636.disop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10497636,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(c10497636.atkcon)
	e3:SetTarget(c10497636.atktg)
	e3:SetOperation(c10497636.atkop)
	c:RegisterEffect(e3)
	if not c10497636.global_check then
		c10497636.global_check=true
		-- ③：1回合1次，自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(c10497636.checkop)
		-- 将全局检查效果ge1注册到双方（player=0），使每次伤害计算前都会触发checkop，记录战士族·地属性怪兽是否进行过战斗，为③的发动条件累计标记。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义过滤函数check：判断战斗怪兽是否为战士族且地属性，用于③发动条件中“自己的战士族·地属性怪兽进行过战斗”的检测。
function c10497636.check(c)
	return c and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 在伤害计算前（EVENT_BATTLE_CONFIRM）获取双方战斗怪兽，若己方或对方战斗怪兽是战士族·地属性，则给对应玩家登记标记，用于③的发动条件判定。
function c10497636.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家0和玩家1分别操控的战斗怪兽（无战斗则为nil），存入c0、c1，用于检查双方是否有符合条件的怪兽参与战斗。
	local c0,c1=Duel.GetBattleMonster(0)
	if c10497636.check(c0) then
		-- 玩家0若有符合条件的怪兽进行战斗，则给玩家0注册10497636标记，持续到结束阶段；该标记表示玩家0本回合有战士族·地属性怪兽进行过战斗。
		Duel.RegisterFlagEffect(0,10497636,RESET_PHASE+PHASE_END,0,1)
	end
	if c10497636.check(c1) then
		-- 玩家1若有符合条件的怪兽进行战斗，则给玩家1注册10497636标记，持续到结束阶段；使对方玩家也能在满足条件时发动③。
		Duel.RegisterFlagEffect(1,10497636,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②的发动条件判断：本卡攻击宣言时，获取攻击对象ac，要求ac为表侧表示且是对方怪兽；同时将ac存入效果标签供后续使用。
function c10497636.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=c:GetBattleTarget()
	e:SetLabelObject(ac)
	return ac and ac:IsFaceup() and ac:IsControler(1-tp)
end
-- ②的发动目标函数：由于效果处理时以实际攻击对象为对象，chk==0时直接返回true允许发动；发动时设置操作信息为无效化该攻击对象。
function c10497636.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=e:GetLabelObject()
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使ac怪兽的效果无效化”，供系统与其他卡的效果互动使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,ac,1,0,0)
end
-- ②的效果处理：在攻击对象仍表侧且与战斗相关、能被无效化并仍是对方怪兽时，对其本身及其原本卡名相同的怪兽施加无效化效果，包括EFFECT_DISABLE、EFFECT_DISABLE_EFFECT、场上全局无效和连锁时无效。
function c10497636.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	if ac:IsFaceup() and ac:IsRelateToBattle() and ac:IsCanBeDisabledByEffect(e) and ac:IsControler(1-tp) then
		-- 这个回合，那只对方怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ac:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		ac:RegisterEffect(e2)
		-- 以及原本卡名和那只对方怪兽相同的怪兽的效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(c10497636.distg2)
		e3:SetLabelObject(ac)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 将e3注册到当前玩家tp，持续到结束阶段，使场上所有原本卡名与对象怪兽相同的表侧怪兽效果无效化。
		Duel.RegisterEffect(e3,tp)
		-- ②：这个回合，那只对方怪兽以及原本卡名和那只对方怪兽相同的怪兽的效果无效化。③：1回合1次，自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_SOLVING)
		e4:SetCondition(c10497636.discon2)
		e4:SetOperation(c10497636.disop2)
		e4:SetLabelObject(ac)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 将e4注册到当前玩家tp，e4为连锁处理时的持续效果：若同名怪兽发动效果则将其无效化，从而在效果处理层面无效同名怪兽的效果。
		Duel.RegisterEffect(e4,tp)
	end
end
-- 定义过滤函数distg2：判断怪兽c是否与对象ac具有相同原本卡名，用于e3对场上同名怪兽施加效果无效化。
function c10497636.distg2(e,c)
	local ac=e:GetLabelObject()
	return c:IsOriginalCodeRule(ac:GetOriginalCodeRule())
end
-- 定义discon2：检测当前连锁中发动效果的效果怪兽是否为与对象ac相同原本卡名的怪兽，若是则满足无效化条件。
function c10497636.discon2(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetLabelObject()
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsOriginalCodeRule(ac:GetOriginalCodeRule())
end
-- 定义disop2：当满足discon2时，调用Duel.NegateEffect(ev)无效当前连锁的效果，完成对同名怪兽发动的效果的无效处理。
function c10497636.disop2(e,tp,eg,ep,ev,re,r,rp)
	-- 将连锁序号ev对应的正在处理的效果无效化，从而无效掉同名怪兽发动的效果。
	Duel.NegateEffect(ev)
end
-- ③的发动条件：本回合tp玩家有战士族·地属性怪兽进行过战斗（flag>0），且当前处于战斗阶段，并满足伤害步骤内可发动条件，才允许发动。
function c10497636.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家tp是否拥有10497636标记（数量大于0），表示本回合tp操控的战士族·地属性怪兽进行过战斗，是③的发动前提。
	return Duel.GetFlagEffect(tp,10497636)>0
		-- 确认当前阶段处于战斗阶段（PHASE_BATTLE_START≤当前阶段≤PHASE_BATTLE），并且不在伤害计算后，满足③在战斗阶段的时点要求。
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义atkfilter：筛选自己场上表侧表示且属于「战吼」（0x15f）系列的怪兽，作为③的攻击力上升对象。
function c10497636.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- ③的发动目标函数：若自己场上存在至少1只表侧表示的「战吼」怪兽，则允许发动；不取对象，处理时选择全部符合条件的「战吼」怪兽。
function c10497636.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，若自己场上存在至少1只符合条件的「战吼」怪兽则返回true，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c10497636.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ③的效果处理：先循环为自己场上全部表侧「战吼」怪兽赋予攻击力上升200的效果（持续到对方回合结束）；若本卡仍与效果相关，则再赋予本卡本战斗阶段最多追加1次攻击怪兽的效果。
function c10497636.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上全部表侧表示且属于「战吼」系列的怪兽组g，作为攻击力上升的对象。
	local g=Duel.GetMatchingGroup(c10497636.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 使用aux.Next遍历怪兽组g中的每张卡，对每只「战吼」怪兽都执行后续的攻击力上升效果处理。
	for tc in aux.Next(g) do
		-- 自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(200)
		tc:RegisterEffect(e1)
	end
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中最多2次可以向怪兽攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
