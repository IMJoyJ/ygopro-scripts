--アルティメット・インセクト LV1
-- 效果：
-- 自己场上表侧表示存在的这张卡不会受到魔法的效果影响。自己回合的准备阶段时，可以把表侧表示的这张卡送到墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV3」。（召唤·特殊召唤·反转的回合不能使用此效果）
function c49441499.initial_effect(c)
	-- 自己场上表侧表示存在的这张卡不会受到魔法的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c49441499.efilter)
	c:RegisterEffect(e1)
	-- 自己回合的准备阶段时，可以把表侧表示的这张卡送到墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV3」。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49441499,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c49441499.spcon)
	e2:SetCost(c49441499.spcost)
	e2:SetTarget(c49441499.sptg)
	e2:SetOperation(c49441499.spop)
	c:RegisterEffect(e2)
	-- （召唤·特殊召唤·反转的回合不能使用此效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c49441499.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c49441499.lvup={34088136}
-- 免疫过滤函数：判断尝试适用的效果是否为魔法卡效果；若为魔法卡效果则本卡不受其影响。
function c49441499.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 给本卡注册一个标识（flag），记录其在本回合进行过召唤/特殊召唤/反转，用于禁止本回合升级效果的发动；该标识会在离场、暂时除外或结束时重置。
function c49441499.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(49441499,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 升级效果的发动条件：必须是自己的准备阶段，且本卡身上没有“召唤/特殊召唤/反转”的标记（即本回合未曾被召唤·特殊召唤·反转过）。
function c49441499.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前为回合玩家的准备阶段，且此卡没有本回合因召唤/特殊召唤/反转产生的禁用标记。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(49441499)==0
end
-- 升级效果的COST：将这张表侧表示的此卡送去墓地作为发动代价；检查其是否能作为代价送墓。
function c49441499.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 实际执行COST：把此卡（自身）送入墓地，理由为代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象过滤：选择卡名为「究极昆虫 LV3」（34088136）且能够特殊召唤的卡（不检查召唤条件/苏生限制）。
function c49441499.spfilter(c,e,tp)
	return c:IsCode(34088136) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 升级效果发动时检查：自己主要怪兽区有空位（或此卡COST送墓后空出），且手卡·卡组存在符合条件的「究极昆虫 LV3」。
function c49441499.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否有足够怪兽区空位；由于COST会送墓此卡腾出1格，因此当前可用区域为0时也判定可以发动（>-1即>=0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组中是否存在至少1只符合条件的『究极昆虫 LV3』。
		and Duel.IsExistingMatchingCard(c49441499.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本效果将进行特殊召唤操作：从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：确认有可用怪兽区后，提示玩家从手卡·卡组选择1只『究极昆虫 LV3』，以表侧表示特殊召唤，并完成LV怪物的升级手续。
function c49441499.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前主要怪兽区没有可用位置，则不进行后续特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组选择1张符合条件的『究极昆虫 LV3』。
	local g=Duel.SelectMatchingCard(tp,c49441499.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的『究极昆虫 LV3』以表侧表示特殊召唤（使用LV升级特殊召唤方式，无视召唤条件/苏生限制）。
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
