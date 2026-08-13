--流星輝巧群
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只仪式怪兽仪式召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只「龙辉巧」怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时下降1000，这张卡加入手卡。
function c22398665.initial_effect(c)
	-- ①：攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22398665,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22398665.target)
	e1:SetOperation(c22398665.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只「龙辉巧」怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时下降1000，这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22398665,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22398665)
	e2:SetTarget(c22398665.thtg)
	e2:SetOperation(c22398665.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：选择我方场上表侧表示、属于「龙辉巧」系列且攻击力1000以上的怪兽，作为②效果可选对象。
function c22398665.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154) and c:IsAttackAbove(1000)
end
-- ②效果的发动目标判定函数：确认场上存在符合条件的「龙辉巧」怪兽且自身在墓地可加入手卡，然后选择1只符合条件的怪兽作为对象，并设置将自身加入手卡的操作信息。
function c22398665.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c22398665.cfilter(chkc) end
	-- 发动合法性检查：场上存在1只符合条件的表侧「龙辉巧」怪兽，且这张卡在墓地能够加入手卡。
	if chk==0 then return Duel.IsExistingTarget(c22398665.cfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToHand() end
	-- 弹出选择提示，让玩家选择效果对象（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择1只符合条件的「龙辉巧」怪兽作为效果对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c22398665.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：这张卡将加入持有者手卡，分类为回手牌，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：对象怪兽攻击力下降1000，持续到对方回合结束；若对象未受反转增减效果影响且这张卡仍与效果关联，则将这张卡加入手卡。
function c22398665.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象（选择的那只「龙辉巧」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsAttackAbove(1000) and not tc:IsImmuneToEffect(e) then
		-- 那只怪兽的攻击力直到对方回合结束时下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and c:IsRelateToEffect(e) then
			-- 将这张卡（流星辉巧群）以效果原因加入持有者手卡。
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end
-- ①效果的发动目标判定函数：确认存在可用机械族解放素材，且手卡·墓地存在能通过解放这些素材进行仪式召唤的仪式怪兽；满足时设置特殊召唤的操作信息。
function c22398665.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取可以作为仪式素材的卡组，并筛选出机械族怪兽作为可解放素材。
		local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
		-- 检查手卡·墓地是否存在1只满足条件的仪式怪兽，能够使用机械族素材以“攻击力合计大于等于其攻击力”的方式进行仪式召唤。
		return Duel.IsExistingMatchingCard(c22398665.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,nil,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	end
	-- 设置操作信息：将从手卡·墓地特殊召唤1只仪式怪兽（分类为特殊召唤）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果处理：选择1只仪式怪兽，选择满足攻击力合计要求的机械族解放素材，解放素材后进行仪式召唤。
function c22398665.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 在效果处理时重新获取机械族仪式素材，用于选择解放的组合。
	local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
	-- 提示玩家选择要仪式召唤的怪兽（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件的仪式怪兽（不受王家长眠之谷影响，且可用机械族素材以攻击力合计≥其攻击力的方式仪式召唤）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22398665.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,nil,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的机械族怪兽作为仪式素材（“请选择要解放的卡”）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的素材组合检查函数：用于校验所选素材组的攻击力合计不超过仪式怪兽攻击力的某个约束（针对“大于等于”检索方式，实际上是用于限制额外选择标准，防止过度解放）。
		aux.GCheckAdditional=c22398665.RitualCheckAdditional(tc,tc:GetAttack(),"Greater")
		local mat=mg:SelectSubGroup(tp,c22398665.RitualCheck,true,1,#mg,tp,tc,tc:GetAttack(),"Greater")
		-- 清除额外的素材组合检查函数，避免影响后续选择。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 将选择的素材作为仪式召唤的解放释放（仪式召唤手续）。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果链，使仪式召唤的后续处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选择的怪兽以仪式召唤方式表侧攻击表示特殊召唤到场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 判断素材组攻击力合计是否大于等于仪式怪兽攻击力（用于“攻击力合计直到变成仪式召唤的怪兽的攻击力以上”）。
function c22398665.RitualCheckGreater(g,c,atk)
	if atk==0 then return false end
	-- 将当前检查的素材组设置为已选择卡，供其它检查函数参考。
	Duel.SetSelectedCard(g)
	-- 检查素材组攻击力合计是否大于等于目标攻击力。
	return g:CheckWithSumGreater(aux.GetCappedAttack,atk)
end
-- 判断素材组攻击力合计是否恰好等于仪式怪兽攻击力（备用相等检查，本效果未使用）。
function c22398665.RitualCheckEqual(g,c,atk)
	if atk==0 then return false end
	-- 检查素材组攻击力合计是否恰好等于目标攻击力，用于精确等量解放。
	return g:CheckWithSumEqual(aux.GetCappedAttack,atk,#g,#g)
end
-- 综合检查素材组是否满足：攻击力条件、解放后空余怪兽区足够、且满足怪兽自身素材限制和额外限制。
function c22398665.RitualCheck(g,tp,c,atk,greater_or_equal)
	-- 检查素材组攻击力满足“大于等于/等于”条件，并且解放素材后自己场上有足够怪兽区域容纳仪式召唤。
	return c22398665["RitualCheck"..greater_or_equal](g,c,atk) and Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		-- 追加检查怪兽自身素材组限制和全局额外仪式素材限制。
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
-- 构造额外的素材组检查函数：对于“等于”要求，素材组攻击力合计不能超过仪式怪兽攻击力；对于“大于”要求，在使用额外卡（ec）时需扣除其攻击力后仍不超过目标攻击力。
function c22398665.RitualCheckAdditional(c,atk,greater_or_equal)
	if greater_or_equal=="Equal" then
		return	function(g)
					-- 检查素材组攻击力合计不超过仪式怪兽攻击力（用于等量解放时禁止超量）。
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(aux.GetCappedAttack)<=atk
				end
	else
		return	function(g,ec)
					if atk==0 then return #g<=1 end
					if ec then
						-- 检查在考虑额外卡ec的攻击力后，素材组合计攻击力减去ec的攻击力不超过目标攻击力，以防止重复计算ec导致攻击力溢出。
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(aux.GetCappedAttack)-aux.GetCappedAttack(ec)<=atk
					else
						-- 仅检查全局额外素材限制，不校验具体攻击力（在未指定ec时）。
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
-- 仪式怪兽候选的终极过滤函数：必须是仪式怪兽、满足额外过滤、可被仪式召唤，且存在一组机械族素材能够以攻击力条件完成仪式召唤。
function c22398665.RitualUltimateFilter(c,filter,e,tp,m1,m2,attack_function,greater_or_equal,chk)
	if bit.band(c:GetType(),0x81)~=0x81 or (filter and not filter(c,e,tp,chk)) or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	local mg=m1:Filter(Card.IsCanBeRitualMaterial,c,c)
	if m2 then
		mg:Merge(m2)
	end
	if c.mat_filter then
		mg=mg:Filter(c.mat_filter,c,tp)
	else
		mg:RemoveCard(c)
	end
	local atk=attack_function(c)
	-- 设置针对该候选怪兽的额外素材组合检查函数，用于选择素材时执行攻击力限制。
	aux.GCheckAdditional=c22398665.RitualCheckAdditional(c,atk,greater_or_equal)
	local res=mg:CheckSubGroup(c22398665.RitualCheck,1,#mg,tp,c,atk,greater_or_equal)
	-- 清除额外素材组合检查函数，防止污染后续候选判断。
	aux.GCheckAdditional=nil
	return res
end
