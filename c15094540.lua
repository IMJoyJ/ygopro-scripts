--百鬼羅刹大危機
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只「哥布林」怪兽和对方场上1只怪兽或者自己墓地1只「哥布林」怪兽和对方墓地1只怪兽为对象才能发动。那2只怪兽除外。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己的除外状态的5只「哥布林」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
local s,id,o=GetID()
-- 注册e1作为这张卡的发动（ACTIVATE）空效果，使这张魔法陷阱卡可以发动；注册e2为①效果的除外效果，e3为②效果的特殊召唤效果；e2与e3均使用SetCountLimit(1,id)，共同实现这个卡名的①②效果1回合只能使用其中任意1个。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1只「哥布林」怪兽和对方场上1只怪兽或者自己墓地1只「哥布林」怪兽和对方墓地1只怪兽为对象才能发动。那2只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把魔法与陷阱区域的表侧表示的这张卡送去墓地，以自己的除外状态的5只「哥布林」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数rmfilter1：判断自己场上或墓地的表侧表示「哥布林」怪兽可以作为①的第一个对象，且要求在该怪兽所在的相同区域（场上或墓地）存在对方怪兽可作为第二个对象。
function s.rmfilter1(c,tp)
	local loc=c:GetLocation()
	return c:IsFaceupEx() and c:IsSetCard(0xac) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
		-- 该行进一步检查对方在相同区域（loc）存在至少1只满足rmfilter2的怪兽，从而保证能凑齐2只对象。
		and Duel.IsExistingTarget(s.rmfilter2,tp,0,loc,1,nil)
end
-- 过滤函数rmfilter2：判断对方怪兽可以成为①的第二个对象，要求是怪兽且可以除外。
function s.rmfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①效果的发动时选择对象：先选择自己场上或墓地的1只「哥布林」怪兽，再根据其位置选择对方场上或墓地的1只怪兽，两者共同作为除外对象。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动合法性检查：确认自己场上或墓地存在至少1只符合条件的「哥布林」怪兽可作为第一个对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp) end
	-- 显示'请选择要除外的卡'的UI提示，用于让玩家选择第一个对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己场上或墓地的1只「哥布林」怪兽作为第一个对象，并将其登记为当前连锁的对象。
	local g1=Duel.SelectTarget(tp,s.rmfilter1,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
	local loc=g1:GetFirst():GetLocation()
	-- 显示'请选择要除外的卡'的UI提示，用于让玩家选择第二个对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 根据第一个对象所在位置（loc），让玩家从对方的场上或墓地选择1只怪兽作为第二个对象，并登记为连锁对象。
	local g2=Duel.SelectTarget(tp,s.rmfilter2,tp,0,loc,1,1,nil)
	g1:Merge(g2)
	-- 将两组对象合并后的组登记为除外操作信息，使系统知道本连锁将除外这些卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),0,0)
end
-- 效果处理时使用的过滤函数：判断对象卡是怪兽且可以除外。
function s.rmopfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- ①效果处理：取得仍然相关的对象，过滤掉受王家长眠之谷影响无法除外的卡；若仍有2只，则将这2只怪兽表侧除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出发动时选择的对象，并筛选出与该效果仍有联系的卡（离场或失效的不处理）。
	local g=Duel.GetTargetsRelateToChain()
	-- 对对象组应用王家长眠之谷过滤器，排除因王家长眠之谷效果而不能除外的卡。
	local tg=g:Filter(aux.NecroValleyFilter(s.rmopfilter),nil)
	if tg:GetCount()==2 then
		-- 将最终确定的2只怪兽以表侧表示除外，原因为效果。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡必须在魔法陷阱区域存在且效果有效（没有被无效或里侧等）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- ②效果的发动代价：把魔法陷阱区域表侧表示的这张卡送去墓地作为COST；检查阶段确认该卡可以送去墓地。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 执行代价：把这张卡从魔陷区送去墓地，原因为COST。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数spfilter：选择除外状态的「哥布林」怪兽，要求表侧表示、可以特殊召唤且可以成为效果对象。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xac) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanBeEffectTarget(e)
end
-- ②效果的target函数：检查自己除外区是否有至少5只符合条件的「哥布林」怪兽，且这些怪兽卡名互不相同（同名卡最多1张），同时自己怪兽区域至少要有5个空格；并且需要确认青眼精灵龙（59822133）的效果没有在适用（否则不能同时特殊召唤2只以上）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 获取自己除外区中满足spfilter的所有「哥布林」怪兽作为候选集合。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	-- 取得自己主要怪兽区域当前可用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 合法性检查：自己怪兽区域空格数>=5，除外区存在至少5只符合条件的「哥布林」怪兽，且候选集合中不同卡名数>=5；同时验证青眼精灵龙限制不适用，否则不能发动。
	if chk==0 then return ft>=5 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,5,nil,e,tp) and g:GetClassCount(Card.GetCode)>=5
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 显示'请选择要特殊召唤的卡'的UI提示，用于选择特殊召唤的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从候选组中选出5张卡名互不相同的「哥布林」怪兽作为特殊召唤对象。
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,5,5)
	-- 将选择的5张卡登记为当前连锁的对象，供后续处理时引用。
	Duel.SetTargetCard(tg)
	-- 登记特殊召唤操作信息，标明本效果要特殊召唤的对象组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,tg:GetCount(),0,0)
end
-- ②效果处理：取回仍然相关的对象；若对象数>1且青眼精灵龙效果适用中则整个效果不处理；否则若区域足够则全部特殊召唤，区域不足则让玩家选择可召唤数量的卡特殊召唤，其余卡因规则送去墓地。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡组，并过滤出与该效果仍有联系的对象（防止对象被无效或离场）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 获取当前可用主要怪兽区域空格数，用于决定特殊召唤卡的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if g:GetCount()<=ft then
		-- 将全部与效果相关的对象以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 显示'请选择要特殊召唤的卡'的UI提示，用于在区域不足时选择哪些卡被特殊召唤。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,ft,ft,nil)
		-- 将玩家选定的卡以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		g:Sub(sg)
		-- 无法特殊召唤的剩余卡以规则理由送去墓地。
		Duel.SendtoGrave(g,REASON_RULE)
	end
end
