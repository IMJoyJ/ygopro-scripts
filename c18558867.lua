--ウォークライ・バシレオス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己的战士族·地属性怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡可以直接攻击。
function c18558867.initial_effect(c)
	-- ②：自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。自己场上的全部「战吼」怪兽的攻击力直到对方回合结束时上升200。这个回合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18558867,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,18558867)
	e1:SetCondition(c18558867.dracon)
	e1:SetOperation(c18558867.draop)
	c:RegisterEffect(e1)
	-- ①：这张卡在手卡·墓地存在，自己的战士族·地属性怪兽被战斗破坏时才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18558867,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,18558868)
	e2:SetCondition(c18558867.spcon)
	e2:SetTarget(c18558867.sptg)
	e2:SetOperation(c18558867.spop)
	c:RegisterEffect(e2)
	if not c18558867.global_check then
		c18558867.global_check=true
		-- 在战斗开始时，为双方玩家注册标识效果，用于记录是否有战士族·地属性怪兽参与过战斗。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(c18558867.checkop)
		-- 将全局环境下的标识效果ge1注册给玩家0（即自己）。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 定义一个函数，用于判断一张卡是否为战士族且属性为地。
function c18558867.check(c)
	return c and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 当战斗确认阶段触发时，检查当前正在战斗的双方怪兽是否满足战士族·地属性条件，若满足则为对应玩家注册标识效果。
function c18558867.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗的双方怪兽，分别存储在c0和c1中。
	local c0,c1=Duel.GetBattleMonster(0)
	if c18558867.check(c0) then
		-- 为玩家0注册一个标识效果，用于标记其有战士族·地属性怪兽参与过战斗，该效果在结束阶段重置。
		Duel.RegisterFlagEffect(0,18558867,RESET_PHASE+PHASE_END,0,1)
	end
	if c18558867.check(c1) then
		-- 为玩家1注册一个标识效果，用于标记其有战士族·地属性怪兽参与过战斗，该效果在结束阶段重置。
		Duel.RegisterFlagEffect(1,18558867,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断当前是否满足②效果的发动条件：玩家有战士族·地属性怪兽参与过战斗，并且当前处于战斗阶段，同时不在伤害计算后。
function c18558867.dracon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家是否拥有标识效果，即是否有战士族·地属性怪兽参与过战斗。
	return Duel.GetFlagEffect(tp,18558867)>0
		-- 判断当前阶段是否为战斗阶段（包括开始和结束阶段），并且不在伤害计算后。
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 定义一个函数，用于判断一张卡是否为「战吼」怪兽且正面表示。
function c18558867.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 效果处理函数，使自身获得直接攻击能力，并使场上所有「战吼」怪兽攻击力上升200。
function c18558867.draop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使自身获得直接攻击的能力，该效果在结束阶段重置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 获取场上所有正面表示的「战吼」怪兽，组成一个卡片组。
	local g=Duel.GetMatchingGroup(c18558867.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历卡片组中的每张怪兽卡。
	for tc in aux.Next(g) do
		-- 为当前遍历到的怪兽卡增加攻击力200的效果，该效果在结束阶段和对方回合开始时重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(200)
		tc:RegisterEffect(e1)
	end
end
-- 定义一个函数，用于判断一张卡是否为己方控制且属性为地、种族为战士族。
function c18558867.spfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 判断是否满足①效果的发动条件：被战斗破坏的怪兽为己方战士族·地属性怪兽，且不是自己本身。
function c18558867.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c18558867.spfilter,1,nil,tp)
end
-- 设置效果的目标信息，表示将要特殊召唤这张卡。
function c18558867.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤的条件：场上存在空位且该卡可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息，表示将要特殊召唤一张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数，将自身特殊召唤到场上，并注册一个效果使其离开场时被移除。
function c18558867.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否与效果相关联且可以被特殊召唤，若满足则进行特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 为自身注册一个效果，使其在离开场时被移除（即从游戏中移除）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
