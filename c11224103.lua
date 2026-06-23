--ホルスの黒炎竜 LV6
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，不会受到魔法效果的影响。这张卡战斗破坏怪兽的回合的结束阶段时，可以把这张卡送去墓地，从手卡·卡组特殊召唤1只「荷鲁斯之黑炎龙 LV8」。
function c11224103.initial_effect(c)
	-- 诱发效果：当这张卡战斗破坏怪兽时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	-- 效果条件：确认该卡是否与本次战斗有关
	e1:SetCondition(aux.bdcon)
	e1:SetOperation(c11224103.bdop)
	c:RegisterEffect(e1)
	-- 永续效果：这张卡不会受到魔法效果的影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c11224103.efilter)
	c:RegisterEffect(e2)
	-- 诱发效果：结束阶段时，可以将这张卡送去墓地，从手卡·卡组特殊召唤1只「荷鲁斯之黑炎龙 LV8」
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
-- 效果处理：为这张卡注册一个标记，表示它在战斗中破坏过怪兽
function c11224103.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(11224103,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果过滤器：对魔法卡的效果免疫
function c11224103.efilter(e,te)
	return te:IsActiveType(TYPE_SPELL)
end
-- 效果条件：确认该卡是否在战斗中破坏过怪兽（通过标记判断）
function c11224103.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(11224103)>0
end
-- 效果代价：支付将此卡送去墓地的代价
function c11224103.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送去墓地作为发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤器：检查手卡或卡组中是否存在「荷鲁斯之黑炎龙 LV8」
function c11224103.spfilter(c,e,tp)
	return c:IsCode(48229808) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 效果目标设定：确认是否可以特殊召唤「荷鲁斯之黑炎龙 LV8」
function c11224103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的场地条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在满足条件的「荷鲁斯之黑炎龙 LV8」
		and Duel.IsExistingMatchingCard(c11224103.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只「荷鲁斯之黑炎龙 LV8」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：执行特殊召唤「荷鲁斯之黑炎龙 LV8」的操作
function c11224103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤场地
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择手卡或卡组中满足条件的「荷鲁斯之黑炎龙 LV8」
	local g=Duel.SelectMatchingCard(tp,c11224103.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「荷鲁斯之黑炎龙 LV8」特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
