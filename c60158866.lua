--不朽の七皇
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以以自己场上1只「No.101」～「No.107」其中任意种的「No.」超量怪兽或者有那怪兽在作为超量素材中的超量怪兽为对象，从以下效果选择1个发动。
-- ●选持有作为对象的怪兽的攻击力以下的攻击力的对方场上1只怪兽，那个效果直到回合结束时无效。
-- ●作为对象的怪兽的超量素材全部取除。那之后，可以从自己墓地选1只「No.」超量怪兽特殊召唤。
function c60158866.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：可以以自己场上1只「No.101」～「No.107」其中任意种的「No.」超量怪兽或者有那怪兽在作为超量素材中的超量怪兽为对象，从以下效果选择1个发动。●选持有作为对象的怪兽的攻击力以下的攻击力的对方场上1只怪兽，那个效果直到回合结束时无效。●作为对象的怪兽的超量素材全部取除。那之后，可以从自己墓地选1只「No.」超量怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,60158866)
	e2:SetTarget(c60158866.target)
	e2:SetOperation(c60158866.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查卡片是否为「No.101」～「No.107」的「No.」超量怪兽
function c60158866.filter(c)
	-- 获取卡片的「No.」编号
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- 过滤函数：检查怪兽是否为超量怪兽，且其自身或其超量素材中包含「No.101」～「No.107」的「No.」超量怪兽
function c60158866.cfilter(c)
	if not c:IsType(TYPE_XYZ) then return false end
	if c60158866.filter(c) then return true end
	local g=c:GetOverlayGroup()
	return g:IsExists(c60158866.filter,1,nil)
end
-- 过滤函数：检查对方场上是否存在攻击力在指定数值以下、且可以被无效效果的怪兽
function c60158866.disfilter(c,atk)
	-- 检查怪兽是否可以被无效，且其攻击力在指定数值以下
	return aux.NegateMonsterFilter(c) and c:IsAttackBelow(atk)
end
-- 效果①的发动准备阶段，处理对象选择以及分支效果的可行性检测与玩家选择
function c60158866.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60158866.cfilter(chkc) end
	-- 检查自己场上是否存在符合条件的可作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c60158866.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只符合条件的怪兽作为对象
	local g=Duel.SelectTarget(tp,c60158866.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local s=0
	-- 检查对方场上是否存在持有作为对象的怪兽的攻击力以下的攻击力的怪兽
	local b1=Duel.IsExistingMatchingCard(c60158866.disfilter,tp,0,LOCATION_MZONE,1,nil,tc:GetAttack())
	local b2=tc:GetOverlayGroup():GetCount()>0
	if b1 and not b2 then
		-- 仅能选择第一个分支效果（无效对方怪兽效果）
		s=Duel.SelectOption(tp,aux.Stringid(60158866,0))  --"效果无效"
	end
	if not b1 and b2 then
		-- 仅能选择第二个分支效果（取除素材并特殊召唤）
		s=Duel.SelectOption(tp,aux.Stringid(60158866,1))+1  --"特殊召唤"
	end
	if b1 and b2 then
		-- 让玩家从两个分支效果中选择一个发动
		s=Duel.SelectOption(tp,aux.Stringid(60158866,0),aux.Stringid(60158866,1))  --"效果无效/特殊召唤"
	end
	e:SetLabel(s)
	if s==0 then
		e:SetCategory(0)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
-- 效果①的执行阶段，根据玩家在发动时选择的分支效果进行对应的处理
function c60158866.operation(e,tp,eg,ep,ev,re,r,rp)
	local s=e:GetLabel()
	-- 获取作为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if s==0 then
		if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
		-- 获取对方场上所有持有作为对象的怪兽的攻击力以下的攻击力且可被无效的怪兽
		local sg=Duel.GetMatchingGroup(c60158866.disfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		if sg:GetCount()>0 then
			-- 提示玩家选择要无效效果的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
			local sc=sg:Select(tp,1,1,nil):GetFirst()
			if sc and not sc:IsImmuneToEffect(e) then
				-- 使与目标怪兽相关的连锁中已发动的效果无效化
				Duel.NegateRelatedChain(sc,RESET_TURN_SET)
				-- 那个效果直到回合结束时无效。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1)
				-- 那个效果直到回合结束时无效。
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e2)
			end
		end
	end
	if s==1 then
		if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
			local og=tc:GetOverlayGroup()
			-- 将作为对象的怪兽的超量素材全部取除
			if og:GetCount()>0 and Duel.SendtoGrave(og,REASON_EFFECT)>0
				-- 检查自己场上是否有空余的怪兽区域
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查自己墓地是否存在可以特殊召唤的「No.」超量怪兽（受王家之谷影响）
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c60158866.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp)
				-- 询问玩家是否选择从墓地特殊召唤1只「No.」超量怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(60158866,2)) then  --"是否从墓地选「No.」超量怪兽特殊召唤？"
				-- 提示玩家选择要特殊召唤的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 从自己墓地选择1只符合条件的「No.」超量怪兽
				local ng=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c60158866.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
				if ng:GetCount()>0 then
					-- 中断当前效果，使后续的特殊召唤处理不与取除素材同时处理（用于“那之后”的时点处理）
					Duel.BreakEffect()
					-- 将选择的「No.」超量怪兽表侧表示特殊召唤
					Duel.SpecialSummon(ng,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
-- 过滤函数：检查卡片是否为可以特殊召唤的「No.」超量怪兽
function c60158866.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
