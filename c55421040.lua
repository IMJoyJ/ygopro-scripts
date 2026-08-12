--ハンティングホーン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用战士族·地属性怪兽不能攻击宣言。
-- ①：自己的手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性的融合怪兽融合召唤。这张卡在战斗阶段发动的场合，可以再选最多有这个效果从手卡作为融合素材的数量的对方场上的怪兽。选的怪兽的攻击力直到战斗阶段结束时变成一半。
local s,id,o=GetID()
-- 初始化卡片效果：注册一个自由时点发动的融合召唤效果（1回合只能发动1张，发动本回合有攻击宣言誓约），并注册全局检测效果用于记录玩家是否用非战士族·地属性怪兽宣言过攻击
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不用战士族·地属性怪兽不能攻击宣言。①：自己的手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性的融合怪兽融合召唤。这张卡在战斗阶段发动的场合，可以再选最多有这个效果从手卡作为融合素材的数量的对方场上的怪兽。选的怪兽的攻击力直到战斗阶段结束时变成一半。
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
		-- 这张卡发动的回合，自己不用战士族·地属性怪兽不能攻击宣言。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(s.checkop)
		-- 把监听攻击宣言的全局检测效果注册到全局环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时检测宣言攻击的怪兽，若不是战士族·地属性怪兽则为其控制者注册标识
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if not (tc:IsRace(RACE_WARRIOR) and tc:IsAttribute(ATTRIBUTE_EARTH)) then
		-- 为该怪兽的控制者注册本回合有效的标识，记录其已用非战士族·地属性怪兽宣言过攻击
		Duel.RegisterFlagEffect(tc:GetControler(),id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 发动代价：确认本回合没有非战士族·地属性怪兽的攻击宣言标识，并注册持续到回合结束的誓约效果，使战士族·地属性以外的怪兽不能攻击宣言
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己本回合是否已有非战士族·地属性怪兽攻击宣言的标识，有则此卡不能发动
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 自己的手卡·场上的战士族怪兽作为融合素材，把1只战士族·地属性的融合怪兽融合召唤。这张卡在战斗阶段发动的场合，可以再选最多有这个效果从手卡作为融合素材的数量的对方场上的怪兽。选的怪兽的攻击力直到战斗阶段结束时变成一半。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTarget(s.attg)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把不能攻击宣言的誓约效果注册给发动玩家，适用到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 誓约效果的适用对象判定：不是战士族·地属性的怪兽不能攻击宣言
function s.attg(e,c)
	return not (c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH))
end
-- 融合素材过滤函数：不受这个效果影响以外的战士族怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsRace(RACE_WARRIOR)
end
-- 融合怪兽过滤函数：可以用给定素材融合召唤的战士族·地属性融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_WARRIOR)
		and c:IsAttribute(ATTRIBUTE_EARTH) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动对象的确认：判断额外卡组是否存在可以用手卡·场上的战士族怪兽（或连锁素材）融合召唤的战士族·地属性融合怪兽；在战斗阶段发动时追加攻击力变化的效果分类，并设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得可作为融合素材的自己手卡·场上的战士族怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在可以用这些素材融合召唤的战士族·地属性融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得自己受到的连锁素材类效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 改用连锁素材效果提供的素材，再次检查是否存在可以融合召唤的战士族·地属性融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 判断当前是否为战斗阶段
	if Duel.IsBattlePhase() then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：选择可以融合召唤的战士族·地属性融合怪兽，选择融合素材送去墓地后将其融合召唤，再按手卡素材数量对对方怪兽适用攻击力减半处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 取得可作为融合素材的自己手卡·场上的战士族怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检索额外卡组中可以用这些素材融合召唤的战士族·地属性融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得自己受到的连锁素材类效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材效果提供的素材检索额外卡组中可以融合召唤的战士族·地属性融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家请选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否走通常素材分支：所选怪兽在通常素材候选范围内，且玩家没有选择改用连锁素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从可用素材中选择融合召唤所用的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			local ct=mat1:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			-- 把融合素材作为融合素材因效果送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，使融合素材送去墓地与融合召唤视为不同时处理
			Duel.BreakEffect()
			-- 把所选的融合怪兽以表侧表示特殊召唤到自己场上（融合召唤）
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			s.atkop(c,tp,ct)
		elseif ce then
			-- 让玩家从连锁素材效果提供的素材中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local ct=mat2:FilterCount(Card.IsLocation,nil,LOCATION_HAND)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
			s.atkop(c,tp,ct)
		end
		tc:CompleteProcedure()
	end
end
-- 战斗阶段发动且使用了手卡素材时，询问玩家是否把对方场上最多那个数量的怪兽的攻击力直到战斗阶段结束时变成一半
function s.atkop(c,tp,ct)
	-- 不在战斗阶段发动或没有从手卡使用融合素材时，不进行攻击力减半的后续处理
	if not Duel.IsBattlePhase() or ct==0 then return end
	-- 对方场上存在表侧表示怪兽时，询问玩家是否把怪兽的攻击力变成一半
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把怪兽攻击力变成一半？"
		-- 中断效果处理，使攻击力减半与之前的处理视为不同时处理
		Duel.BreakEffect()
		-- 提示玩家请选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家选择最多等同于手卡融合素材数量的对方场上的表侧表示怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,ct,nil)
		if g:GetCount()>0 then
			-- 显示所选怪兽被选中的动画并记录这些卡被选为对象
			Duel.HintSelection(g)
			-- 依次遍历所选的每只怪兽
			for tc in aux.Next(g) do
				-- 选的怪兽的攻击力直到战斗阶段结束时变成一半。
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
