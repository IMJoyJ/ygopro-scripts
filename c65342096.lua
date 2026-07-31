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
	-- 卡名当作「魔法都市 恩底弥翁」使用
	aux.EnableChangeCode(c,39910367)
	-- ①：连锁登记效果：魔法卡发动时注册连锁Flag标记
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetRange(LOCATION_SZONE)
	-- 连锁注册：为连锁发动的魔法卡设置FLAG_ID_CHAINING标记
	e3:SetOperation(aux.chainreg)
	c:RegisterEffect(e3)
	-- ①：放置魔力指示物效果：每次双方发动魔法卡处理结算时，为此卡放置1个魔力指示物。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EVENT_CHAIN_SOLVED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c65342096.counterop)
	c:RegisterEffect(e4)
	-- ②：去除指示物特召效果：自己的魔法师族怪兽被战斗破坏时，去除自己场上6个魔力指示物才能发动。从手卡·卡组把1只7星以上的魔法师族怪兽特殊召唤。
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
-- 放置魔力指示物处理：确认发动的卡为魔法卡且处于连锁标记中，为此卡添加1个魔力指示物
function c65342096.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 战破检查过滤条件：自己被战斗破坏的魔法师族怪兽
function c65342096.spconcheck(c,tp)
	return c and c:IsRace(RACE_SPELLCASTER) and c:IsControler(tp) and c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果触发条件：存在攻击目标，且攻击怪兽或被攻击怪兽为自己被战破的魔法师族怪兽
function c65342096.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本次战斗是否存在攻击目标（非直接攻击）
	return Duel.GetAttackTarget()~=nil
		-- 检查攻击方是否为自己被战破的魔法师族怪兽
		and (c65342096.spconcheck(Duel.GetAttacker(),tp)
		-- 检查被攻击方是否为自己被战破的魔法师族怪兽
		or c65342096.spconcheck(Duel.GetAttackTarget(),tp))
end
-- ②效果发动Cost：去除自己场上6个魔力指示物
function c65342096.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：自己场上是否有至少6个魔力指示物可去除
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x1,6,REASON_COST) end
	-- 从自己场上去除6个魔力指示物
	Duel.RemoveCounter(tp,1,0,0x1,6,REASON_COST)
end
-- 特召过滤条件：7星以上的魔法师族怪兽且可特殊召唤
function c65342096.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动准备：检查怪兽区空位并确认手卡·卡组是否存在符合条件的怪兽
function c65342096.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组是否存在可特召的7星以上魔法师族怪兽
		and Duel.IsExistingMatchingCard(c65342096.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从手卡·卡组选1只7星以上的魔法师族怪兽表侧表示特殊召唤
function c65342096.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足条件的7星以上魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c65342096.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
