--アルティメット・インセクト LV5
-- 效果：
-- 「究极昆虫 LV3」的效果特殊召唤的场合，只要这张卡在场上存在，对方场上的全部怪兽攻击力下降500。自己回合的准备阶段时，可以把表侧表示的这张卡送去墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV7」上场。（召唤·特殊召唤·反转的回合不能使用此效果）
function c34830502.initial_effect(c)
	-- 「究极昆虫 LV3」的效果特殊召唤的场合，只要这张卡在场上存在，对方场上的全部怪兽攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c34830502.con)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- 自己回合的准备阶段时，可以把表侧表示的这张卡送去墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV7」上场。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34830502,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c34830502.spcon)
	e2:SetCost(c34830502.spcost)
	e2:SetTarget(c34830502.sptg)
	e2:SetOperation(c34830502.spop)
	c:RegisterEffect(e2)
	-- （召唤·特殊召唤·反转的回合不能使用此效果）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c34830502.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c34830502.lvup={34088136,19877898}
c34830502.lvdn={49441499,34088136}
-- 检查这张卡的召唤/特殊召唤方式是否为经由「究极昆虫 LV3」的效果进行的LV特殊召唤，以此作为攻击力下降效果的适用条件。
function c34830502.con(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV
end
-- 当这张卡召唤、特殊召唤或反转成功时，给自身注册一个直到结束阶段为止的标记，用于“召唤·特殊召唤·反转的回合不能使用此效果”的限制。
function c34830502.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34830503,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 发动升阶效果的触发条件：必须是这张卡的持有者（控制者）的回合的准备阶段，且这张卡本回合没有进行过召唤·特殊召唤·反转（无对应标记）。
function c34830502.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前为这张卡的控制者的准备阶段，且这张卡没有“召唤·特殊召唤·反转的回合”的标记，满足两个条件才可发动升级效果。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(34830503)==0
end
-- 以将这张卡自身送去墓地为代价来发动效果；先检查这张卡是否可以作为代价送去墓地，可以则执行。
function c34830502.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身从场上送入墓地，作为发动升级效果所需的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选手卡·卡组中卡名为「究极昆虫 LV7」（卡号19877898）且能够被特殊召唤的卡，作为特殊召唤的对象。
function c34830502.spfilter(c,e,tp)
	return c:IsCode(19877898) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 发动前的目标判定：检查自己场上是否有可用的怪兽区域空格，以及手卡·卡组是否存在符合条件的「究极昆虫 LV7」，两者均满足才能发动。
function c34830502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的怪兽区域空格（此处写法表示即便为0也先通过，具体在效果处理时再进一步判断）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组中是否存在卡名为「究极昆虫 LV7」且满足特殊召唤条件的卡片（至少1张）。
		and Duel.IsExistingMatchingCard(c34830502.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果的操作信息：效果处理时将进行1只怪兽的特殊召唤，对象可能来自手卡·卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若场上仍有空位，则让玩家从手卡·卡组选择1只「究极昆虫 LV7」，以LV特殊召唤方式特殊召唤到场上，并完成LV怪兽的特殊召唤手续。
function c34830502.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有怪兽区域空格，若没有空格则效果处理不成功（直接终止）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示信息，引导选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1张满足条件的「究极昆虫 LV7」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c34830502.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「究极昆虫 LV7」以LV特殊召唤方式、表侧表示特殊召唤到自己的场上，并解除特殊召唤限制；后续还需调用CompleteProcedure完成LV怪兽的进化流程。
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
