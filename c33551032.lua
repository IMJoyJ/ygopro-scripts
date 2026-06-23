--アンブラル・アンフォーム
-- 效果：
-- 这张卡的攻击让这张卡被战斗破坏送去墓地时，可以从卡组把2只名字带有「阴影」的怪兽特殊召唤。「阴影无形鬼」的效果1回合只能使用1次。
function c33551032.initial_effect(c)
	-- 创建一个诱发效果，用于在战斗破坏时特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33551032,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,33551032)
	e1:SetCondition(c33551032.spcon)
	e1:SetTarget(c33551032.sptg)
	e1:SetOperation(c33551032.spop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：攻击怪兽是自己且被战斗破坏送入墓地
function c33551032.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 攻击怪兽是自己且在墓地且被战斗破坏
	return Duel.GetAttacker()==c and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
end
-- 过滤函数，用于筛选名字带有「阴影」且可特殊召唤的怪兽
function c33551032.spfilter(c,e,tp)
	return c:IsSetCard(0x87) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置发动时的条件检查：未被青眼精灵龙效果影响、场上至少有2个空位、卡组有2只符合条件的怪兽
function c33551032.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 场上至少有2个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 卡组存在至少2只名字带有「阴影」的怪兽
		and Duel.IsExistingMatchingCard(c33551032.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁操作信息，表示将特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：检测青眼精灵龙效果、判断空位、选择并特殊召唤2只怪兽
function c33551032.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 判断场上空位是否不足
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 获取卡组中所有名字带有「阴影」且可特殊召唤的怪兽
	local g=Duel.GetMatchingGroup(c33551032.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()<2 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,2,2,nil)
	-- 将选择的怪兽特殊召唤到场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
