--ホルスの黒炎竜 LV6
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，不会受到魔法效果的影响。这张卡战斗破坏怪兽的回合的结束阶段时，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「荷鲁斯之黑炎龙 LV8」。
function c11224103.initial_effect(c)
	-- 对应效果原文：“这张卡战斗破坏怪兽的回合的结束阶段时”中的“战斗破坏怪兽”部分——登记本回合战斗破坏过怪兽的标记。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	-- 触发条件：仅当这张卡进行战斗并战斗破坏怪兽时满足（aux.bdcon判断本卡与战斗相关）。
	e1:SetCondition(aux.bdcon)
	e1:SetOperation(c11224103.bdop)
	c:RegisterEffect(e1)
	-- 对应效果原文：“只要这张卡在自己场上表侧表示存在，不会受到魔法效果的影响。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c11224103.efilter)
	c:RegisterEffect(e2)
	-- 对应效果原文：“这张卡战斗破坏怪兽的回合的结束阶段时，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「荷鲁斯之黑炎龙 LV8」。”
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11224103,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c11224103.spcon)
	e3:SetCost(c11224103.spcost)
	e3:SetTarget(c11224103.sptg)
	e3:SetOperation(c11224103.spop)
	c:RegisterEffect(e3)
end
c11224103.lvup={48229808}
c11224103.lvdn={75830094}
-- 在战斗破坏怪兽时给自身注册编号11224103的标识，该标识在阶段结束时重置，用来标记本回合此卡战斗破坏过怪兽。
function c11224103.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11224103,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤函数：把要被免疫的效果判定为是否为魔法效果；如果效果属于魔法类型，则此卡不受其影响。
function c11224103.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 升级效果发动条件：检查自身是否带有编号11224103的标识（即本回合是否战斗破坏过怪兽）。
function c11224103.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11224103)>0
end
-- 效果发动代价：确认此卡自身能够作为代价送去墓地；实际操作是将其送入墓地。
function c11224103.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡作为代价（REASON_COST）送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选怪兽：卡名必须为「荷鲁斯之黑炎龙 LV8」，且可以被当前效果特殊召唤（无视召唤条件与苏生限制，符合LV8只能由LV6效果特殊召唤的设定）。
function c11224103.spfilter(c,e,tp)
	return c:IsCode(48229808) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 升级效果的目标判断：检查我方怪兽区在自身作为cost送墓后是否会有空位，以及手卡·卡组中是否存在符合条件的「荷鲁斯之黑炎龙 LV8」。
function c11224103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 空格判定：当前怪兽区空格数大于-1即可（因自身将作为代价送去墓地，会腾出一个格子），确保处理时能放置特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 存在性判定：手卡·卡组中存在至少1只满足spfilter条件的「荷鲁斯之黑炎龙 LV8」，发动才能成功。
		and Duel.IsExistingMatchingCard(c11224103.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：声明本次效果将进行特殊召唤，对象数量为1，来源为手卡·卡组（供其他卡片进行效果连锁检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若场上仍有空位，则从手卡·卡组选择1只「荷鲁斯之黑炎龙 LV8」表侧表示特殊召唤，并使其完成正规召唤手续（无视召唤条件/苏生限制）。
function c11224103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查我方怪兽区是否还有空位，若没有则终止处理，避免因场上变化导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家弹出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡·卡组中选出1张满足spfilter条件的卡，也就是「荷鲁斯之黑炎龙 LV8」。
	local g=Duel.SelectMatchingCard(tp,c11224103.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 把选中的「荷鲁斯之黑炎龙 LV8」以表侧表示特殊召唤到我方场上（不限制召唤方式，不检查召唤条件/苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
