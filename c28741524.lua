--念動収集機
-- 效果：
-- 自己墓地存在的2星以下的念动力族怪兽任意数量特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽等级合计×300的数值的伤害。
function c28741524.initial_effect(c)
	-- 自己墓地存在的2星以下的念动力族怪兽任意数量特殊召唤。那之后，自己受到这个效果特殊召唤的怪兽等级合计×300的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c28741524.sptg)
	e1:SetOperation(c28741524.spop)
	c:RegisterEffect(e1)
end
-- 筛选自己墓地中等级2以下、念动力族、且能被玩家tp以该效果特殊召唤的怪兽。
function c28741524.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsRace(RACE_PSYCHO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时，筛选出仍与此效果相关联且仍为念动力族的对象卡。
function c28741524.opfilter(c,e)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_PSYCHO)
end
-- 发动前检查与选择对象：若已指定对象chkc，则校验其位于我方墓地且满足可特招条件；若为发动合法性检查，则确认我方主要怪兽区有空位且墓地存在至少1只满足条件的对象。
function c28741524.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28741524.filter(chkc,e,tp) end
	-- 发动合法性检查：我方主要怪兽区必须存在至少1个可用空格，否则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认墓地存在至少1只满足筛选条件且可被选择为对象的念动力族2星以下怪兽。
		and Duel.IsExistingTarget(c28741524.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 取得我方主要怪兽区当前可用空格数，作为本效果可选择/特殊召唤的怪兽数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出选择提示，提示我方玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方墓地选择1到ft只满足筛选条件的念动力族怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c28741524.filter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 设置操作信息：登记本次连锁将把g中的这些怪兽特殊召唤，数量为g:GetCount()。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
	local lv=g:GetSum(Card.GetLevel)
	-- 设置操作信息：登记本次连锁后续将对我方玩家造成lv×300点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,lv*300)
end
-- 效果处理阶段：取出仍有效且为念动力族的对象，确认主要怪兽区空格足够容纳全部对象，且不受【青眼精灵龙】限制（不能同时特殊召唤2只以上）；满足条件则全部特殊召唤，再按实际特召成功的怪兽等级合计造成伤害。
function c28741524.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁记录的对象中，筛选出仍与该效果相关且仍为念动力族的卡，作为实际可特殊召唤的怪兽集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c28741524.opfilter,nil,e)
	-- 再次取得我方主要怪兽区当前可用空格数，用于效果处理时判断能否全部特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft<g:GetCount() or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if g:GetCount()>0 then
		-- 按常规检查召唤条件与苏生限制后，将g中的对象卡以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 获取刚才特殊召唤操作实际成功的怪兽集合。
		local og=Duel.GetOperatedGroup()
		local lv=og:GetSum(Card.GetLevel)
		-- 中断当前效果处理，使特殊召唤和后续伤害分为不同时点处理。
		Duel.BreakEffect()
		-- 给予我方玩家实际特殊召唤的怪兽等级合计×300的效果伤害。
		Duel.Damage(tp,lv*300,REASON_EFFECT)
	end
end
