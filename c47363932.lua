--スクラップ・ワイバーン
-- 效果：
-- 包含「废铁」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「废铁」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，选自己场上1张卡破坏。
-- ②：这张卡已在怪兽区域存在的状态，场上的表侧表示的「废铁」怪兽被效果破坏的场合才能发动。从卡组把1只「废铁」怪兽特殊召唤。那之后，选场上1张卡破坏。
function c47363932.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只怪兽作为连接素材，且素材组中必须至少有1只「废铁」怪兽（由lcheck过滤）。
	aux.AddLinkProcedure(c,nil,2,2,c47363932.lcheck)
	c:EnableReviveLimit()
	-- ①：以自己墓地1只「废铁」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，选自己场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47363932,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,47363932)
	e1:SetTarget(c47363932.sptg1)
	e1:SetOperation(c47363932.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡已在怪兽区域存在的状态，场上的表侧表示的「废铁」怪兽被效果破坏的场合才能发动。从卡组把1只「废铁」怪兽特殊召唤。那之后，选场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47363932,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,47363933)
	e2:SetCondition(c47363932.spcon2)
	e2:SetTarget(c47363932.sptg2)
	e2:SetOperation(c47363932.spop2)
	c:RegisterEffect(e2)
end
-- 连接素材检查函数：返回连接素材组g中是否存在至少1只是「废铁」怪兽的卡，用于实现“包含「废铁」怪兽的怪兽2只”的素材要求。
function c47363932.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x24)
end
-- 特殊召唤筛选函数：判断卡c是否为「废铁」怪兽，并且能否被当前效果e特殊召唤（符合召唤规则和苏生限制）。
function c47363932.spfilter(c,e,tp)
	return c:IsSetCard(0x24) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件与取对象检测：若指定对象，则对象必须是自己墓地的「废铁」怪兽且可特殊召唤；在发动判定时要求主要怪兽区有空位且墓地存在符合条件的对象。
function c47363932.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c47363932.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区域是否有空位，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只符合spfilter的「废铁」怪兽可以作为效果①的对象。
		and Duel.IsExistingTarget(c47363932.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片，将“请选择要特殊召唤的卡”写入选择提示缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足spfilter的「废铁」怪兽，并将其设为本效果的对象。
	local g1=Duel.SelectTarget(tp,c47363932.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取自己场上的全部卡片（LOCATION_ONFIELD），作为后续需要破坏的候选范围。
	local g2=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	-- 设置本次效果处理信息：包含特殊召唤操作，目标为已选择的墓地怪兽g1，数量为1，用于连锁检测和效果发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
	-- 设置本次效果处理信息：包含破坏操作，候选破坏对象为自己场上的全部卡g2，数量为1，用于连锁检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 效果①的实际处理：先特殊召唤取对象的墓地「废铁」怪兽；特殊召唤成功后，再选择自己场上1张卡破坏。
function c47363932.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁中效果①所选择的墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 检查该对象是否仍与本效果相关（未离场或未被无效），并尝试将其特殊召唤；只有特殊召唤成功（返回值≠0）才继续执行后续破坏。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要破坏的卡，将“请选择要破坏的卡”写入提示缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从自己场上选择1张卡（任意卡）作为本次要破坏的卡。
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使特殊召唤与后续破坏不在同一时点处理，正确体现“那之后”的先后关系。
			Duel.BreakEffect()
			-- 手动显示所选择要被破坏的卡的对象动画，并登记这些卡为（广义）效果对象。
			Duel.HintSelection(g)
			-- 使用效果原因（REASON_EFFECT）破坏所选择的卡。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 被破坏怪兽的筛选函数：该卡须因效果被破坏、破坏前位于怪兽区域、破坏前是表侧表示且名字含有「废铁」字段。
function c47363932.cfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(0x24) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果②的触发条件：本连锁中是否有至少1张卡满足cfilter，即场上的表侧表示「废铁」怪兽被效果破坏。
function c47363932.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47363932.cfilter,1,nil)
end
-- 效果②的发动条件和处理前设定：发动时要求主要怪兽区域有空位，且卡组中存在至少1只可特殊召唤的「废铁」怪兽。
function c47363932.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位，以确保可以从卡组特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足spfilter的「废铁」怪兽可以被特殊召唤。
		and Duel.IsExistingMatchingCard(c47363932.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取场上全部卡片（包含双方场上），作为后续破坏操作的候选范围。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 设置操作信息：包含从卡组的特殊召唤，数量1，目标持有者为自己，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：包含破坏操作，候选破坏对象为场上所有卡g，数量为1，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的实际处理：先确认有空位，然后从卡组选1只「废铁」怪兽特殊召唤；若成功，再选场上1张卡破坏。
function c47363932.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己主要怪兽区域是否有空位；若无空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足spfilter的「废铁」怪兽作为特殊召唤对象。
	local g1=Duel.SelectMatchingCard(tp,c47363932.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若确实选到了卡并且特殊召唤成功，才继续执行后续的破坏操作。
	if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家从双方场上选择1张卡作为本次要破坏的卡。
		local g2=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if g2:GetCount()>0 then
			-- 中断当前效果处理，使特殊召唤与破坏作为不同时点处理，符合“那之后”的时点关系。
			Duel.BreakEffect()
			-- 手动显示所选择要被破坏的卡的对象动画，并登记为效果对象。
			Duel.HintSelection(g2)
			-- 使用效果原因（REASON_EFFECT）破坏所选择的卡。
			Duel.Destroy(g2,REASON_EFFECT)
		end
	end
end
