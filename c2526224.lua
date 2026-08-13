--炎王神獣 キリン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，这张卡特殊召唤。
-- ②：这张卡被破坏送去墓地的场合才能发动。从自己的手卡·墓地把「炎王神兽 麒麟」以外的1只「炎王」怪兽特殊召唤。那之后，可以把场上1张卡破坏。
local s,id,o=GetID()
-- 初始化效果：为「炎王神兽 麒麟」注册两个效果。e1为手卡发动的二速诱发即时效果（①），e2为被破坏送墓时发动的选发诱发效果（②）；并分别设置各自的描述、分类、类型、发动条件、目标与操作函数，以及同名卡1回合1次的次数限制。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spscon)
	e1:SetTarget(s.spstg)
	e1:SetOperation(s.spsop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏送去墓地的场合才能发动。从自己的手卡·墓地把「炎王神兽 麒麟」以外的1只「炎王」怪兽特殊召唤。那之后，可以把场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：当前阶段必须是主要阶段1或主要阶段2（即自己·对方的主要阶段）。
function s.spscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 定义破坏对象的选择过滤器：需要是表侧表示、炎属性，并且在它被破坏后自己场上有可以特殊召唤怪兽的空格。
function s.filter(c,tp)
	-- 过滤器具体条件：对象为表侧表示的炎属性怪兽，且破坏该对象后自己场上可用怪兽区数量大于0。
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的目标处理：检索可破坏的炎属性怪兽集合，确认自己可以特殊召唤麒麟，并写入“破坏+特殊召唤”的操作信息。
function s.spstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 取得自己手卡·场上（表侧表示）中，麒麟以外满足s.filter条件的炎属性怪兽集合，作为潜在的破坏对象。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,c,tp)
	if chk==0 then return #g>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果预定会破坏1张卡（对象从g中确定，但实际在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本次效果预定会特殊召唤麒麟自己。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的实际处理：选择1张炎属性怪兽破坏；若破坏成功且麒麟仍在效果对应状态，则将麒麟特殊召唤。
function s.spsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示，让玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己手卡·场上选择1张满足条件的炎属性怪兽（麒麟自身除外）作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,aux.ExceptThisCard(e),tp)
	-- 若破坏处理成功，且麒麟与当前效果仍有联系（未因离场等原因重置），继续执行特殊召唤。
	if Duel.Destroy(g,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将麒麟以表侧攻击表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡是被破坏并送去墓地的场合才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- ②效果特殊召唤对象的过滤器：必须是「炎王」系列怪兽、可以特殊召唤，且不是麒麟自身。
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x81) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(id)
end
-- ②效果的目标处理（发动时判定）：自己场上存在可用怪兽区，且手卡·墓地中存在符合条件的「炎王」怪兽才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检查：自己场上的怪兽区域有空位，能够进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动检查：在手卡或墓地中存在至少1只满足s.sfilter的「炎王」怪兽（麒麟以外）。
		and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果预定从自己的手卡·墓地特殊召唤1只「炎王」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果的实际处理：从手卡·墓地选择并特殊召唤1只「炎王」怪兽；若特殊召唤成功且玩家选择“是”，再破坏场上1张卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认是否有可用怪兽区，若没有则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·墓地选择1只符合条件的「炎王」怪兽（排除受王家长眠之谷影响不可特殊召唤的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.sfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 执行特殊召唤；若特殊召唤数量小于1，说明没有成功，后续破坏处理不再执行。
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)<1
		-- 若特殊召唤失败，或玩家选择“否”（不破坏场上卡），则结束整个效果处理。
		or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end  --"是否破坏场上1张卡？"
	-- 弹出选择提示，让玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上所有卡中，由玩家选择1张卡（不取对象，效果处理时选择）。
	local sg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	-- 手动显示被选中的卡的指定动画，并记录为已被选中。
	Duel.HintSelection(sg)
	-- 中断当前效果链，使后续的破坏处理与之前的特殊召唤视为不同时处理，避免错失时点。
	Duel.BreakEffect()
	-- 以效果破坏所选中的卡片。
	Duel.Destroy(sg,REASON_EFFECT)
end
