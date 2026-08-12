--ARG☆S－飛燕のカパネ
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己的战士族怪兽不会被战斗破坏。
-- ②：1回合1次，怪兽区域有永续陷阱卡存在的场合才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己的「阿尔戈☆群星」怪兽除外中的场合，再让自己回复500基本分。
-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔陷发动、①效果（战破抗性）、②效果（特招/回复）以及怪兽状态下的③效果（放置回魔陷区）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己的战士族怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indfilter)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：1回合1次，怪兽区域有永续陷阱卡存在的场合才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。自己的「阿尔戈☆群星」怪兽除外中的场合，再让自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"表侧表示放置"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 过滤属于战士族的怪兽，用于战破抗性效果。
function s.indfilter(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤场上表侧表示存在的永续陷阱卡。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS)
end
-- 特殊召唤效果的发动条件：怪兽区域有永续陷阱卡存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方怪兽区域是否存在至少1张表侧表示的永续陷阱卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶向/可行性检查，确认怪兽区域有空位、未在此回合发动过此效果，且玩家可以特殊召唤该陷阱怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位，且本回合该卡未注册过同名效果的Flag（防止同一次连锁中重复发动）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(id)==0
		-- 检查玩家是否能将该卡作为特定属性、种族、等级和攻守的陷阱怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁运营信息，声明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理逻辑：将自身作为陷阱怪兽特殊召唤，若有「阿尔戈☆群星」怪兽被除外，则回复500基本分。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次确认是否满足特殊召唤该陷阱怪兽的条件，不满足则直接结束。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 尝试将自身以表侧表示特殊召唤，并检查是否特殊召唤成功。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查除外区是否存在己方表侧表示的「阿尔戈☆群星」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_REMOVED,0,1,nil) then
		-- 中断当前效果处理，使后续的回复基本分处理与特殊召唤不视为同时进行。
		Duel.BreakEffect()
		-- 让发动效果的玩家回复500基本分。
		Duel.Recover(tp,500,REASON_EFFECT)
	end
end
-- 过滤除外区中表侧表示的「阿尔戈☆群星」怪兽。
function s.cfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1c1)
end
-- 放置效果的发动条件：自身未被战斗破坏，且是通过自身效果特殊召唤上场的。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 放置效果的靶向/可行性检查，确认魔法与陷阱区域有空位，且自身可以被放置到场上。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查魔法与陷阱区域是否有空余的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsCanBePlacedOnField() end
end
-- 放置效果的处理逻辑：若魔法与陷阱区域有空位，且自身仍存在于场上，则将自身表侧表示移动到魔法与陷阱区域。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若魔法与陷阱区域已无空位，则直接结束。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身移动到魔法与陷阱区域表侧表示放置，并立刻适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
