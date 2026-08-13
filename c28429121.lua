--リチュアに伝わりし禁断の秘術
-- 效果：
-- 名字带有「遗式」的仪式怪兽的降临必需。必须从自己场上以及对方场上把直到变成和仪式召唤的怪兽相同等级为止的表侧表示存在的怪兽解放。这个效果仪式召唤的怪兽的攻击力变成一半。这张卡发动的回合，自己不能进行战斗阶段。
function c28429121.initial_effect(c)
	-- 卡片效果原文：名字带有「遗式」的仪式怪兽的降临必需。必须从自己场上以及对方场上把直到变成和仪式召唤的怪兽相同等级为止的表侧表示存在的怪兽解放。这个效果仪式召唤的怪兽的攻击力变成一半。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c28429121.cost)
	e1:SetTarget(c28429121.target)
	e1:SetOperation(c28429121.activate)
	c:RegisterEffect(e1)
end
-- 发动代价函数：检查当前阶段并给发动者附加本回合不能进行战斗阶段的誓约效果，以此作为发动这张卡的限制。
function c28429121.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：当前阶段必须不是主要阶段2（若已是主要阶段2则不能发动），以保证“不能进行战斗阶段”的限制确实会在发动后的战斗阶段前生效。
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 卡片效果原文：名字带有「遗式」的仪式怪兽的降临必需。必须从自己场上以及对方场上把直到变成和仪式召唤的怪兽相同等级为止的表侧表示存在的怪兽解放。这个效果仪式召唤的怪兽的攻击力变成一半。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把“不能进行战斗阶段”的誓约效果注册到玩家tp，持续到回合结束阶段，实际执行“这张卡发动的回合，自己不能进行战斗阶段。”
	Duel.RegisterEffect(e1,tp)
end
-- 素材过滤：筛选可解放的表侧表示怪兽，要求等级大于0、不受此效果免疫且能够解放，用于从对方场上选取解放素材。
function c28429121.mfilter(c,e)
	return c:IsFaceup() and c:GetLevel()>0 and not c:IsImmuneToEffect(e) and c:IsReleasable()
end
-- 对象过滤：筛选卡名带有「遗式」字段（0x3a）的仪式怪兽。
function c28429121.filter(c,e,tp)
	return c:IsSetCard(0x3a)
end
-- 发动目标判断：获取可用仪式素材并检查手牌中是否存在能用这些素材进行等级相等仪式召唤的「遗式」仪式怪兽；并设置特殊召唤的操作信息。
function c28429121.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家tp的仪式召唤可用素材（手牌、场上可解放的怪兽以及墓地仪式魔人等）。
		local mg1=Duel.GetRitualMaterial(tp)
		mg1:Remove(Card.IsLocation,nil,LOCATION_HAND)
		-- 获取对方场上的表侧表示解放素材（本卡允许使用对方场上怪兽作为仪式素材）。
		local mg2=Duel.GetMatchingGroup(c28429121.mfilter,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		-- 检查是否存在手牌的「遗式」仪式怪兽，能够以素材等级合计恰好等于其等级的方式完成仪式召唤。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c28429121.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	end
	-- 设置效果处理信息：将进行从手牌特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择要仪式召唤的「遗式」仪式怪兽，从可用素材（含对方场上表侧怪兽）中选择等级合计恰好等于其等级的解放素材，解放后使其攻击力减半并以仪式召唤方式特殊召唤。
function c28429121.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取仪式召唤通常可用素材（手牌、场上、墓地仪式魔人等）。
	local mg1=Duel.GetRitualMaterial(tp)
	mg1:Remove(Card.IsLocation,nil,LOCATION_HAND)
	-- 获取对方场上可作为额外素材的表侧表示怪兽，并入可用素材组。
	local mg2=Duel.GetMatchingGroup(c28429121.mfilter,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只符合条件的「遗式」仪式怪兽作为仪式召唤目标。
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c28429121.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	local tc=tg:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 显示“请选择要解放的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的素材选择规则：要求所选素材的等级合计必须与仪式怪兽的等级相等（不允许多解放）。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 由玩家从可用素材中选择一组等级合计恰好等于仪式怪兽等级的解放素材。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 清除临时素材检查规则，避免影响其他处理。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选择的仪式素材（包括通常素材及对方场上怪兽；墓地素材等按规则除外）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续特殊召唤与之前的解放处理变为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 这个效果仪式召唤的怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		tc:RegisterEffect(e1)
		-- 以仪式召唤方式将选择的怪兽表侧表示特殊召唤到己方场上，并完成仪式召唤手续。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
