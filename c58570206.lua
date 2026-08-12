--多層融合
-- 效果：
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤（融合素材怪兽必须是3只以上）。对方场上有怪兽存在的场合，也能把最多有那个数量的自己的额外卡组的怪兽除外作为融合素材。那个场合，融合召唤时自己失去那些除外的怪兽的攻击力合计数值的基本分。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义该卡的发动效果
function s.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤（融合素材怪兽必须是3只以上）。对方场上有怪兽存在的场合，也能把最多有那个数量的自己的额外卡组的怪兽除外作为融合素材。那个场合，融合召唤时自己失去那些除外的怪兽的攻击力合计数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.fusion_effect=true
-- 融合素材检查辅助函数，限制从额外卡组选取的融合素材数量不能超过对方场上的怪兽数量
function s.fcheck1(ct)
	return function(tp,sg,fc)
				if ct>0 and sg:FilterCount(Card.IsLocation,nil,LOCATION_EXTRA)>ct then
					return false
				end
				return true
			end
end
-- 融合素材检查辅助函数，限制融合素材怪兽必须是3只以上
function s.fcheck2(tp,sg,fc)
	return sg:GetCount()>=3
end
-- 过滤可以作为融合素材且能被除外的额外卡组怪兽
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤可以进行融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果发动的目标确认与合法性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡和场上不受该效果影响的可用融合素材
		local mg=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 获取对方场上的怪兽数量
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		if ct>0 then
			-- 获取自己额外卡组中满足条件的可用融合素材
			local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_EXTRA,0,nil)
			if mg2:GetCount()>0 then
				mg:Merge(mg2)
			end
		end
		-- 设置融合素材数量限制的额外检查函数
		aux.FCheckAdditional=s.fcheck1(ct)
		-- 设置融合素材必须在3只以上的额外检查函数
		aux.FGoalCheckAdditional=s.fcheck2
		-- 检查是否存在可以使用当前素材进行融合召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg,nil,chkf)
		-- 重置额外融合素材数量检查函数
		aux.FCheckAdditional=nil
		-- 重置额外融合素材个数检查函数
		aux.FGoalCheckAdditional=nil
		if not res then
			-- 检查玩家是否存在连锁素材的效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
end
-- 效果处理的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡和场上不受该效果影响的可用融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 获取对方场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if ct>0 then
		-- 获取自己额外卡组中满足条件的可用融合素材
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_EXTRA,0,nil)
		if mg2:GetCount()>0 then
			mg1:Merge(mg2)
		end
	end
	-- 设置融合素材数量限制的额外检查函数
	aux.FCheckAdditional=s.fcheck1(ct)
	-- 设置融合素材必须在3只以上的额外检查函数
	aux.FGoalCheckAdditional=s.fcheck2
	-- 获取可以使用当前素材进行融合召唤的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 检查玩家是否存在连锁素材的效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	local sg=sg1:Clone()
	if sg2 then sg:Merge(sg2) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tg=sg:Select(tp,1,1,nil)
	local tc=tg:GetFirst()
	if tc then
		-- 判断是否使用本卡的效果进行融合召唤（而非连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 重新设置融合素材数量限制的额外检查函数
			aux.FCheckAdditional=s.fcheck1(ct)
			-- 重新设置融合素材必须在3只以上的额外检查函数
			aux.FGoalCheckAdditional=s.fcheck2
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置额外融合素材数量检查函数
			aux.FCheckAdditional=nil
			-- 重置额外融合素材个数检查函数
			aux.FGoalCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
			mat1:Sub(rg)
			-- 将非额外卡组的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 将来自额外卡组的融合素材除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤与素材处理不视为同时进行
			Duel.BreakEffect()
			-- 尝试将融合怪兽以表侧表示进行融合召唤（分解步骤）
			Duel.SpecialSummonStep(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁素材效果下让玩家选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		local exmat=tc:GetMaterial():Filter(Card.IsPreviousLocation,nil,LOCATION_EXTRA)
		if #exmat>0 then
			local dam=exmat:GetSum(Card.GetAttack)
			-- 获取玩家当前的生命值
			local lp=Duel.GetLP(tp)
			if lp>=dam then
				-- 扣除与除外怪兽攻击力合计数值相等的生命值
				Duel.SetLP(tp,lp-dam)
			else
				-- 若扣除数值大于等于当前生命值，则将生命值归0
				Duel.SetLP(tp,0)
			end
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		tc:CompleteProcedure()
	end
	-- 确保重置额外融合素材数量检查函数
	aux.FCheckAdditional=nil
	-- 确保重置额外融合素材个数检查函数
	aux.FGoalCheckAdditional=nil
end
