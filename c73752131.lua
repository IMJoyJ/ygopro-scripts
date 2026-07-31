--熟練の黒魔術師
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
function c73752131.initial_effect(c)
	-- 注册卡片记述列表：记述「黑魔术师」
	aux.AddCodeList(c,46986414)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 注册连锁标记辅助函数：在连锁发动时为自身注册连锁FLAG，用于后续确认魔法卡发动
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c73752131.acop)
	c:RegisterEffect(e1)
	-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73752131,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c73752131.spcost)
	e2:SetTarget(c73752131.sptg)
	e2:SetOperation(c73752131.spop)
	c:RegisterEffect(e2)
end
c73752131.mentioned_counter={
	[0x1]=true,
}
-- 放置指示物处理：确认魔法卡发动处理完毕且此卡在发动时已在场，给自身放置1个魔力指示物
function c73752131.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- ②效果发动Cost：把有3个魔力指示物放置的自身解放
function c73752131.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 将自身作为Cost解放送去墓地
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤条件：卡号为46986414（黑魔术师）且可特殊召唤
function c73752131.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动准备：设置从手卡·卡组·墓地特殊召唤「黑魔术师」的操作信息
function c73752131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区域是否有空位（考虑解放自身后的格子）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组·墓地是否存在「黑魔术师」
		and Duel.IsExistingMatchingCard(c73752131.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手卡·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从手卡·卡组·墓地选1只「黑魔术师」特殊召唤
function c73752131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 主要怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组·墓地选择1只受王谷过滤影响的「黑魔术师」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73752131.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
