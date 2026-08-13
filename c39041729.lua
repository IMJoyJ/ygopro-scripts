--時空超越
-- 效果：
-- ①：从自己墓地把恐龙族怪兽2只以上除外才能发动。从自己的手卡·墓地选持有和除外的怪兽的等级合计相同等级的1只恐龙族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
function c39041729.initial_effect(c)
	-- ①：从自己墓地把恐龙族怪兽2只以上除外才能发动。从自己的手卡·墓地选持有和除外的怪兽的等级合计相同等级的1只恐龙族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetLabel(0)
	e1:SetCost(c39041729.cost)
	e1:SetTarget(c39041729.target)
	e1:SetOperation(c39041729.activate)
	c:RegisterEffect(e1)
end
-- 判断手卡·墓地中的一只恐龙族怪兽能否作为特殊召唤对象：需要其等级大于0、种族为恐龙、可被效果特殊召唤，并且墓地存在至少2只恐龙族怪兽的等级合计恰好等于该怪兽的等级。
function c39041729.filter(c,e,tp)
	-- 获取墓地中除被判断怪兽自身以外、可作为代价除外的恐龙族怪兽集合，用于后续等级合计判定。
	local rg=Duel.GetMatchingGroup(c39041729.cfilter,tp,LOCATION_GRAVE,0,c)
	local lv=c:GetLevel()
	return lv>0 and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and rg:CheckWithSumEqual(Card.GetLevel,lv,2,99)
end
-- 筛选可作为除外代价的恐龙族怪兽：种族为恐龙且满足可以作为代价除外。
function c39041729.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToRemoveAsCost()
end
-- 代价判定函数：在代价确认前先将标记设为100，表示已进入代价选择流程；chk==0时返回true表示代价表面上可支付（实际除外在target阶段完成）。
function c39041729.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 发动效果的目标选择与代价支付：先进行合法性检查，然后让玩家宣言一个等级，从墓地选择等级合计等于该等级的至少2只恐龙族怪兽除外作为代价，并设置后续特殊召唤的操作信息。
function c39041729.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己主要怪兽区是否存在可用空格，确保可以特殊召唤怪兽。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查手卡·墓地中是否存在至少1只满足特殊召唤条件的恐龙族怪兽（通过filter筛选，包括等级可行性）。
			and Duel.IsExistingMatchingCard(c39041729.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 获取手卡·墓地中所有满足特殊召唤条件的恐龙族怪兽集合，用于构建可选等级列表。
	local g=Duel.GetMatchingGroup(c39041729.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	local lvt={}
	local pc=1
	for i=2,12 do
		if g:IsExists(c39041729.spfilter,1,nil,e,tp,i) then lvt[pc]=i pc=pc+1 end
	end
	lvt[pc]=nil
	-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的怪兽的等级”（通过Stringid获取多语言文本）。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39041729,0))  --"请选择要特殊召唤的怪兽的等级"
	-- 让玩家从可选等级中宣言一个等级，作为要特殊召唤的怪兽的等级，同时用于确定除外怪兽的等级合计目标。
	local lv=Duel.AnnounceNumber(tp,table.unpack(lvt))
	-- 获取墓地中所有可作为代价除外的恐龙族怪兽集合（不排除任何卡，因为要从中选取等级合计的一部分）。
	local rg=Duel.GetMatchingGroup(c39041729.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 向玩家发送选择提示，提示内容为“请选择要除外的卡”，用于选择墓地中要除外的恐龙族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:SelectWithSumEqual(tp,Card.GetLevel,lv,2,99)
	-- 将玩家选择的恐龙族怪兽以表侧表示除外，作为发动效果的代价。
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(lv)
	-- 设置连锁处理信息，表示本效果将在后续从手卡·墓地特殊召唤1只怪兽（数量1，位置为手卡+墓地）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 筛选最终要特殊召唤的怪兽：必须是指定等级、恐龙族且可以被特殊召唤。
function c39041729.spfilter(c,e,tp,lv)
	return c:IsLevel(lv) and c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：选择并特殊召唤1只符合条件的恐龙族怪兽，并给它附加本回合不能攻击的效果。
function c39041729.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，若无空位则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足等级、恐龙族、可特殊召唤且不受王家长眠之谷影响的怪兽（通过NecroValleyFilter过滤）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c39041729.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp,e:GetLabel())
	local tc=g:GetFirst()
	if tc then
		-- 将选择的恐龙族怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽在这个回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
