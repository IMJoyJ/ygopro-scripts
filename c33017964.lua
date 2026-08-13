--幻魔の扉
-- 效果：
-- 这个卡名的效果在决斗中只能适用1次。
-- ①：把基本分支付一半才能发动。对方场上的怪兽全部破坏。那之后，可以从对方墓地把1只怪兽无视召唤条件在自己场上特殊召唤。
local s,id,o=GetID()
-- 效果的整体注册逻辑：新建效果e1，设置描述、分类、类型、发动时点、代价、发动条件和处理函数，最后将效果注册给幻魔之扉这张卡。
function s.initial_effect(c)
	-- 对应效果原文“①：把基本分支付一半才能发动。对方场上的怪兽全部破坏。那之后，可以从对方墓地把1只怪兽无视召唤条件在自己场上特殊召唤。”，此处为发动效果的整体配置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 代价函数：在发动时进行代价检测，若为检测阶段（chk==0）则直接返回true表示代价可支付；实际发动时支付基本分一半的LP。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付基本分一半：失去当前LP的一半作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 发动条件与操作信息设置函数：检查决斗中是否已适用过该效果、对方场上是否有怪兽；若有，则将对方场上所有怪兽作为破坏对象写入操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自身flag效果为0（该卡名效果在决斗中尚未适用）且对方场上存在至少1只怪兽。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有怪兽，用于后续破坏效果的操作信息。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置本次连锁需要处理的破坏信息：破坏对象为对方场上所有怪兽，数量为这些怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 特殊召唤的过滤函数：从对方墓地选择满足条件的怪兽，要求该卡是怪兽且能被无视召唤条件特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果处理函数：确认决斗中尚未适用过该效果后登记flag；破坏对方场上全部怪兽；若成功破坏且我方有可用怪兽区，则询问玩家是否从对方墓地选1只怪兽特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查该卡名效果在决斗中是否已适用过，若已适用则直接终止本次处理（双重保障）。
	if Duel.GetFlagEffect(tp,id)>0 then return end
	-- 给玩家tp登记一个效果标志（code为id，reset为0即不重置），表示本决斗中该效果已经适用过1次。
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	-- 再次取得对方场上全部怪兽，用于实际破坏处理（因为发动后对方场面可能发生变化）。
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上全部怪兽；仅当实际破坏了至少1张且我方场上有可用的怪兽区域时，才继续后续的特殊召唤处理。
	if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.GetMZoneCount(tp)>0 then
		-- 从对方墓地检索可特殊召唤的怪兽，并排除受“王家长眠之谷”效果影响的卡；过滤条件为s.spfilter。
		local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,0,LOCATION_GRAVE,nil,e,tp)
		-- 若存在可特殊召唤的候选怪兽，则询问玩家“是否特殊召唤？”。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使其后的处理与破坏效果不再视为同时处理（错开时点）。
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的卡，显示选择消息“请选择要特殊召唤的卡”。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local g=sg:Select(tp,1,1,nil)
			-- 手动显示被选中的卡片的选中动画，并记录该卡被选为对象。
			Duel.HintSelection(g)
			-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上，无视召唤条件，且不检查苏生限制。
			Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
