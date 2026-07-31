--ドラゴニック・ガード
-- 效果：
-- 每次怪兽通常召唤，给这张卡放置1个龙神指示物。此外，可以把场上表侧表示存在的这张卡送去墓地，把持有这张卡放置的龙神指示物数量以下的等级的1只龙族怪兽从自己卡组特殊召唤。
function c78009994.initial_effect(c)
	c:EnableCounterPermit(0x22)
	-- ①：每次怪兽通常召唤，给这张卡放置1个龙神指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c78009994.ctop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
	-- ②：把场上表侧表示存在的这张卡送去墓地才能发动。把持有这张卡放置的龙神指示物数量以下的等级的1只龙族怪兽从自己卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(78009994,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c78009994.spcost)
	e2:SetTarget(c78009994.sptg)
	e2:SetOperation(c78009994.spop)
	c:RegisterEffect(e2)
end
c78009994.mentioned_counter={
	[0x22]=true,
}
-- 放置指示物处理：非自身通常召唤时，给此卡放置1个龙神指示物
function c78009994.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetFirst()~=e:GetHandler() then
		e:GetHandler():AddCounter(0x22,1)
	end
end
-- Cost处理：记录当前指示物数量，并将自身送去墓地
function c78009994.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x22))
	-- 把此卡作为Cost送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 卡组特召过滤条件：等级在指定数值以下的龙族怪兽且可特殊召唤
function c78009994.spfilter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动准备：检查怪兽区域空位与卡组满足条件的龙族怪兽，并设置特召操作信息
function c78009994.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：怪兽区域是否有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 发动条件检查：卡组是否存在等级在指示物数量以下的龙族怪兽
		and Duel.IsExistingMatchingCard(c78009994.spfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler():GetCounter(0x22),e,tp) end
	-- 设置连锁操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只满足条件的龙族怪兽表侧表示特殊召唤
function c78009994.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域无空位则终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只等级在Cost记录的指示物数量以下的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c78009994.spfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel(),e,tp)
	if g:GetCount()~=0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
