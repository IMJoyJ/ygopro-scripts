--渋い忍者
-- 效果：
-- 这张卡反转时，可以从自己的手卡·墓地把「素银忍者」以外的名字带有「忍者」的怪兽任意数量里侧守备表示特殊召唤。「素银忍者」在场上只能有1只表侧表示存在。
function c87483942.initial_effect(c)
	c:SetUniqueOnField(1,1,87483942)
	-- 这张卡反转时，可以从自己的手卡·墓地把「素银忍者」以外的名字带有「忍者」的怪兽任意数量里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87483942,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetCode(EVENT_FLIP)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetTarget(c87483942.sptg)
	e1:SetOperation(c87483942.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·墓地中「素银忍者」以外的名字带有「忍者」且可以里侧守备表示特殊召唤的怪兽
function c87483942.filter(c,e,tp)
	return c:IsSetCard(0x2b) and not c:IsCode(87483942) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动条件与目标检查：自己场上有可用的怪兽区域，且手卡·墓地存在至少1只满足条件的怪兽
function c87483942.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c87483942.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从手卡·墓地特殊召唤怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：在怪兽区域有空位的情况下，选择手卡·墓地中满足条件的怪兽里侧守备表示特殊召唤，并给对方确认
function c87483942.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·墓地选择1到ft张（受王家长眠之谷影响的）满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c87483942.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧表示怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
