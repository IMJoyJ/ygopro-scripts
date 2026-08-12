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
		-- 自己的战士族·地属性怪兽进行过战斗的自己·对方的战斗阶段才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(c18558867.checkop)
		-- 把检测战斗的永续效果ge1注册到全局环境，用于记录战士族·地属性怪兽进行过战斗
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：判断卡是否为战士族·地属性怪兽
function c18558867.check(c)
	return c and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 伤害计算前触发的处理：若进行战斗的怪兽是战士族·地属性，则为对应玩家注册本回合的标识效果
function c18558867.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得玩家0当前正处于战斗中的攻击怪兽和攻击对象怪兽
	local c0,c1=Duel.GetBattleMonster(0)
	if c18558867.check(c0) then
		-- 为玩家0注册持续到回合结束的标识效果，记录其战士族·地属性怪兽进行过战斗
		Duel.RegisterFlagEffect(0,18558867,RESET_PHASE+PHASE_END,0,1)
	end
	if c18558867.check(c1) then
		-- 为玩家1注册持续到回合结束的标识效果，记录其战士族·地属性怪兽进行过战斗
		Duel.RegisterFlagEffect(1,18558867,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②效果的发动条件：自己已有战斗记录标识、当前处于战斗阶段且不在伤害计算后
function c18558867.dracon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否已有「战士族·地属性怪兽进行过战斗」的标识记录
	return Duel.GetFlagEffect(tp,18558867)>0
		-- 限制只能在战斗阶段发动，且伤害步骤中只能在伤害计算前发动
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤函数：自己场上表侧表示的「战吼」怪兽
function c18558867.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- ②效果的处理：先赋予这张卡本回合可以直接攻击，再让自己场上全部「战吼」怪兽攻击力上升200直到对方回合结束
function c18558867.draop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 检索自己场上全部表侧表示的「战吼」怪兽
	local g=Duel.GetMatchingGroup(c18558867.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 逐个遍历检索到的「战吼」怪兽进行处理
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
end
-- 过滤函数：被破坏前控制者是自己且为战士族·地属性的怪兽
function c18558867.spfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- ①效果的发动条件：被战斗破坏的怪兽不含这张卡本身，且其中有自己的战士族·地属性怪兽
function c18558867.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c18558867.spfilter,1,nil,tp)
end
-- ①效果的对象确认：自己主要怪兽区有空位且这张卡可以被特殊召唤
function c18558867.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认自己主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：预定将这张卡1张特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：这张卡特殊召唤，并赋予其从场上离开的场合除外的效果
function c18558867.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，则将其以表侧攻击表示特殊召唤到自己场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
