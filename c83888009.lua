--七皇再生
-- 效果：
-- ①：把自己场上的超量怪兽全部解放，以除外的1只自己的超量怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从自己墓地的怪兽以及除外的自己怪兽之中选最多有解放的怪兽数量＋1只的「No.101」～「No.107」其中任意种的「No.」超量怪兽在那只特殊召唤的怪兽下面重叠作为超量素材。这张卡发动的回合的结束阶段，双方各自受到自身手卡数量×300伤害。
function c83888009.initial_effect(c)
	-- ①：把自己场上的超量怪兽全部解放，以除外的1只自己的超量怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以从自己墓地的怪兽以及除外的自己怪兽之中选最多有解放的怪兽数量＋1只的「No.101」～「No.107」其中任意种的「No.」超量怪兽在那只特殊召唤的怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c83888009.cost)
	e1:SetTarget(c83888009.target)
	e1:SetOperation(c83888009.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的超量怪兽（用于解放代价）
function c83888009.costfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 过滤可以被解放且未确定被战斗破坏的怪兽
function c83888009.filter(c)
	return c:IsReleasable() and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价：解放自己场上所有的超量怪兽，并记录解放的数量
function c83888009.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	-- 获取自己场上所有表侧表示的超量怪兽
	local g=Duel.GetMatchingGroup(c83888009.costfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否至少有1只超量怪兽，且全部可以被解放，并且解放后有可用的怪兽区域
	if chk==0 then return g:GetCount()>0 and g:FilterCount(c83888009.filter,nil)==g:GetCount() and Duel.GetMZoneCount(tp,g)>0 end
	e:SetLabel(g:GetCount())
	-- 解放选定的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤除外状态的、可以特殊召唤的表侧表示超量怪兽
function c83888009.spfilter(c,e,tp)
	return c:IsType(TYPE_XYZ) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与效果分类声明（选择除外的1只超量怪兽为对象）
function c83888009.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c83888009.spfilter(chkc,e,tp) end
	if chk==0 then
		if e:GetLabel()==100 then
			e:SetLabel(0)
			-- 检查除外区是否存在可以特殊召唤的超量怪兽作为对象
			return Duel.IsExistingTarget(c83888009.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		else
			return false
		end
	end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择除外的1只超量怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c83888009.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 声明该效果包含特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤对象怪兽，并可选择将特定「No.」超量怪兽重叠作为其超量素材，同时注册回合结束阶段的伤害效果
function c83888009.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取自己墓地及除外区中满足重叠素材条件的「No.」超量怪兽（受王家之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c83888009.ovfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,tc)
	-- 检查对象怪兽是否仍与效果相关，并将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查是否存在可重叠的素材，并询问玩家是否选择重叠超量素材
		and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(83888009,0)) then  --"是否重叠超量素材？"
		-- 中断当前效果处理，使后续的重叠素材处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		local sg=g:Select(tp,1,e:GetLabel()+1,nil)
		-- 将选定的卡重叠在特殊召唤的怪兽下面作为超量素材
		Duel.Overlay(tc,sg)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡发动的回合的结束阶段，双方各自受到自身手卡数量×300伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetOperation(c83888009.damop)
		-- 注册在回合结束阶段触发的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤可以作为超量素材重叠的「No.101」～「No.107」超量怪兽
function c83888009.ovfilter(c)
	-- 获取卡片的「No.」编号
	local no=aux.GetXyzNumber(c)
	return no and no>=101 and no<=107 and c:IsType(TYPE_XYZ) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsCanOverlay()
end
-- 结束阶段伤害效果的具体处理：双方根据各自手卡数量受到伤害
function c83888009.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该效果的卡片（显示卡片发动动画）
	Duel.Hint(HINT_CARD,0,83888009)
	-- 给予回合玩家自身手卡数量×300的伤害
	Duel.Damage(tp,Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)*300,REASON_EFFECT)
	-- 给予对手玩家自身手卡数量×300的伤害
	Duel.Damage(1-tp,Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*300,REASON_EFFECT)
end
