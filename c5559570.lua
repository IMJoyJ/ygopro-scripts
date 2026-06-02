--誇り高き耀聖の詩－エルフェンノーツ
-- 效果：
-- 调整＋调整以外的魔法师族怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在中央的主要怪兽区域存在，双方不用中央的主要怪兽区域的怪兽不能攻击宣言。
-- ②：这张卡在中央的主要怪兽区域存在的场合，自己·对方的主要阶段才能发动。这张卡回到额外卡组，从自己的手卡·卡组·墓地各把最多1只「耀圣」怪兽特殊召唤。
local s,id,o=GetID()
-- 为这张卡设定同调召唤条件、苏生限制并注册效果①与效果②
function s.initial_effect(c)
	-- 设定同调召唤素材为：调整＋调整以外的魔法师族怪兽1只
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_SPELLCASTER),1,1)
	c:EnableReviveLimit()
	-- ①：只要这张卡在中央的主要怪兽区域存在，双方不用中央的主要怪兽区域的怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetCondition(s.ancondition)
	e1:SetTarget(s.antarget)
	c:RegisterEffect(e1)
	-- ②：这张卡在中央的主要怪兽区域存在的场合，自己·对方的主要阶段才能发动。这张卡回到额外卡组，从自己的手卡·卡组·墓地各把最多1只「耀圣」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的判定条件：检查这张卡是否在中央的主要怪兽区域（序列为2）
function s.ancondition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSequence()==2
end
-- 效果①的限制对象判定：除中央的主要怪兽区域以外的怪兽
function s.antarget(e,c)
	return c:GetSequence()~=2
end
-- 效果②的发动条件函数：必须在双方的主要阶段且自身在中央的主要怪兽区域
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段且自身在中央的主要怪兽区域
	return Duel.IsMainPhase() and e:GetHandler():GetSequence()==2
end
-- 过滤函数：检索卡组、手卡或墓地中可以被特殊召唤的「耀圣」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动判定：检查自身是否能回到额外卡组、是否有可用怪兽区域，以及手卡·卡组·墓地中是否存在至少1只可以特殊召唤的「耀圣」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return e:GetHandler():IsAbleToExtra()
		-- 计算这张卡离场后玩家场上可用的怪兽区域数量是否大于0
		and Duel.GetMZoneCount(tp,c)>0
		-- 且检查自己的手卡、卡组、墓地中是否存在至少1只可以特殊召唤的「耀圣」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：从手卡、卡组、墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	-- 设置操作信息：将这张卡送回额外卡组
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,c,1,0,0)
end
-- 特召怪兽的数量限制函数：保证从手卡、卡组、墓地选择特殊召唤的怪兽各最多为1只
function s.gcheck(g)
	if #g==1 then return true end
	return g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_HAND)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 效果②的效果处理：将这张卡送回额外卡组，并从手卡·卡组·墓地选择最多各1只（合计最多3只）「耀圣」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍在场上，则将其送回额外卡组
	if c:IsRelateToChain() and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_EXTRA)
		-- 检查己方场上可用的怪兽区域数量是否大于0
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且检查己方的手卡、卡组、墓地中是否存在不受王家长眠之谷影响且可以被特殊召唤的「耀圣」怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) then
		-- 获取己方手卡、卡组、墓地中所有满足特殊召唤条件且不受王家长眠之谷影响的「耀圣」怪兽
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
		-- 获取当前己方场上可用的怪兽区域空格数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft>0 and #g>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
			-- 发送系统提示：请选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,ft)
			if sg then
				-- 将选择的「耀圣」怪兽以表侧表示特殊召唤到玩家场上
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
