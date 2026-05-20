--エクシーズ・ディメンション・スプラッシュ
-- 效果：
-- 盖放的这张卡从游戏中除外的场合，可以从卡组把2只水属性·8星怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，效果无效化，也不能解放。
function c71541986.initial_effect(c)
	-- 盖放的这张卡从游戏中除外的场合，可以从卡组把2只水属性·8星怪兽特殊召唤。这个效果特殊召唤的怪兽不能攻击宣言，效果无效化，也不能解放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71541986,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetCondition(c71541986.spcon)
	e1:SetTarget(c71541986.sptg)
	e1:SetOperation(c71541986.spop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否在场上以里侧表示（盖放）的状态被除外。
function c71541986.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤卡组中满足水属性、8星且可以特殊召唤的怪兽。
function c71541986.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果的预检：检测青眼精灵龙效果、自身怪兽区域空位数是否大于1，以及卡组中是否存在至少2只满足条件的怪兽。
function c71541986.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的主要怪兽区域是否有2个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2只满足过滤条件的水属性·8星怪兽。
		and Duel.IsExistingMatchingCard(c71541986.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示此效果会从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择2只水属性·8星怪兽特殊召唤，并对它们施加不能攻击、效果无效、不能解放的限制。
function c71541986.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 若自己场上的主要怪兽区域空位数不足2个，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足过滤条件的水属性·8星怪兽。
	local g=Duel.GetMatchingGroup(c71541986.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<2 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,2,2,nil)
	local tc=sg:GetFirst()
	while tc do
		-- 将选中的怪兽以表侧表示特殊召唤到场上（分步处理）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽不能攻击宣言
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效化
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
		-- 也不能解放
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EFFECT_UNRELEASABLE_SUM)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e5)
		tc=sg:GetNext()
	end
	-- 完成特殊召唤的流程，刷新场上状态。
	Duel.SpecialSummonComplete()
end
