--TG トライデント・ランチャー
-- 效果：
-- 包含「科技属」调整的效果怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的手卡·卡组·墓地各把1只「科技属」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
-- ②：对方不能把这张卡所连接区的「科技属」同调怪兽作为效果的对象。
function c50750868.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用至少2张且至多99张满足过滤条件的怪兽作为连接素材，其中至少1张为效果怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c50750868.lcheck)
	-- ①：这张卡连接召唤的场合才能发动。从自己的手卡·卡组·墓地各把1只「科技属」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50750868,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,50750868)
	e1:SetCondition(c50750868.spcon)
	e1:SetTarget(c50750868.sptg)
	e1:SetOperation(c50750868.spop)
	c:RegisterEffect(e1)
	-- ②：对方不能把这张卡所连接区的「科技属」同调怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c50750868.tgtg)
	-- 设置效果值为aux.tgoval函数，用于过滤不会成为对方效果对象的卡
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 连接召唤条件检查函数，判断连接素材中是否存在满足条件的调整怪兽
function c50750868.lcheck(g,lc)
	return g:IsExists(c50750868.mzfilter,1,nil)
end
-- 调整怪兽过滤函数，筛选出同时具有科技属属性和调整类型的怪兽
function c50750868.mzfilter(c)
	return c:IsLinkSetCard(0x27) and c:IsLinkType(TYPE_TUNER)
end
-- 目标过滤函数，筛选出位于连接区且为科技属同调怪兽的卡
function c50750868.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x27) and c:IsType(TYPE_SYNCHRO)
end
-- 特殊召唤条件判断函数，判断是否为连接召唤
function c50750868.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤过滤函数，筛选出可被守备表示特殊召唤的科技属怪兽
function c50750868.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x27) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 特殊召唤数量检查函数，确保所选卡片来自不同位置（手牌、卡组、墓地）
function c50750868.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
-- 特殊召唤目标设定函数，检测是否满足特殊召唤条件并设置操作信息
function c50750868.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
		-- 获取玩家在指定区域的可用怪兽区数量
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ct>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检测手牌中是否存在满足条件的科技属怪兽
			and Duel.IsExistingMatchingCard(c50750868.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone)
			-- 检测墓地中是否存在满足条件的科技属怪兽
			and Duel.IsExistingMatchingCard(c50750868.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone)
			-- 检测卡组中是否存在满足条件的科技属怪兽
			and Duel.IsExistingMatchingCard(c50750868.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,zone)
	end
	-- 设置连锁操作信息，指定将要特殊召唤3张卡片到手牌、卡组和墓地位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 特殊召唤效果处理函数，执行特殊召唤操作并注册后续限制效果
function c50750868.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if c:IsRelateToEffect(e) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		local zone=c:GetLinkedZone(tp)&0x1f
		-- 获取玩家在指定区域的可用怪兽区数量
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		if ct>=3 then
			-- 获取满足条件的科技属怪兽组（来自手牌）
			local g1=Duel.GetMatchingGroup(c50750868.spfilter,tp,LOCATION_HAND,0,nil,e,tp,zone)
			-- 获取满足条件的科技属怪兽组（来自卡组）
			local g2=Duel.GetMatchingGroup(c50750868.spfilter,tp,LOCATION_DECK,0,nil,e,tp,zone)
			-- 获取满足条件的科技属怪兽组（来自墓地，排除王家长眠之谷影响）
			local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50750868.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
			if #g1>0 and #g2>0 and #g3>0 then
				-- 提示玩家选择要特殊召唤的卡片（手牌部分）
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg1=g1:Select(tp,1,1,nil)
				-- 提示玩家选择要特殊召唤的卡片（卡组部分）
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg2=g2:Select(tp,1,1,nil)
				sg1:Merge(sg2)
				-- 提示玩家选择要特殊召唤的卡片（墓地部分）
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg3=g3:Select(tp,1,1,nil)
				sg1:Merge(sg3)
				-- 将选中的卡片以守备表示形式特殊召唤到场上
				Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
			end
		end
	end
	-- ①：这张卡连接召唤的场合才能发动。从自己的手卡·卡组·墓地各把1只「科技属」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50750868.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果目标函数，禁止非科技属怪兽被特殊召唤
function c50750868.splimit(e,c)
	return not c:IsSetCard(0x27)
end
