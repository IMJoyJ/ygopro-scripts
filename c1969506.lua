--傀儡儀式－パペット・リチューアル
-- 效果：
-- 自己基本分比对方少2000以上的场合才能发动。从自己墓地选择2只名字带有「机关傀儡」的8星怪兽特殊召唤。「傀儡仪式」在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
function c1969506.initial_effect(c)
	-- 效果原文内容：自己基本分比对方少2000以上的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,1969506+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c1969506.spcon)
	e1:SetCost(c1969506.spcost)
	e1:SetTarget(c1969506.sptg)
	e1:SetOperation(c1969506.spop)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否满足发动条件，即自己的LP比对方少2000以上。
function c1969506.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断是否满足发动条件，即自己的LP比对方少2000以上。
	return Duel.GetLP(tp)<=Duel.GetLP(1-tp)-2000
end
-- 效果原文内容：从自己墓地选择2只名字带有「机关傀儡」的8星怪兽特殊召唤。
function c1969506.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即当前阶段不是主要阶段2。
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 效果原文内容：「傀儡仪式」在1回合只能发动1张，这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将不能进入战斗阶段的效果注册给全局环境。
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：定义过滤函数，用于筛选名字带有「机关傀儡」且等级为8的怪兽。
function c1969506.filter(c,e,tp)
	return c:IsSetCard(0x1083) and c:IsLevel(8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果原文内容：从自己墓地选择2只名字带有「机关傀儡」的8星怪兽特殊召唤。
function c1969506.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1969506.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果作用：判断场上是否有足够的怪兽区域进行特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 效果作用：判断墓地中是否存在至少2只符合条件的怪兽。
		and Duel.IsExistingTarget(c1969506.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择2只符合条件的怪兽作为特殊召唤的目标。
	local g=Duel.SelectTarget(tp,c1969506.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果原文内容：这张卡发动的回合，自己不能进行战斗阶段。
function c1969506.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 效果作用：获取当前连锁中目标卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft>=sg:GetCount() then
		-- 效果作用：将符合条件的怪兽特殊召唤到场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
