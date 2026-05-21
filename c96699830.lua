--ボーン・フロム・ドラコニス
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。
-- ①：从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外才能发动。从手卡把1只6星以上的机械族·光属性怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成因为这张卡发动而除外的怪兽数量×500，不受自身以外的卡的效果影响。
function c96699830.initial_effect(c)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外才能发动。从手卡把1只6星以上的机械族·光属性怪兽无视召唤条件特殊召唤。这个效果特殊召唤的怪兽的攻击力·守备力变成因为这张卡发动而除外的怪兽数量×500，不受自身以外的卡的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c96699830.cost)
	e1:SetTarget(c96699830.target)
	e1:SetOperation(c96699830.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示及自己墓地的机械族·光属性且可以除外的怪兽
function c96699830.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：检查是否能除外怪兽且本回合未进行过其他特殊召唤，并注册本回合不能用此卡以外的效果特殊召唤的限制，最后将符合条件的怪兽全部除外并记录除外数量
function c96699830.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上表侧表示及自己墓地中所有满足条件的机械族·光属性怪兽
	local g=Duel.GetMatchingGroup(c96699830.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 检查阶段：必须存在至少1只可除外的怪兽，且本回合自己没有进行过特殊召唤
	if chk==0 then return g:GetCount()>0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽特殊召唤。①：从自己墓地以及自己场上的表侧表示怪兽之中把机械族·光属性怪兽全部除外才能发动。从手卡把1只6星以上的机械族·光属性怪兽无视召唤条件特殊召唤。...不受自身以外的卡的效果影响。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c96699830.splimit)
	e1:SetLabelObject(e)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册本回合不能进行其他特殊召唤的限制效果
	Duel.RegisterEffect(e1,tp)
	-- 将选定的怪兽全部表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 限制效果的过滤函数：限制只能通过当前发动的效果进行特殊召唤
function c96699830.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return se~=e:GetLabelObject()
end
-- 过滤手卡中满足等级6星以上、机械族、光属性且可以特殊召唤（无视召唤条件）的怪兽
function c96699830.spfilter(c,e,tp)
	return c:IsLevelAbove(6) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果发动时的目标检查与宣告：检查怪兽区域是否有空位，以及手卡中是否存在可特殊召唤的怪兽，并设置特殊召唤的操作信息
function c96699830.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c96699830.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选择1只符合条件的怪兽无视召唤条件特殊召唤，并使其攻击力·守备力变成除外数量×500，且不受自身以外的卡的效果影响
function c96699830.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上没有可用的怪兽区域空格，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c96699830.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则尝试将其以表侧表示无视召唤条件特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		local val=e:GetLabel()*500
		-- 不受自身以外的卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c96699830.efilter)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的攻击力·守备力变成因为这张卡发动而除外的怪兽数量×500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_ATTACK)
		e2:SetValue(val)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e3)
	end
	-- 完成特殊召唤流程，使特殊召唤正式生效
	Duel.SpecialSummonComplete()
end
-- 抗性过滤函数：使该怪兽不受自身以外的卡片效果影响
function c96699830.efilter(e,re)
	return e:GetHandler()~=re:GetHandler()
end
