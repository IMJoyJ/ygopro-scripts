--一斉蜂起
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ①：以最多有对方场上的怪兽数量的自己墓地的4星以下的「蜂军」怪兽为对象才能发动。那些怪兽特殊召唤。
function c52838896.initial_effect(c)
	-- ①：以最多有对方场上的怪兽数量的自己墓地的4星以下的「蜂军」怪兽为对象才能发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52838896+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c52838896.spcost)
	e1:SetTarget(c52838896.sptg)
	e1:SetOperation(c52838896.spop)
	c:RegisterEffect(e1)
	-- 设置活动计数器，检测玩家在当回合是否已经发动过这张卡（对应“这个卡名的卡在1回合只能发动1张”）
	Duel.AddCustomActivityCounter(52838896,ACTIVITY_SPSUMMON,c52838896.counterfilter)
end
-- 过滤函数：返回true表示该特殊召唤不触发计数器（即昆虫族怪兽或从主卡组特殊召唤时不受限制）
function c52838896.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_INSECT)
end
-- 代价函数：检查玩家是否已发动过此卡，并注册一个永续效果，限制该回合不能特殊召唤非昆虫族怪兽
function c52838896.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测玩家是否已经发动过这张卡（通过计数器），若为0则可以发动
	if chk==0 then return Duel.GetCustomActivityCount(52838896,tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册一个永续效果，限制玩家在该回合不能特殊召唤非昆虫族怪兽（对应“这张卡发动的回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤”）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c52838896.splimit)
	-- 将限制效果注册到玩家tp，使其生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制函数：返回true表示禁止该特殊召唤（仅当怪兽在额外卡组且不是昆虫族时禁止）
function c52838896.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT)
end
-- 筛选函数：返回true表示该怪兽是4星以下且属于「蜂军」系列且可以被特殊召唤
function c52838896.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x12f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：选择自己墓地的「蜂军」怪兽作为对象，数量最多为对方场上的怪兽数量
function c52838896.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52838896.filter(chkc,e,tp) end
	-- 获取玩家tp的主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方玩家主要怪兽区的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 检测是否有足够的空位、对方场上有怪兽、以及存在满足条件的墓地的「蜂军」怪兽
	if chk==0 then return ft>0 and ct>0 and Duel.IsExistingTarget(c52838896.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	ct=math.min(ft,ct)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择最多ct张墓地的「蜂军」怪兽作为对象
	local g=Duel.SelectTarget(tp,c52838896.filter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置操作信息，声明要进行特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 操作函数：执行特殊召唤处理
function c52838896.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家tp的主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中玩家选择的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选中的怪兽特殊召唤到玩家场上
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
