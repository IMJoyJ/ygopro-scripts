--魔法都市の実験施設
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：这张卡只要在魔法与陷阱区域存在，卡名当作「魔法都市 恩底弥翁」使用。
-- ②：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ③：1回合1次，自己的魔法师族怪兽被战斗破坏的伤害计算后，把自己场上6个魔力指示物取除才能发动。从手卡·卡组把1只7星以上的魔法师族怪兽特殊召唤。
function c65342096.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65342096+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e1)
	-- 使这张卡在魔法与陷阱区域存在时，卡名当作「魔法都市 恩底弥翁」使用。
	aux.EnableChangeCode(c,39910367)
	-- ②：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	-- 设置效果处理为：在连锁发生时，在这张卡上注册一个标记，用于记录该连锁中有魔法卡发动。
	e3:SetOperation(aux.chainreg)
	c:RegisterEffect(e3)
	-- ②：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c65342096.counterop)
	c:RegisterEffect(e4)
	-- ③：1回合1次，自己的魔法师族怪兽被战斗破坏的伤害计算后，把自己场上6个魔力指示物取除才能发动。从手卡·卡组把1只7星以上的魔法师族怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(65342096,0))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_BATTLED)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c65342096.spcon)
	e5:SetCost(c65342096.spcost)
	e5:SetTarget(c65342096.sptg)
	e5:SetOperation(c65342096.spop)
	c:RegisterEffect(e5)
end
-- 魔法卡发动连锁处理完毕时的处理：若该连锁中确实发动了魔法卡，且本卡在场，则给本卡放置1个魔力指示物。
function c65342096.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检查怪兽是否为自己场上的魔法师族怪兽，且在战斗中被破坏。
function c65342096.spconcheck(c,tp)
	return c and c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp) and c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 检查特殊召唤效果的发动条件：必须存在攻击对象，且攻击怪兽或被攻击怪兽中有一方是自己被战斗破坏的魔法师族怪兽。
function c65342096.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在攻击对象（即不是直接攻击）。
	return Duel.GetAttackTarget()~=nil
		-- 并且（攻击怪兽是自己被战斗破坏的魔法师族怪兽
		and (c65342096.spconcheck(Duel.GetAttacker(),tp)
		-- 或者被攻击怪兽是自己被战斗破坏的魔法师族怪兽）。
		or c65342096.spconcheck(Duel.GetAttackTarget(),tp))
end
-- 特殊召唤效果的发动代价：从自己场上移去6个魔力指示物。
function c65342096.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：检查自己场上是否能移去6个魔力指示物作为代价。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,6,REASON_COST) end
	-- 执行阶段：从自己场上移去6个魔力指示物。
	Duel.RemoveCounter(tp,1,0,0x1,6,REASON_COST)
end
-- 过滤条件：7星以上的、可以被特殊召唤的魔法师族怪兽。
function c65342096.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动目标：检查怪兽区域是否有空位，且手卡或卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息。
function c65342096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己的手卡或卡组中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c65342096.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的效果处理：从手卡或卡组选择1只7星以上的魔法师族怪兽特殊召唤到场上。
function c65342096.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡或卡组中选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c65342096.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
