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
	-- 注册卡名变更效果：这张卡只要在魔法与陷阱区域存在，卡名当作「魔法都市 恩底弥翁」（卡号39910367）使用。
	aux.EnableChangeCode(c,39910367)
	-- ②：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。（前置部分：魔法卡发动时在场记录，用于计数指示物放置效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	-- 在魔法卡发动时记录这张卡存在于场上（chainreg登记连锁发生标志），供连锁处理结束时放置指示物使用。
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
c65342096.mentioned_counter={
	[0x1]=true,
}
-- 连锁处理结束时，若发动的效果是魔法卡的卡的发动且这张卡在发动时存在于场上，则给这张卡放置1个魔力指示物。
function c65342096.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 检查传入的怪兽是否存在、种族为魔法师族、控制者为自己且被战斗破坏确定，用于判定战斗破坏的是自己的魔法师族怪兽。
function c65342096.spconcheck(c,tp)
	return c and c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp) and c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果发动条件：发生了怪兽间的战斗，且攻击方或被攻击的怪兽是被战斗破坏的自己的魔法师族怪兽。
function c65342096.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这次伤害计算后有战斗破坏的目标存在（即发生了怪兽之间的战斗）。
	return Duel.GetAttackTarget()~=nil
		-- 并且攻击的怪兽是被战斗破坏的自己的魔法师族怪兽的情况。
		and (c65342096.spconcheck(Duel.GetAttacker(),tp)
		-- 或者被攻击的怪兽是被战斗破坏的自己的魔法师族怪兽的情况。
		or c65342096.spconcheck(Duel.GetAttackTarget(),tp))
end
-- 发动代价：作为发动的代价，需要取除自己场上6个魔力指示物。
function c65342096.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认能否作为代价取除自己场上6个魔力指示物。
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,6,REASON_COST) end
	-- 作为发动的代价，把自己场上6个魔力指示物取除。
	Duel.RemoveCounter(tp,1,0,0x1,6,REASON_COST)
end
-- 过滤条件：检索可以从手卡·卡组特殊召唤的1只7星以上的魔法师族怪兽。
function c65342096.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标设置：确认自己的主要怪兽区域有空位，且手卡·卡组存在可以特殊召唤的7星以上的魔法师族怪兽。
function c65342096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己的主要怪兽区域存在可以特殊召唤的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认自己的手卡·卡组存在至少1只可以特殊召唤的7星以上的魔法师族怪兽。
		and Duel.IsExistingMatchingCard(c65342096.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：声明这个连锁将进行1次从卡组（或手卡）的特殊召唤处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：自己的主要怪兽区域有空位时，从手卡·卡组选1只7星以上的魔法师族怪兽特殊召唤。
function c65342096.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己的主要怪兽区域有空位，没有则不作处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己提示「请选择要特殊召唤的卡」的选卡信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从手卡·卡组中选择1只7星以上的可以特殊召唤的魔法师族怪兽。
	local g=Duel.SelectMatchingCard(tp,c65342096.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选中的1只7星以上的魔法师族怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
