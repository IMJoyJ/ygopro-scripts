--TG トライデント・ランチャー
-- 效果：
-- 包含「科技属」调整的效果怪兽2只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己的手卡·卡组·墓地各把1只「科技属」怪兽在作为这张卡所连接区的自己场上守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
-- ②：对方不能把这张卡所连接区的「科技属」同调怪兽作为效果的对象。
function c50750868.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：用2~99只效果怪兽作为连接素材，且素材组中必须包含至少1只「科技属」调整怪兽。
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
	-- 设置该效果的Value为aux.tgoval：当效果发动者是对方玩家时返回false，用于实现“对方不能把这张卡所连接区的「科技属」同调怪兽作为效果的对象”。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 连接素材的追加条件：检查素材组g中是否存在至少1只满足c50750868.mzfilter的怪兽（即「科技属」调整怪兽），以此确保连接召唤时素材中包含「科技属」调整。
function c50750868.lcheck(g,lc)
	return g:IsExists(c50750868.mzfilter,1,nil)
end
-- 素材过滤函数：判断怪兽是否为「科技属」系列怪兽且是调整怪兽（IsLinkSetCard(0x27)检查科技属字段，IsLinkType(TYPE_TUNER)检查调整）。
function c50750868.mzfilter(c)
	return c:IsLinkSetCard(0x27) and c:IsLinkType(TYPE_TUNER)
end
-- ②效果的适用对象判断：若该卡c位于这张卡的连接区域内，且是「科技属」同调怪兽，则成为不能被对方效果选为对象的目标。
function c50750868.tgtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c) and c:IsSetCard(0x27) and c:IsType(TYPE_SYNCHRO)
end
-- ①效果的发动条件：此卡是以连接召唤方式特殊召唤成功时才能发动。
function c50750868.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤候选的过滤函数：该卡必须是「科技属」怪兽，且可以被玩家tp以表侧守备表示特殊召唤到指定zone（这张卡的连接区）。
function c50750868.spfilter(c,e,tp,zone)
	return c:IsSetCard(0x27) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,tp,zone)
end
-- 特殊召唤卡组的合法性检查：一组选出的卡（sg）必须来自不同区域（手卡/卡组/墓地），即区域种类数等于卡数，保证各选1张。
function c50750868.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg
end
-- ①效果的发动时点处理：检查连接区空位是否至少3个、没有青眼精灵龙的同召限制，以及手卡·墓地·卡组各存在至少1只可特殊召唤的「科技属」怪兽；满足则效果可发动，并设置特殊召唤操作信息。
function c50750868.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)&0x1f
		-- 计算这张卡的连接区中可用的主要怪兽区空格数（zone为连接端指向的格子，限制为前5格），供发动条件判断是否可容纳3只怪兽。
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return ct>2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 确认手牌中存在至少1只满足spfilter的「科技属」怪兽，可作为①效果从手卡特殊召唤的对象。
			and Duel.IsExistingMatchingCard(c50750868.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone)
			-- 确认墓地中存在至少1只满足spfilter的「科技属」怪兽，可作为①效果从墓地特殊召唤的对象。
			and Duel.IsExistingMatchingCard(c50750868.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone)
			-- 确认卡组中存在至少1只满足spfilter的「科技属」怪兽，可作为①效果从卡组特殊召唤的对象。
			and Duel.IsExistingMatchingCard(c50750868.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,zone)
	end
	-- 设置当前连锁的特殊召唤操作信息：预计从手卡·卡组·墓地合计特殊召唤3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：先检查此卡仍与效果关联且青眼精灵龙限制不适用；若连接区空格≥3，则从手卡、卡组、墓地各选1只「科技属」怪兽（墓地使用王家长眠之谷过滤），以表侧守备表示特殊召唤到连接区；之后给己方附加直到结束阶段不能特殊召唤非「科技属」怪兽的自肃效果。
function c50750868.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if c:IsRelateToEffect(e) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
		local zone=c:GetLinkedZone(tp)&0x1f
		-- 效果处理时重新计算连接区可用空格数，确认仍足够特殊召唤3只怪兽。
		local ct=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
		if ct>=3 then
			-- 获取手牌中所有可被①效果特殊召唤的「科技属」怪兽集合，供玩家选择1只。
			local g1=Duel.GetMatchingGroup(c50750868.spfilter,tp,LOCATION_HAND,0,nil,e,tp,zone)
			-- 获取卡组中所有可被①效果特殊召唤的「科技属」怪兽集合，供玩家选择1只。
			local g2=Duel.GetMatchingGroup(c50750868.spfilter,tp,LOCATION_DECK,0,nil,e,tp,zone)
			-- 获取墓地中所有可被①效果特殊召唤的「科技属」怪兽集合（并通过王家长眠之谷的过滤），供玩家选择1只。
			local g3=Duel.GetMatchingGroup(aux.NecroValleyFilter(c50750868.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
			if #g1>0 and #g2>0 and #g3>0 then
				-- 向玩家弹出选择提示，要求从手卡中选择1只要特殊召唤的「科技属」怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg1=g1:Select(tp,1,1,nil)
				-- 向玩家弹出选择提示，要求从卡组中选择1只要特殊召唤的「科技属」怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg2=g2:Select(tp,1,1,nil)
				sg1:Merge(sg2)
				-- 向玩家弹出选择提示，要求从墓地中选择1只要特殊召唤的「科技属」怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local sg3=g3:Select(tp,1,1,nil)
				sg1:Merge(sg3)
				-- 将选出的3只「科技属」怪兽以表侧守备表示特殊召唤到这张卡的连接区（由tp控制）。
				Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP_DEFENSE,zone)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「科技属」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c50750868.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上的领域效果，影响己方玩家，持续到回合结束时。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的过滤函数：只要怪兽不是「科技属」字段，就不能进行特殊召唤。
function c50750868.splimit(e,c)
	return not c:IsSetCard(0x27)
end
