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
-- 过滤函数，用于判断是否为场上表侧表示的「龙辉巧」怪兽且攻击力不低于1000。
function c22398665.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154) and c:IsAttackAbove(1000)
end
-- 设置效果处理时的条件判断，检查是否满足选择对象和将此卡加入手卡的条件。
function c22398665.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c22398665.cfilter(chkc) end
	-- 条件判断：检查场上是否存在满足cfilter条件的怪兽，且此卡可以加入手卡。
	if chk==0 then return Duel.IsExistingTarget(c22398665.cfilter,tp,LOCATION_MZONE,0,1,nil) and e:GetHandler():IsAbleToHand() end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足cfilter条件的场上1只怪兽作为效果对象。
	Duel.SelectTarget(tp,c22398665.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示此效果会将此卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理效果的执行函数，对目标怪兽造成攻击力下降1000的效果，并将此卡加入手卡。
function c22398665.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsAttackAbove(1000) and not tc:IsImmuneToEffect(e) then
		-- 创建一个攻击力减少1000的效果并注册到目标怪兽上。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) and c:IsRelateToEffect(e) then
			-- 将此卡以效果原因送入手卡。
			Duel.SendtoHand(c,nil,REASON_EFFECT)
		end
	end
end
-- ①：攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只仪式怪兽仪式召唤。
function c22398665.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家的仪式召唤素材，并筛选出种族为机械族的卡片。
		local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
		-- 检查是否存在满足仪式召唤条件的怪兽。
		return Duel.IsExistingMatchingCard(c22398665.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,nil,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	end
	-- 设置效果处理信息，表示此效果会特殊召唤1只仪式怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①：攻击力合计直到变成仪式召唤的怪兽的攻击力以上为止，把自己的手卡·场上的机械族怪兽解放，从自己的手卡·墓地把1只仪式怪兽仪式召唤。
function c22398665.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家的仪式召唤素材，并筛选出种族为机械族的卡片。
	local mg=Duel.GetRitualMaterialEx(tp):Filter(Card.IsRace,nil,RACE_MACHINE)
	-- 提示玩家选择要特殊召唤的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足仪式召唤条件的1只怪兽。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c22398665.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,nil,e,tp,mg,nil,aux.GetCappedAttack,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式召唤的附加条件。
		aux.GCheckAdditional=c22398665.RitualCheckAdditional(tc,tc:GetAttack(),"Greater")
		local mat=mg:SelectSubGroup(tp,c22398665.RitualCheck,true,1,#mg,tp,tc,tc:GetAttack(),"Greater")
		-- 清除仪式召唤的附加条件。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选中的仪式召唤素材。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，使后续效果视为不同时处理。
		Duel.BreakEffect()
		-- 以仪式召唤方式将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 判断给定的怪兽组中是否存在攻击力总和大于等于指定值的组合。
function c22398665.RitualCheckGreater(g,c,atk)
	if atk==0 then return false end
	-- 设置当前选中的卡片组。
	Duel.SetSelectedCard(g)
	-- 判断给定的怪兽组中是否存在攻击力总和大于等于指定值的组合。
	return g:CheckWithSumGreater(aux.GetCappedAttack,atk)
end
-- 判断给定的怪兽组中是否存在攻击力总和等于指定值的组合。
function c22398665.RitualCheckEqual(g,c,atk)
	if atk==0 then return false end
	-- 判断给定的怪兽组中是否存在攻击力总和等于指定值的组合。
	return g:CheckWithSumEqual(aux.GetCappedAttack,atk,#g,#g)
end
-- 判断给定的怪兽组是否满足仪式召唤的条件。
function c22398665.RitualCheck(g,tp,c,atk,greater_or_equal)
	-- 判断给定的怪兽组是否满足仪式召唤的条件。
	return c22398665["RitualCheck"..greater_or_equal](g,c,atk) and Duel.GetMZoneCount(tp,g,tp)>0 and (not c.mat_group_check or c.mat_group_check(g,tp))
		-- 判断给定的怪兽组是否满足仪式召唤的附加条件。
		and (not aux.RCheckAdditional or aux.RCheckAdditional(tp,g,c))
end
-- 根据指定的条件创建一个用于判断仪式召唤附加条件的过滤函数。
function c22398665.RitualCheckAdditional(c,atk,greater_or_equal)
	if greater_or_equal=="Equal" then
		return	function(g)
					-- 判断给定的怪兽组中攻击力总和是否小于等于指定值。
					return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g)) and g:GetSum(aux.GetCappedAttack)<=atk
				end
	else
		return	function(g,ec)
					if atk==0 then return #g<=1 end
					if ec then
						-- 判断给定的怪兽组中攻击力总和减去目标怪兽攻击力是否小于等于指定值。
						return (not aux.RGCheckAdditional or aux.RGCheckAdditional(g,ec)) and g:GetSum(aux.GetCappedAttack)-aux.GetCappedAttack(ec)<=atk
					else
						-- 判断给定的怪兽组是否满足附加条件。
						return not aux.RGCheckAdditional or aux.RGCheckAdditional(g)
					end
				end
	end
end
-- 判断给定的怪兽是否满足仪式召唤的条件。
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
	-- 设置仪式召唤的附加条件。
	aux.GCheckAdditional=c22398665.RitualCheckAdditional(c,atk,greater_or_equal)
	local res=mg:CheckSubGroup(c22398665.RitualCheck,1,#mg,tp,c,atk,greater_or_equal)
	-- 清除仪式召唤的附加条件。
	aux.GCheckAdditional=nil
	return res
end
