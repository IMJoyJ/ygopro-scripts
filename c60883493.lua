--VS 裏螺旋流雪風
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡的暗·地·炎属性怪兽各最多1只给对方观看才能发动。给人观看的怪兽数量的以下效果各适用。
-- ●1只以上：给与对方400伤害。那之后，可以从手卡把1只「征服斗魂」怪兽特殊召唤。
-- ●2只以上：给与对方600伤害。这个回合中，自己场上的「征服斗魂」怪兽不会被效果破坏。
-- ●3只：给与对方800伤害。那之后，可以把场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册这张卡发动的效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把手卡的暗·地·炎属性怪兽各最多1只给对方观看才能发动。给人观看的怪兽数量的以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤手卡中暗、地、炎属性且未给对方确认的怪兽
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_EARTH+ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 执行发动代价：展示手卡中不同属性的暗・地・炎属性怪兽各最多1只，并记录展示的数量
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中可供展示的暗・地·炎属性怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return #g>0 end
	-- 提示玩家选择要展示给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择1到3只属性各不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,1,3)
	-- 将选中的怪兽给对方确认
	Duel.ConfirmCards(1-tp,sg)
	-- 若此卡是「征服斗魂」卡片，则触发手卡展示属性怪兽的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 将手卡洗切
	Duel.ShuffleHand(tp)
	e:SetLabel(#sg)
end
-- 设置效果发动的目标：检查发动代价并设置伤害操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置造成400点伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,400)
end
-- 过滤手卡中可以特殊召唤的「征服斗魂」怪兽
function s.sfilter(c,e,tp)
	return c:IsSetCard(0x195) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行效果处理：根据展示的怪兽数量依次适用各个阶段的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 若展示的怪兽数量在1只以上，则给与对方400点伤害，若对方生命值未归零则继续处理
	if ct>0 and Duel.Damage(1-tp,400,REASON_EFFECT)>0 and Duel.GetLP(1-tp)>0 then
		-- 获取手卡中可以特殊召唤的「征服斗魂」怪兽
		local g=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若自己场上有空余的怪兽区域且手卡有可特殊召唤的怪兽，可选择是否进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从手卡特殊召唤？"
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将选中的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if ct>1 then
		-- 使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 给与对方600点伤害
		Duel.Damage(1-tp,600,REASON_EFFECT)
		-- 如果对方基本分不为0
		if Duel.GetLP(1-tp)>0 then
			-- 这个回合中，自己场上的「征服斗魂」怪兽不会被效果破坏。●3只：给与对方800伤害。那之后，可以把场上的怪兽全部破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetTargetRange(LOCATION_MZONE,0)
			-- 设置不会被效果破坏的卡片为「征服斗魂」怪兽
			e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x195))
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetValue(1)
			-- 注册破坏抗性的全局效果
			Duel.RegisterEffect(e1,tp)
		end
	end
	if ct>2 then
		-- 使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 给与对方800点伤害，若对方生命值未归零则继续处理
		if Duel.Damage(1-tp,800,REASON_EFFECT)>0 and Duel.GetLP(1-tp)>0 then
			-- 获取场上的所有怪兽
			local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
			-- 若场上有怪兽，可选择是否破坏场上的全部怪兽
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把场上的怪兽全部破坏？"
				-- 使之后的效果处理视为不同时处理
				Duel.BreakEffect()
				-- 破坏场上的所有怪兽
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
