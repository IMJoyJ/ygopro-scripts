--一斉蜂起
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ①：以最多有对方场上的怪兽数量的自己墓地的4星以下的「蜂军」怪兽为对象才能发动。那些怪兽特殊召唤。
function c52838896.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。①：以最多有对方场上的怪兽数量的自己墓地的4星以下的「蜂军」怪兽为对象才能发动。那些怪兽特殊召唤。
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
	-- 注册一个自定义活动计数器，用于记录本回合当前玩家从额外卡组特殊召唤非昆虫族怪兽的次数，作为发动代价的判定依据。
	Duel.AddCustomActivityCounter(52838896,ACTIVITY_SPSUMMON,c52838896.counterfilter)
end
-- 该过滤函数用于判定特殊召唤操作是否计入自定义计数器：只有从额外卡组特殊召唤且不是昆虫族的怪兽才会计数（返回false），其他情况不计入（返回true）。
function c52838896.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_INSECT)
end
-- 发动代价函数：检查本回合是否尚未进行过违规的特殊召唤（计数器为0），若合法则给当前玩家附加一个誓约效果，使其本回合内不能从额外卡组特殊召唤非昆虫族怪兽。
function c52838896.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：仅当本回合没有从额外卡组特殊召唤过非昆虫族怪兽（对应计数器为0）时才可支付代价发动。
	if chk==0 then return Duel.GetCustomActivityCount(52838896,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。①：以最多有对方场上的怪兽数量的自己墓地的4星以下的「蜂军」怪兽为对象才能发动。那些怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c52838896.splimit)
	-- 将刚创建的自肃效果（不能从额外卡组特殊召唤非昆虫族怪兽）注册给当前玩家tp，使该誓约从本回合开始适用直到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的判定函数：若尝试特殊召唤的怪兽来自额外卡组且不是昆虫族，则禁止那次特殊召唤。
function c52838896.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_INSECT)
end
-- 筛选可作为对象的墓地怪兽：4星以下、属于「蜂军」字段、且能够被特殊召唤。
function c52838896.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x12f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择函数：若已在连锁中指定对象则验证其合法性；否则计算可用怪兽区空格和对方场上怪兽数，取较小值作为可选数量上限；若受到青眼精灵龙效果影响则上限强制为1；在满足发动条件时从自己墓地选择1到该数量的「蜂军」怪兽为对象，并登记特殊召唤操作信息。
function c52838896.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52838896.filter(chkc,e,tp) end
	-- 获取当前玩家tp的主要怪兽区可用空格数量，用于限制可选择/特殊召唤的怪兽数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上主要怪兽区的怪兽数量，用于决定最多可选择的对象数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	-- 发动可行性检查：我方必须有可用怪兽区空格、对方场上有怪兽、且墓地存在至少1只符合条件的「蜂军」怪兽。
	if chk==0 then return ft>0 and ct>0 and Duel.IsExistingTarget(c52838896.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	ct=math.min(ft,ct)
	-- 发出“请选择要特殊召唤的卡”的提示消息，供玩家在选择目标时看到相应提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的符合条件的「蜂军」怪兽中选择1到ct张卡，并将这些卡登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c52838896.filter,tp,LOCATION_GRAVE,0,1,ct,nil,e,tp)
	-- 设置当前连锁的操作信息，声明本连锁涉及特殊召唤，目标组为g，数量为g的卡片数，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 效果处理函数：重新获取可用怪兽区空格，若无空格则终止；取得连锁对象并过滤仍与效果相关的卡；若目标多于1只且受到青眼精灵龙效果影响则终止；若目标数超过空格数则让玩家选择实际可特殊召唤的数量；最后将选中的卡特殊召唤。
function c52838896.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取当前玩家tp的主要怪兽区可用空格数，因为发动后场上情况可能已变化。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取当前连锁登记的效果对象卡组，即发动时选择的目标怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	if sg:GetCount()>ft then
		-- 当特殊召唤对象数量超过可用怪兽区空格时，提示玩家选择要实际特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:Select(tp,ft,ft,nil)
	end
	-- 将选中的「蜂军」怪兽以表侧表示特殊召唤到操作者tp的场上。
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
end
