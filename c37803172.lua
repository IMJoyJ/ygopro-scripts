--陽炎獣 ペリュトン
-- 效果：
-- 这张卡不能用名字带有「阳炎兽」的怪兽的效果以外特殊召唤。只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。此外，把手卡1只炎属性怪兽送去墓地，把这张卡解放才能发动。从卡组把2只名字带有「阳炎兽」的怪兽特殊召唤。「阳炎兽 佩利冬」的这个效果1回合只能使用1次。
function c37803172.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方不能把这张卡作为卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.tgoval，使这张卡不能成为对方发动的效果的对象。
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 这张卡不能用名字带有「阳炎兽」的怪兽的效果以外特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(c37803172.splimit)
	c:RegisterEffect(e2)
	-- 此外，把手卡1只炎属性怪兽送去墓地，把这张卡解放才能发动。从卡组把2只名字带有「阳炎兽」的怪兽特殊召唤。「阳炎兽 佩利冬」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37803172,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,37803172)
	e3:SetCost(c37803172.spcost)
	e3:SetTarget(c37803172.sptg)
	e3:SetOperation(c37803172.spop)
	c:RegisterEffect(e3)
end
-- 特殊召唤限制判定：只有当进行这次特殊召唤的效果来源卡是名字带有「阳炎兽」的怪兽时，才允许特殊召唤此卡；否则不能特殊召唤。
function c37803172.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x107d)
end
-- 代价筛选函数：选择手卡中1只炎属性怪兽，且它能够作为效果代价送入墓地。
function c37803172.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToGraveAsCost()
end
-- 代价检查阶段：确认自己场上这张卡可以被解放，且手卡存在可作为代价的炎属性怪兽，以满足发动条件。
function c37803172.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable()
		-- 检查手卡中是否存在至少1只炎属性且可作为代价送去墓地的怪兽。
		and Duel.IsExistingMatchingCard(c37803172.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 作为发动代价，从手卡丢弃1只满足筛选条件的炎属性怪兽。
	Duel.DiscardHand(tp,c37803172.cfilter,1,1,REASON_COST)
	-- 作为发动代价，解放（释放）这张卡自身。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象筛选：卡组中的「阳炎兽」怪兽，并且能够被本次效果成功特殊召唤。
function c37803172.filter(c,e,tp)
	return c:IsSetCard(0x107d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标阶段判断：确认当前没有“青眼精灵龙”效果禁止同时特殊召唤2只以上怪兽、我方怪兽区有空位、卡组存在至少2只符合条件的「阳炎兽」怪兽。
function c37803172.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认我方怪兽区至少有1个可用空格，作为能够发动特殊召唤效果的基本条件。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认卡组中存在至少2只满足特殊召唤条件的「阳炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c37803172.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 写入连锁操作信息：该效果将进行2只怪兽的特殊召唤，且对象来自卡组（不取对象，不指定具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：若“青眼精灵龙”效果适用或怪兽区空位不足则终止；否则从卡组中选出2只符合条件的「阳炎兽」怪兽，以表侧表示特殊召唤到我方场上。
function c37803172.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若我方怪兽区可用空格不足2个，则无法特殊召唤2只怪兽，直接终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足特殊召唤条件的「阳炎兽」怪兽，构成候选集合供后续选择。
	local g=Duel.GetMatchingGroup(c37803172.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 显示“请选择要特殊召唤的卡”的提示，请玩家从候选集合中选择2只怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2只「阳炎兽」怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
