--オリファンの角笛
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的场上·墓地选1张装备魔法卡除外。那之后，可以选场上1张卡破坏。
-- ●选自己场上1只「罗兰」怪兽破坏。那之后，等级合计直到变成9星为止从卡组选最多3只战士族·炎属性怪兽效果无效守备表示特殊召唤。这个效果的发动后，直到下次的自己回合的结束时自己不是战士族怪兽不能特殊召唤。
function c55749927.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从自己的场上·墓地选1张装备魔法卡除外。那之后，可以选场上1张卡破坏。●选自己场上1只「罗兰」怪兽破坏。那之后，等级合计直到变成9星为止从卡组选最多3只战士族·炎属性怪兽效果无效守备表示特殊召唤。这个效果的发动后，直到下次的自己回合的结束时自己不是战士族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,55749927+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c55749927.target)
	e1:SetOperation(c55749927.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上或墓地的装备魔法卡
function c55749927.rmfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup() or c:GetEquipTarget())
		and (c:GetType()&(TYPE_EQUIP+TYPE_SPELL))==TYPE_EQUIP+TYPE_SPELL
		and c:IsAbleToRemove()
end
-- 过滤自己场上表侧表示的「罗兰」怪兽，并检查是否满足后续特殊召唤的格子和等级条件
function c55749927.desfilter(c,tp,g)
	-- 计算该怪兽被破坏后，自己场上可用的怪兽区域数量（最多为3）
	local ft=math.min((Duel.GetMZoneCount(tp,c)),3)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	return c:IsFaceup() and c:IsSetCard(0x148)
		and (not g or ft>0 and g:CheckWithSumEqual(Card.GetLevel,9,1,ft))
end
-- 过滤卡组中可以特殊召唤的等级9以下的战士族·炎属性怪兽
function c55749927.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelBelow(9)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与分支选择处理
function c55749927.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(c55749927.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 获取自己场上满足条件的「罗兰」怪兽组
	local g1=Duel.GetMatchingGroup(c55749927.desfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 检查自己场上或墓地是否存在可除外的装备魔法卡
	local b1=Duel.IsExistingMatchingCard(c55749927.rmfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,nil)
	-- 检查卡组中是否存在可特召的怪兽，且自己场上是否存在可破坏的「罗兰」怪兽
	local b2=g:GetCount()>0 and Duel.IsExistingMatchingCard(c55749927.desfilter,tp,LOCATION_MZONE,0,1,nil,tp,g)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个分支均满足时，让玩家选择发动其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(55749927,0),aux.Stringid(55749927,1))  --"除外并破坏/破坏并特殊召唤"
	elseif b1 then
		-- 仅分支1满足时，强制选择分支1
		op=Duel.SelectOption(tp,aux.Stringid(55749927,0))  --"除外并破坏"
	-- 仅分支2满足时，强制选择分支2
	else op=Duel.SelectOption(tp,aux.Stringid(55749927,1))+1 end  --"破坏并特殊召唤"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
		-- 设置除外操作的连锁信息
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
		-- 设置破坏操作的连锁信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
		-- 设置特殊召唤操作的连锁信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
-- 检查选中的怪兽卡组等级合计是否刚好等于9
function c55749927.spcheck(g)
	return g:GetSum(Card.GetLevel)==9
end
-- 效果处理的核心函数
function c55749927.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从自己场上或墓地选择1张装备魔法卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55749927.rmfilter),tp,LOCATION_GRAVE+LOCATION_ONFIELD,0,1,1,nil)
		local exc=nil
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) then exc=e:GetHandler() end
		-- 成功将选中的装备魔法卡除外
		if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0
			-- 检查场上是否存在其他卡片可以被破坏
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,exc)
			-- 询问玩家是否选择场上1张卡破坏
			and Duel.SelectYesNo(tp,aux.Stringid(55749927,2)) then  --"是否选卡破坏？"
			-- 中断当前效果处理，使后续的破坏处理不与除外同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家选择场上1张卡
			local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,exc)
			-- 闪烁显示被选中的卡
			Duel.HintSelection(g)
			-- 破坏选中的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	else
		-- 重新获取卡组中满足特召条件的怪兽组
		local g=Duel.GetMatchingGroup(c55749927.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择自己场上1只「罗兰」怪兽
		local dg=Duel.SelectMatchingCard(tp,c55749927.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,g)
		if dg:GetCount()>0 then
			-- 闪烁显示被选中的「罗兰」怪兽
			Duel.HintSelection(dg)
			-- 成功破坏选中的「罗兰」怪兽
			if Duel.Destroy(dg,REASON_EFFECT)~=0 then
				-- 计算当前自己场上可用的怪兽区域数量（最多为3）
				local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
				-- 再次获取卡组中满足特召条件的怪兽组
				g=Duel.GetMatchingGroup(c55749927.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
				if ft>0 and g:CheckWithSumEqual(Card.GetLevel,9,1,ft) then
					-- 中断当前效果处理，使后续的特殊召唤处理不与破坏同时进行
					Duel.BreakEffect()
					-- 提示玩家选择要特殊召唤的怪兽
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					local sg=g:SelectSubGroup(tp,c55749927.spcheck,false,1,ft)
					if sg then
						local tc=sg:GetFirst()
						-- 遍历选中的要特殊召唤的怪兽
						for tc in aux.Next(sg) do
							-- 尝试将怪兽以表侧守备表示特殊召唤
							if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
								-- 效果无效
								local e1=Effect.CreateEffect(c)
								e1:SetType(EFFECT_TYPE_SINGLE)
								e1:SetCode(EFFECT_DISABLE)
								e1:SetReset(RESET_EVENT+RESETS_STANDARD)
								tc:RegisterEffect(e1)
								-- 效果无效
								local e2=Effect.CreateEffect(c)
								e2:SetType(EFFECT_TYPE_SINGLE)
								e2:SetCode(EFFECT_DISABLE_EFFECT)
								e2:SetValue(RESET_TURN_SET)
								e2:SetReset(RESET_EVENT+RESETS_STANDARD)
								tc:RegisterEffect(e2)
							end
						end
						-- 完成所有怪兽的特殊召唤
						Duel.SpecialSummonComplete()
					end
				end
			end
		end
		-- 这个效果的发动后，直到下次的自己回合的结束时自己不是战士族怪兽不能特殊召唤。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetTargetRange(1,0)
		e3:SetTarget(c55749927.splimit)
		-- 判断当前是否为自己的回合，以确定限制效果的持续时间
		if Duel.GetTurnPlayer()==tp then
			e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		else
			e3:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN)
		end
		-- 注册不能特殊召唤战士族以外怪兽的玩家限制效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 限制只能特殊召唤战士族怪兽
function c55749927.splimit(e,c)
	return not c:IsRace(RACE_WARRIOR)
end
