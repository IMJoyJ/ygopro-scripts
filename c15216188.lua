--時の機械－タイム・エンジン
-- 效果：
-- 这个卡名在规则上也当作「金属化」卡使用。
-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，以那之内的1只为对象才能发动。那只怪兽特殊召唤。这个效果把5星以上的机械族怪兽特殊召唤，自己的场上或墓地有这张卡以外的「金属化」陷阱卡存在的场合，可以再让以下效果适用。
-- ●对方场上的怪兽全部破坏。那之后，可以给与对方这个效果特殊召唤的怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 定义并注册本卡的①效果：该效果为陷阱效果，通过自定义合并延迟事件监听自己场上的怪兽被战斗或对方效果破坏，在满足条件时发动，先特殊召唤其中1只怪兽，并根据条件选择是否追加破坏对方全场怪兽和给予伤害。
function s.initial_effect(c)
	-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，以那之内的1只为对象才能发动。那只怪兽特殊召唤。这个效果把5星以上的机械族怪兽特殊召唤，自己的场上或墓地有这张卡以外的「金属化」陷阱卡存在的场合，可以再让以下效果适用。●对方场上的怪兽全部破坏。那之后，可以给与对方这个效果特殊召唤的怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 注册合并延迟事件：监听怪兽被破坏的事件，将同一连锁中多次发生的破坏事件合并为一个自定义事件（EVENT_CUSTOM+id）来触发本卡的①效果，防止同连锁内多次破坏导致效果重复发动。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_DESTROYED)
end
-- 过滤函数：判定被破坏的怪兽是否符合本卡发动条件——破坏前由自己控制、位于主要怪兽区、不是衍生物，且破坏原因是战斗破坏或对方玩家的效果破坏。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and not c:IsType(TYPE_TOKEN)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 发动条件判定：破坏事件组中存在至少1只满足cfilter的己方怪兽，且事件组中不包含这张卡自身（避免这张卡被同时破坏时对触发判定产生干扰）。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 对象过滤器：用于选择对象时，要求目标怪兽能够成为该效果的对象，并且能够被己方以表侧表示特殊召唤（不对召唤条件进行追加检查）。
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 发动时选择对象：从破坏事件组中筛选出所有满足条件且可特殊召唤的怪兽，若有多个则让玩家选择1只，将其设为效果对象，并登记该特殊召唤的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(s.cfilter,nil,tp):Filter(s.tgfilter,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	-- 发动合法性检查：确认己方主要怪兽区有空位，并且存在至少1只可作为对象的候选怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 显示提示文字“请选择效果的对象”，要求玩家从候选怪兽中选择1只作为对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选定的怪兽设置为当前连锁的效果对象，之后效果处理阶段可通过Duel.GetFirstTarget获取该对象。
	Duel.SetTargetCard(g)
	-- 登记操作信息：声明本效果将对1只怪兽进行特殊召唤，供星尘龙、王家长眠之谷等卡片的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 追加效果条件过滤：判定己方场上或墓地是否存在这张卡以外的「金属化」陷阱卡，且该陷阱卡为表侧表示（墓地中的卡视为表侧表示）。
function s.dcfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP)
end
-- 效果处理：若对象仍与效果关联且可特召，则将对象怪兽表侧表示特殊召唤；特召成功后，若该怪兽是5星以上机械族、对方场上有怪兽、己方存在其他「金属化」陷阱卡且玩家同意发动追加效果，则破坏对方场上全部怪兽，之后可选择给予对方该怪兽原本攻击力数值的伤害。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动效果时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果处理前的条件确认：对象怪兽仍与本次效果关联、不受王家长眠之谷的影响，并且己方场上仍有主要怪兽区空位。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 将对象怪兽以表侧表示特殊召唤到己方场上；返回值不等于0表示特殊召唤成功。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsRace(RACE_MACHINE) and tc:IsLevelAbove(5)
			-- 判断对方场上是否存在至少1只怪兽（作为后续能否发动破坏追加效果的依据）。
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 判断自己场上或墓地是否存在这张卡以外的「金属化」陷阱卡（通过s.dcfilter过滤），作为发动追加效果的条件之一。
			and Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,aux.ExceptThisCard(e))
			-- 询问玩家“是否把怪兽破坏？”，决定是否适用追加效果（破坏对方场上全部怪兽）。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
			-- 中断当前效果处理，使后续的破坏处理成为独立的效果处理段，避免与特殊召唤处理共享时点造成错位。
			Duel.BreakEffect()
			-- 取得对方场上的全部怪兽，作为后续要破坏的对象集合。
			local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			-- 若对方场上有怪兽，则以效果将它们全部破坏；返回实际被破坏的怪兽数，非0表示至少破坏了1只。
			if sg:GetCount()>0 and Duel.Destroy(sg,REASON_EFFECT)~=0
				-- 判断特殊召唤的怪兽原本攻击力是否大于0，并询问玩家“是否给予伤害？”，决定是否进一步给予对方伤害。
				and tc:GetBaseAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否给予伤害？"
				-- 再次中断当前效果处理，使后续的伤害处理独立成段。
				Duel.BreakEffect()
				-- 基于特殊召唤的怪兽的原本攻击力数值，给对方玩家造成效果伤害。
				Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
			end
		end
	end
end
