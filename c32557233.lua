--六花深々
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡也能把自己场上1只植物族怪兽解放来发动。
-- ①：从自己墓地选1只「六花」怪兽守备表示特殊召唤。把怪兽解放来把这张卡发动的场合，再从自己墓地选1只植物族怪兽守备表示特殊召唤。
function c32557233.initial_effect(c)
	-- 对应效果原文：‘这个卡名的卡在1回合只能发动1张。’及‘①：从自己墓地选1只「六花」怪兽守备表示特殊召唤。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32557233,0))  --"不解放怪兽发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,32557233+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c32557233.target)
	e1:SetOperation(c32557233.activate)
	c:RegisterEffect(e1)
	-- 对应效果原文：‘这张卡也能把自己场上1只植物族怪兽解放来发动。’及‘把怪兽解放来把这张卡发动的场合，再从自己墓地选1只植物族怪兽守备表示特殊召唤。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32557233,1))  --"解放怪兽发动"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,32557233+EFFECT_COUNT_CODE_OATH)
	e2:SetCost(c32557233.cost)
	e2:SetTarget(c32557233.target2)
	e2:SetOperation(c32557233.activate2)
	c:RegisterEffect(e2)
end
-- 定义「六花」怪兽的过滤器：候选卡需属于「六花」字段且能被效果以表侧守备表示特殊召唤；当check为真时，还需额外确认墓地存在至少1只可被特殊召唤的植物族怪兽（供解放发动时追加特殊召唤）。
function c32557233.spfilter(c,e,tp,check)
	return c:IsSetCard(0x141) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 当check为false时，额外检查墓地是否存在满足spfilter2的植物族怪兽，以保证解放发动的情况下能完成追加特殊召唤。
		and (check or Duel.IsExistingMatchingCard(c32557233.spfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp))
end
-- 定义植物族怪兽的过滤器：候选卡需为植物族且能被效果以表侧守备表示特殊召唤，用于追加特殊召唤的选择。
function c32557233.spfilter2(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 不解放发动时的发动条件检测：在我方主怪兽区有空位、墓地存在符合条件的「六花」怪兽（且已确认有可追加召唤的植物族怪兽）时，登记后续将进行1次从墓地特殊召唤。
function c32557233.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查我方主怪兽区是否存在至少1个空位，以确保能特殊召唤怪兽。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查墓地是否存在至少1只满足spfilter（「六花」可特召并要求check=true，即同时存在可追加特召的植物族怪兽）的卡，作为发动前提。
			and Duel.IsExistingMatchingCard(c32557233.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,true)
	end
	-- 登记本次连锁的操作信息：将从墓地特殊召唤1只怪兽，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 不解放发动时的效果处理：检查主怪兽区有空位后，提示玩家从自己墓地选择1只满足spfilter且不受王家长眠之谷影响的「六花」怪兽，将其表侧守备表示特殊召唤。
function c32557233.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若主怪兽区没有空位，则效果不处理，直接中止本次特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，提示内容为‘请选择要特殊召唤的卡’，随后进入卡片选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足spfilter且不受王家长眠之谷影响的「六花」怪兽（check=true保证追加植物族怪兽存在），作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32557233.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「六花」怪兽以表侧守备表示特殊召唤到我方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义解放代价的过滤器：解放该怪兽后我方至少仍有2个主怪兽区空位（用于随后特召两只怪兽），且该怪兽的控制者是我方或表侧表示；该怪兽必须是植物族，或者拥有76869711号效果且控制者为对方的卡（在特定互动下也可作为植物族解放）。
function c32557233.rfilter(c,tp)
	-- 要求解放c后我方仍有至少2个可用怪兽区空位，且c的控制者是我方或c为表侧表示（以满足解放条件）。
	return Duel.GetMZoneCount(tp,c)>1 and (c:IsControler(tp) or c:IsFaceup())
		and (c:IsRace(RACE_PLANT) or c:IsHasEffect(76869711,tp) and c:IsControler(1-tp))
end
-- 解放发动时的代价处理：先给效果打上‘已通过解放发动’的标记（e:SetLabel(1)），然后在发动合法性检查通过后，让玩家从自己场上选择1只满足rfilter的怪兽并解放作为代价。
function c32557233.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动合法性检查阶段，确认场上是否存在至少1只满足rfilter的可解放怪兽；若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c32557233.rfilter,1,nil,tp) end
	-- 向玩家发送选择解放怪兽的提示，提示内容为‘请选择要解放的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从自己场上选择1只满足rfilter的怪兽，作为发动这张卡的解放代价。
	local g=Duel.SelectReleaseGroup(tp,c32557233.rfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，解放原因为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 解放发动时的目标检测：通过e的标签判断是否已解放怪兽，或检查主怪兽区空位是否足够2个，并确认墓地存在可特殊召唤的「六花」怪兽与植物族怪兽各至少1只，且本回合剩余特殊召唤次数允许2次；最后登记将进行2次从墓地特殊召唤。
function c32557233.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否具备两次特殊召唤的条件：如果cost已置标签1（表示已解放怪兽），则直接视为满足；否则需要主怪兽区空位多于1个（虽然非解放发动只特召1只，但此检测用于确认第二次特殊召唤的空间）。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	if chk==0 then
		e:SetLabel(0)
		return res and e:IsHasType(EFFECT_TYPE_ACTIVATE)
			-- 检查墓地是否存在至少1只满足spfilter的「六花」怪兽，作为第一个特殊召唤对象。
			and Duel.IsExistingMatchingCard(c32557233.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 检查当前玩家本回合是否还能进行2次特殊召唤，防止超出特殊召唤次数限制。
			and Duel.IsPlayerCanSpecialSummonCount(tp,2)
	end
	-- 登记本次连锁的操作信息：将从墓地特殊召唤2只怪兽，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 解放发动时的效果处理：先选择并特殊召唤1只「六花」怪兽；若成功，且效果仍为发动中效果、主怪兽区仍有空位、墓地存在可特殊召唤的植物族怪兽，则中断当前处理，再选择1只植物族怪兽以表侧守备表示特殊召唤。
function c32557233.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 若主怪兽区没有空位，则无法特殊召唤第一只怪兽，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，提示内容为‘请选择要特殊召唤的卡’，用于选择第一只特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张满足spfilter且不受王家长眠之谷影响的「六花」怪兽（check=true同时确保植物族追加对象存在），作为第一只特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32557233.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp,true)
	local tc=g:GetFirst()
	-- 若成功选择了「六花」怪兽且特殊召唤成功（返回值非0），才继续执行追加植物族特殊召唤。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		if e:IsHasType(EFFECT_TYPE_ACTIVATE)
			-- 追加条件之一：主怪兽区仍至少有1个空位，用于特殊召唤第二只怪兽。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 追加条件之二：墓地存在至少1只满足spfilter2且不受王家长眠之谷影响的植物族怪兽，可选为追加特殊召唤对象。
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c32557233.spfilter2),tp,LOCATION_GRAVE,0,1,nil,e,tp) then
			-- 中断当前效果处理，使追加的特殊召唤作为新的处理节点，避免时点被占用（错开特召时点）。
			Duel.BreakEffect()
			-- 向玩家发送选择提示，提示内容为‘请选择要特殊召唤的卡’，用于选择追加特殊召唤对象。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从自己墓地选择1只满足spfilter2且不受王家长眠之谷影响的植物族怪兽，作为追加特殊召唤对象。
			local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c32557233.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			-- 将选中的植物族怪兽以表侧守备表示特殊召唤到我方场上。
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
