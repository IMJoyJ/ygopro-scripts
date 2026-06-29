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
	-- ①：自己场上的战士族·地属性怪兽被战斗破坏时，这张卡在手卡·墓地存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
		-- 注册全局战斗检测效果以记录本回合进行过战斗的战士族·地属性怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_BATTLE_CONFIRM)
		ge1:SetOperation(c18558867.checkop)
		-- 将战斗检测的全局持续效果注册给系统
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查是否是战士族·地属性怪兽的过滤条件
function c18558867.check(c)
	return c and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 全局战斗检测的逻辑执行
function c18558867.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的怪兽对象
	local c0,c1=Duel.GetBattleMonster(0)
	if c18558867.check(c0) then
		-- 若战士族·地属性怪兽是自己场上的，则在自己身上标记此回合已进行过战斗
		Duel.RegisterFlagEffect(0,18558867,RESET_PHASE+PHASE_END,0,1)
	end
	if c18558867.check(c1) then
		-- 若战士族·地属性怪兽是对方场上的，则在对方身上标记此回合已进行过战斗
		Duel.RegisterFlagEffect(1,18558867,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 直接攻击和攻击力上升效果的发动条件判断
function c18558867.dracon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己本回合是否满足战士族·地属性怪兽进行过战斗的条件
	return Duel.GetFlagEffect(tp,18558867)>0
		-- 检查当前是否正处于双方的战斗阶段，且处于伤害步骤等合理发动时点
		and (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 可增加攻击力的自己场上表侧表示「战吼」怪兽的过滤条件
function c18558867.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x15f)
end
-- 直接攻击和攻击力上升效果的执行
function c18558867.draop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	-- 获取自己场上所有表侧表示的「战吼」怪兽
	local g=Duel.GetMatchingGroup(c18558867.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历自己场上的所有「战吼」怪兽以适用攻击力上升效果
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
-- 被战斗破坏送去墓地的战士族·地属性怪兽的过滤条件
function c18558867.spfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR)
end
-- 战士族·地属性怪兽被破坏特召自身的效果触发条件
function c18558867.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c18558867.spfilter,1,nil,tp)
end
-- 特召自身效果的发动准备
function c18558867.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空闲怪兽区域且此卡能否特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为将自己特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特召自身效果的执行
function c18558867.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡能成功特殊召唤到场上
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
