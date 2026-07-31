--熟練の黒魔術師
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物（最多3个）。
-- ②：把有3个魔力指示物放置的这张卡解放才能发动。从自己的手卡·卡组·墓地选1只「黑魔术师」特殊召唤。
function c73752131.initial_effect(c)
	-- 注册卡片记述列表：记述「黑魔术师」
	aux.AddCodeList(c,46986414)
	c:EnableCounterPermit(0x1)
	c:SetCounterLimit(0x1,3)
	-- 注册连锁检测效果：在魔法卡发动时注册FLAG标记，供放置魔力指示物效果判定
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 连锁注册处理：在连锁发动时为自身注册FLAG标记
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
-- 放置指示物处理：在魔法卡发动且连锁处理结束时，给自身放置1个魔力指示物
function c73752131.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- ②效果发动Cost：解放放置有3个魔力指示物的自身
function c73752131.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x1)==3 and e:GetHandler():IsReleasable() end
	-- 解放自身作为发动Cost
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤条件：卡名为「黑魔术师」且可以特殊召唤
function c73752131.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动准备：检查怪兽区域空位及手牌·卡组·墓地是否存在「黑魔术师」
function c73752131.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：计算解放自身后怪兽区域是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 发动条件检查：手牌·卡组·墓地是否存在可特殊召唤的「黑魔术师」
		and Duel.IsExistingMatchingCard(c73752131.filter,tp,0x13,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从手牌·卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果处理：从手牌·卡组·墓地选择1只「黑魔术师」表侧表示特殊召唤
function c73752131.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌·卡组·墓地选择1只不受王谷影响的「黑魔术师」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73752131.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
