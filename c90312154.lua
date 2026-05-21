--失われた聖域
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，从卡组选1张「天空的圣域」或者有那个卡名记述的魔法·陷阱卡在自己场上盖放。
-- ②：这张卡的卡名只要在场上·墓地存在当作「天空的圣域」使用。
-- ③：从自己墓地把1只天使族怪兽除外，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c90312154.initial_effect(c)
	-- 在卡片关系列表中记录该卡记述了「天空的圣域」
	aux.AddCodeList(c,56433456)
	-- 使这张卡在场上·墓地存在时，卡名当作「天空的圣域」使用
	aux.EnableChangeCode(c,56433456,LOCATION_SZONE+LOCATION_GRAVE)
	-- ①：作为这张卡的发动时的效果处理，从卡组选1张「天空的圣域」或者有那个卡名记述的魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,90312154+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c90312154.target)
	e1:SetOperation(c90312154.activate)
	c:RegisterEffect(e1)
	-- ③：从自己墓地把1只天使族怪兽除外，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,90312155)
	e2:SetCost(c90312154.discost)
	e2:SetTarget(c90312154.distg)
	e2:SetOperation(c90312154.disop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「天空的圣域」或记述了该卡名的、可盖放的魔法·陷阱卡
function c90312154.filter(c,ft)
	-- 检查卡片是否为「天空的圣域」或记述了该卡名的魔法·陷阱卡，且可以盖放
	return aux.IsCodeOrListed(c,56433456) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
		and (ft==nil or ft>0 or c:IsType(TYPE_FIELD))
end
-- 卡片发动时效果处理的靶向与可行性检查函数
function c90312154.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上可用的魔法与陷阱区域空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 检查卡组中是否存在至少1张满足过滤条件的、可盖放的魔法·陷阱卡
		return Duel.IsExistingMatchingCard(c90312154.filter,tp,LOCATION_DECK,0,1,nil,ft)
	end
end
-- 卡片发动时效果处理的执行函数
function c90312154.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的卡片
	local tc=Duel.SelectMatchingCard(tp,c90312154.filter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		-- 将选中的卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 过滤自己墓地中可以作为发动成本除外的天使族怪兽
function c90312154.cfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
end
-- 效果③的发动成本处理函数
function c90312154.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可作为发动成本除外的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90312154.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1只满足条件的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c90312154.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外，作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的对象选择与可行性检查函数
function c90312154.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查已选择的对象是否仍是对方场上的表侧表示效果怪兽
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查对方场上是否存在可以成为效果对象的表侧表示效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效效果的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1只表侧表示的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息，表示该效果包含无效卡片效果的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果③的执行函数
function c90312154.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取已选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
