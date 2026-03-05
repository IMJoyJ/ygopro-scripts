--時の機械－タイム・エンジン
-- 效果：
-- 这个卡名在规则上也当作「金属化」卡使用。
-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，以那之内的1只为对象才能发动。那只怪兽特殊召唤。这个效果把5星以上的机械族怪兽特殊召唤，自己的场上或墓地有这张卡以外的「金属化」陷阱卡存在的场合，可以再让以下效果适用。
-- ●对方场上的怪兽全部破坏。那之后，可以给与对方这个效果特殊召唤的怪兽的原本攻击力数值的伤害。
local s,id,o=GetID()
-- 注册效果：将此卡设为发动时点，并注册合并延迟事件以处理多个破坏同时触发的情况
function s.initial_effect(c)
	-- ①：自己场上的怪兽被战斗或者对方的效果破坏的场合，以那之内的1只为对象才能发动。那只怪兽特殊召唤。这个效果把5星以上的机械族怪兽特殊召唤，自己的场上或墓地有这张卡以外的「金属化」陷阱卡存在的场合，可以再让以下效果适用。
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
	-- 注册合并延迟事件，用于处理多个破坏事件合并为一次效果触发
	aux.RegisterMergedDelayedEvent(c,id,EVENT_DESTROYED)
end
-- 过滤条件：判断被破坏的怪兽是否为己方控制且位于怪兽区，且不是衍生物，且破坏原因为战斗或对方效果
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and not c:IsType(TYPE_TOKEN)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 条件函数：判断是否有满足条件的怪兽被破坏且不包含此卡本身
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 过滤条件：判断目标怪兽是否可以成为效果对象且可以特殊召唤
function s.tgfilter(c,e,tp)
	return c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 目标选择函数：筛选满足条件的怪兽并设置为效果对象，若有多张则进行选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(s.cfilter,nil,tp):Filter(s.tgfilter,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	-- 检查是否满足发动条件：场上是否有空位且存在可特殊召唤的怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 设置当前连锁的目标卡片
	Duel.SetTargetCard(g)
	-- 设置操作信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 过滤条件：判断是否为表侧表示的金属化陷阱卡
function s.dcfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1ba) and c:IsType(TYPE_TRAP)
end
-- 效果发动函数：处理特殊召唤及后续破坏与伤害效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否有效且未受王家长眠之谷影响且场上存在空位
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 执行特殊召唤操作
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and tc:IsRace(RACE_MACHINE) and tc:IsLevelAbove(5)
			-- 检查己方场上是否存在其他怪兽
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查己方场上或墓地是否存在其他金属化陷阱卡
			and Duel.IsExistingMatchingCard(s.dcfilter,tp,LOCATION_SZONE+LOCATION_GRAVE,0,1,aux.ExceptThisCard(e))
			-- 询问玩家是否发动破坏效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把怪兽破坏？"
			-- 中断当前效果处理，防止错时点
			Duel.BreakEffect()
			-- 获取对方场上的所有怪兽作为破坏对象
			local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
			-- 执行破坏操作并确认是否成功破坏
			if sg:GetCount()>0 and Duel.Destroy(sg,REASON_EFFECT)~=0
				-- 询问玩家是否发动伤害效果
				and tc:GetBaseAttack()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否给予伤害？"
				-- 中断当前效果处理，防止错时点
				Duel.BreakEffect()
				-- 对对方造成伤害，伤害值为特殊召唤怪兽的原本攻击力
				Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
			end
		end
	end
end
