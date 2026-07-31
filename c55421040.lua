--ハンティングホーン
-- 效果：
-- 自己手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性融合怪兽融合召唤，这张卡在战斗阶段发动的场合，可以再选最多有在手卡作为融合素材的数量的对方场上的怪兽，那些攻击力直到回合结束时变成一半。这张卡发动的回合，自己不是战士族·地属性怪兽不能攻击宣言。
-- 「狩猎号角」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡片的效果及全局规则检查
function s.initial_effect(c)
	-- 自己手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性融合怪兽融合召唤。
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
		-- 将全场攻击宣言监听效果注册至全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言检查：若非战士族·地属性怪兽攻击宣言则记录玩家誓约标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not (tc:IsRace(RACE_WARRIOR) and tc:IsAttribute(ATTRIBUTE_EARTH)) then
		-- 为玩家注册本回合已有非指定属性/种族怪兽攻击宣言的标记
		Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 发动Cost及誓约：限制本回合非战士族·地属性怪兽不能攻击
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未曾用非战士族·地属性怪兽进行攻击宣言
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 这张卡发动的回合，自己不是战士族·地属性怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTarget(s.attg)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册限制非战士族·地属性怪兽攻击宣言的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 攻击限制过滤：非战士族或非地属性怪兽
function s.attg(e,c)
	return not (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH))
end
-- 融合素材过滤：不受效果影响以外的战士族怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsRace(RACE_WARRIOR)
end
-- 融合目标过滤：战士族·地属性融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR)
		and c:IsAttribute(ATTRIBUTE_EARTH) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动目标选择：确认是否能进行融合召唤，并在战斗阶段追加改攻分类
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取手卡及场上符合条件的战士族融合素材怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在可融合召唤的战士族·地属性融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在可替代的连锁融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在替代素材下额外卡组是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 判断当前是否处于战斗阶段以追加降低攻击力分类
	if Duel.IsBattlePhase() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	end
	-- 设置效果处理分类为从额外卡组特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 卡片发动效果处理：进行融合召唤，并在战斗阶段可降低对方怪兽攻击力
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取符合素材条件的战士族怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组所有符合条件的战士族·地属性融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取替代素材下符合条件的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 发送选择要特殊召唤卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规手卡·场上素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local ct=mat1:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			-- 将融合素材作为融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，分隔后续的特殊召唤及攻击力变更操作
			Duel.BreakEffect()
			-- 将选中的融合怪兽表侧表示融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			s.atkop(c,tp,ct)
		elseif ce then
			-- 在替代连锁素材下选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local ct=mat2:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			s.atkop(c,tp,ct)
		end
		tc:CompleteProcedure()
	end
end
-- 攻击力减半操作：在战斗阶段可选择最多有手卡素材数量的对方怪兽攻击力减半
function s.atkop(c,tp,ct)
	-- 检查是否在战斗阶段且存在来自手卡作为素材的怪兽数量
	if not Duel.IsBattlePhase() or ct==0 then return end
	-- 询问玩家是否发动对方场上怪兽攻击力减半的效果
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽攻击力变成一半？"
		-- 中断当前效果处理，分隔后续的选卡及降攻操作
		Duel.BreakEffect()
		-- 发送选择表侧表示卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择对方场上最多ct张表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,ct,nil)
		if g:GetCount()>0 then
			-- 显示选定卡片的目标提示动画
			Duel.HintSelection(g)
			-- 遍历所选中的对方怪兽并依次降低攻击力
			for tc in aux.Next(g) do
				-- 这张卡在战斗阶段发动的场合，可以再选最多有在手卡作为融合素材的数量的对方场上的怪兽，那些攻击力直到回合结束时变成一半。
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
