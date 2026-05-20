--Hunting Horn
-- 效果：
-- 自己手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性融合怪兽融合召唤，这张卡在战斗阶段发动的场合，可以再选最多有在手卡作为融合素材的数量的对方场上的怪兽，那些攻击力直到回合结束时变成一半。这张卡发动的回合，自己不是战士族·地属性怪兽不能攻击宣言。
-- 「狩猎号角」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡片效果，包括卡片发动效果以及用于记录非地属性·战士族怪兽攻击宣言的全局监听效果。
function s.initial_effect(c)
	-- 自己手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性融合怪兽融合召唤，这张卡在战斗阶段发动的场合，可以再选最多有在手卡作为融合素材的数量的对方场上的怪兽，那些攻击力直到回合结束时变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		-- 这张卡发动的回合，自己不是战士族·地属性怪兽不能攻击宣言。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果，用于在决斗中持续检测玩家是否进行了非地属性·战士族怪兽的攻击宣言。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时的全局检测操作：如果攻击宣言的怪兽不是地属性·战士族怪兽，则给该玩家注册一个标识效果，表示本回合已进行过非地属性·战士族的攻击。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not (tc:IsRace(RACE_WARRIOR) and tc:IsAttribute(ATTRIBUTE_EARTH)) then
		-- 给进行攻击宣言的玩家注册一个本回合内有效的标识效果，用于限制「狩猎号角」的发动。
		Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 发动代价与限制处理：检查本回合是否进行过非地属性·战士族怪兽的攻击宣言，并在发动时注册“本回合不能用非地属性·战士族怪兽攻击宣言”的限制。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：如果本回合已经用非地属性·战士族怪兽进行过攻击宣言，则这张卡不能发动。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 这张卡发动的回合，自己不是战士族·地属性怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTarget(s.attg)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动玩家注册“不能用非地属性·战士族怪兽进行攻击宣言”的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制的目标过滤：筛选出所有不是地属性·战士族的怪兽。
function s.attg(e,c)
	return not (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH))
end
-- 融合素材过滤：筛选出不受此卡效果影响且是战士族的怪兽。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsRace(RACE_WARRIOR)
end
-- 融合怪兽过滤：筛选出额外卡组中可以进行融合召唤的地属性·战士族融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR)
		and c:IsAttribute(ATTRIBUTE_EARTH) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动时的目标确认：检查是否存在合法的融合召唤组合，并根据是否在战斗阶段发动来动态调整效果分类（是否包含改变攻击力）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡·场上可用的战士族融合素材。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组中是否存在可以使用当前素材融合召唤的地属性·战士族融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在「连锁素材」等卡片带来的替代融合效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用替代融合效果的素材时，是否存在可融合召唤的合法怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 判断当前是否在战斗阶段。
	if Duel.IsBattlePhase() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：执行融合召唤，若在战斗阶段发动，则追加降低对方怪兽攻击力的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取可用的战士族融合素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中所有可融合召唤的地属性·战士族融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取替代融合效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用替代融合素材时可融合召唤的怪兽。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤（融合召唤）的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若同时满足常规和替代融合，则让玩家选择是否使用替代融合效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local ct=mat1:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			-- 将选定的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓视为同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示特殊召唤（融合召唤）。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			s.atkop(c,tp,ct)
		elseif ce then
			-- 让玩家选择替代融合效果所需的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local ct=mat2:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			s.atkop(c,tp,ct)
		end
		tc:CompleteProcedure()
	end
end
-- 降低攻击力效果处理：若在战斗阶段发动，可选择最多等同于手卡融合素材数量的对方怪兽，使其攻击力减半。
function s.atkop(c,tp,ct)
	-- 检查是否在战斗阶段发动，且手卡融合素材的数量是否大于0，若不满足则不处理后续效果。
	if not Duel.IsBattlePhase() or ct==0 then return end
	-- 检查对方场上是否存在表侧表示怪兽，并询问玩家是否发动降低攻击力的追加效果。
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽攻击力变成一半？"
		-- 中断当前效果处理，使后续的降低攻击力不与融合召唤视为同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择对方场上表侧表示的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择最多等同于手卡融合素材数量的对方场上的表侧表示怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,ct,nil)
		if g:GetCount()>0 then
			-- 选中所选的怪兽并显示选择动画。
			Duel.HintSelection(g)
			-- 遍历选中的怪兽，依次适用降低攻击力的效果。
			for tc in aux.Next(g) do
				-- 那些攻击力直到回合结束时变成一半。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(math.ceil(tc:GetAttack()/2))
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end
