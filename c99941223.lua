--佚楽の堕天使
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只天使族·暗属性的融合怪兽融合召唤。「堕天使」融合怪兽融合召唤的场合，对方场上的「堕天使」怪兽也能作为融合素材。这个效果特殊召唤的怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 注册卡片的发动效果，处理融合召唤，并限制同名卡每回合只能发动1张
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的手卡·场上·墓地的怪兽作为融合素材除外，把1只天使族·暗属性的融合怪兽融合召唤。「堕天使」融合怪兽融合召唤的场合，对方场上的「堕天使」怪兽也能作为融合素材。这个效果特殊召唤的怪兽的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 筛选手卡·场上可以被除外且不具备效果免疫的卡片过滤函数
function s.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中符合天使族·暗属性融合怪兽且能进行融合召唤的卡片的筛选函数
function s.filter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 设定融合素材检查所需的额外校验逻辑
	aux.FCheckAdditional=s.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置融合素材的额外校验设置
	aux.FCheckAdditional=nil
	return res
end
-- 过滤自己墓地中可作为融合素材且能被除外的怪兽的筛选函数
function s.filter3(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤对方场上表侧表示的「堕天使」怪兽作为融合素材的筛选函数
function s.filter4(c,e)
	return c:IsFaceup() and c:IsSetCard(0xef) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 检查所用材料是否包含对手控制的怪兽，若有则要求融合怪兽必须为「堕天使」怪兽
function s.fcheck(tp,sg,fc)
	return not sg:IsExists(Card.IsControler,1,nil,1-tp) or fc:IsSetCard(0xef)
end
-- 效果发动的目标和可行性检查，判定手卡·场上·墓地以及对方场上的卡是否能融合召唤出符合要求的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取己方手卡·场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取己方墓地中可用的融合素材
		local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil,e)
		-- 获取对方场上符合条件的表侧表示「堕天使」怪兽作为融合素材
		local mg3=Duel.GetMatchingGroup(s.filter4,tp,0,LOCATION_MZONE,nil,e)
		mg1:Merge(mg2)
		mg1:Merge(mg3)
		-- 检查额外卡组是否存在符合融合召唤条件的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取可用于融合的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg4=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在使用连锁素材的情况下检查额外卡组中是否存在能够召唤的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg4,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表明此效果包含从额外卡组进行特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息，表明此效果包含将手卡·场上·墓地中的卡片除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果的处理操作，执行除外素材并融合召唤怪兽，给召唤的怪兽增加1000攻击力
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 在伤害步骤或伤害计算时直接返回，不进行效果处理
	if Duel.GetCurrentPhase()&(PHASE_DAMAGE+PHASE_DAMAGE_CAL)~=0 then return end
	-- 获取己方手卡·场上当前可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取己方墓地当前可用的融合素材
	local mg2=Duel.GetMatchingGroup(s.filter3,tp,LOCATION_GRAVE,0,nil,e)
	-- 获取对方场上当前可用的「堕天使」怪兽作为融合素材
	local mg3=Duel.GetMatchingGroup(s.filter4,tp,0,LOCATION_MZONE,nil,e)
	mg1:Merge(mg2)
	mg1:Merge(mg3)
	-- 获取额外卡组中当前能够进行融合召唤的融合怪兽集合
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg4=nil
	local sg2=nil
	-- 在处理时获取可用于融合的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg4=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取能利用连锁素材召唤的额外卡组融合怪兽集合
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg4,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给当前玩家发送选择要特殊召唤的卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否通过该卡自身的效果（非其他连锁素材效果）来召唤所选融合怪兽
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 设置融合材料的额外校验规则
			aux.FCheckAdditional=s.fcheck
			-- 让当前玩家选择融合召唤所需要的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置融合素材的额外校验设置
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选定的融合素材以表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使前后的处理不视为同时进行
			Duel.BreakEffect()
			-- 以融合召唤的形式将融合怪兽表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让当前玩家为连锁素材效果所要召唤的融合怪兽选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 这个效果特殊召唤的怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:CompleteProcedure()
	end
end
