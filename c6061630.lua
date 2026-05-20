--マジカル・コンダクター
-- 效果：
-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
-- ②：1回合1次，把这张卡的魔力指示物任意数量取除才能发动。从自己的手卡·墓地选持有和取除数量相同等级的1只魔法师族怪兽特殊召唤。
function c6061630.initial_effect(c)
	c:EnableCounterPermit(0x1)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 注册连锁发生时这张卡在场上存在的标记，用于后续检测魔法卡发动是否在场
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- ①：只要这张卡在怪兽区域存在，每次自己或者对方把魔法卡发动，给这张卡放置2个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c6061630.acop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡的魔力指示物任意数量取除才能发动。从自己的手卡·墓地选持有和取除数量相同等级的1只魔法师族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6061630,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c6061630.sptg)
	e2:SetOperation(c6061630.spop)
	c:RegisterEffect(e2)
end
-- 连锁处理结束时，若有魔法卡发动且当时此卡在场，则给此卡放置2个魔力指示物
function c6061630.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,2)
	end
end
-- 过滤手卡·墓地中可以特殊召唤、且等级大于0、且此卡能取除对应等级数量魔力指示物的魔法师族怪兽
function c6061630.filter(c,cc,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:GetLevel()>0 and cc:IsCanRemoveCounter(tp,0x1,c:GetLevel(),REASON_COST)
end
-- 效果发动的可行性检查：检查自身怪兽区域是否有空位，且手卡·墓地是否存在满足条件的魔法师族怪兽
function c6061630.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在满足过滤条件的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c6061630.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e:GetHandler(),e,tp) end
	-- 获取手卡·墓地中所有满足过滤条件的魔法师族怪兽
	local g=Duel.GetMatchingGroup(c6061630.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e:GetHandler(),e,tp)
	local lvt={}
	local tc=g:GetFirst()
	while tc do
		local tlv=tc:GetLevel()
		lvt[tlv]=tlv
		tc=g:GetNext()
	end
	local pc=1
	for i=1,12 do
		if lvt[i] then lvt[i]=nil lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 提示玩家选择要取除的魔力指示物数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(6061630,1))  --"请选择要取除的魔力指示物数量"
	-- 让玩家宣言一个数字（即要取除的魔力指示物数量/特殊召唤怪兽的等级）
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	e:GetHandler():RemoveCounter(tp,0x1,lv,REASON_COST)
	e:SetLabel(lv)
	-- 设置特殊召唤的操作信息（从手卡·墓地特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤手卡·墓地中等级等于指定数值、且可以特殊召唤的魔法师族怪兽
function c6061630.sfilter(c,lv,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevel(lv)
end
-- 效果处理：若场上有空位，则让玩家从手卡·墓地选择1只与取除指示物数量相同等级的魔法师族怪兽特殊召唤
function c6061630.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·墓地选择1只满足条件（且不受王家之谷影响）的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c6061630.sfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,lv,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
