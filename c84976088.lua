--バックグランド・ドラゴン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在墓地存在，自己场上没有卡存在的场合才能发动。墓地的这张卡和手卡1只4星以下的龙族怪兽守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c84976088.initial_effect(c)
	-- ①：这张卡在墓地存在，自己场上没有卡存在的场合才能发动。墓地的这张卡和手卡1只4星以下的龙族怪兽守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84976088,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,84976088)
	e1:SetCondition(c84976088.spcon)
	e1:SetTarget(c84976088.sptg)
	e1:SetOperation(c84976088.spop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：自己场上没有卡存在
function c84976088.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（怪兽区和魔法陷阱区）的卡片数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
-- 过滤条件：手卡中等级4以下且可以特殊召唤的龙族怪兽
function c84976088.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动准备：检查是否满足特殊召唤2只怪兽的条件（包括场上空位、手卡中是否有符合条件的怪兽、以及是否受精灵龙等卡片限制影响）
function c84976088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡中是否存在至少1只满足过滤条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c84976088.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置特殊召唤的操作信息（预计特殊召唤2只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 效果处理：将墓地的这张卡和手卡1只4星以下龙族怪兽守备表示特殊召唤，并对这张卡适用离场除外的效果
function c84976088.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己场上的主要怪兽区域空位不足2个，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足过滤条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c84976088.filter,tp,LOCATION_HAND,0,1,1,c,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选中的怪兽和墓地的这张卡以表侧守备表示特殊召唤，并判断是否特殊召唤成功
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e2:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e2,true)
		end
	end
end
