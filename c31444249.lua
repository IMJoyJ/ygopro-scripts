--煉獄の虚夢
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的原本等级是2星以上的「狱火机」怪兽等级变成1星，那些怪兽给与对方的战斗伤害变成一半。
-- ②：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「狱火机」融合怪兽融合召唤。从额外卡组特殊召唤的怪兽只有对方场上才存在的场合，自己卡组的怪兽也能有最多6只作为融合素材。
function c31444249.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：自己场上的原本等级是2星以上的「狱火机」怪兽等级变成1星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(1)
	e2:SetTarget(c31444249.lvtg)
	c:RegisterEffect(e2)
	-- 效果原文：那些怪兽给与对方的战斗伤害变成一半
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c31444249.rdtg)
	-- 将效果作用对象受到的战斗伤害改为一半
	e3:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e3)
	-- 效果原文：把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「狱火机」融合怪兽融合召唤
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCost(c31444249.spcost)
	e4:SetTarget(c31444249.sptg)
	e4:SetOperation(c31444249.spop)
	c:RegisterEffect(e4)
end
-- 判断目标怪兽是否为「狱火机」且原本等级大于等于2
function c31444249.lvtg(e,c)
	return c:IsSetCard(0xbb) and c:GetOriginalLevel()>=2
end
-- 判断目标怪兽是否为「狱火机」且原本等级大于等于2
function c31444249.rdtg(e,c)
	return c:IsSetCard(0xbb) and c:GetOriginalLevel()>=2
end
-- 支付将此卡送入墓地的费用
function c31444249.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤出可作为融合素材的怪兽（包括怪兽卡、可作为融合素材、可送入墓地）
function c31444249.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤出未被效果免疫的卡
function c31444249.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤出可融合召唤的「狱火机」融合怪兽（包括类型为融合、种族为狱火机、可特殊召唤、满足融合素材条件）
function c31444249.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xbb) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 检查融合素材中来自卡组的卡数量是否不超过6张
function c31444249.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=6
end
-- 检查融合素材中来自卡组的卡数量是否不超过6张
function c31444249.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK)<=6
end
-- 判断是否满足特殊召唤条件：己方场上没有从额外卡组特殊召唤的怪兽，对方场上存在从额外卡组特殊召唤的怪兽
function c31444249.dmcon(tp)
	-- 己方场上没有从额外卡组特殊召唤的怪兽
	return not Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,LOCATION_MZONE,0,1,nil,LOCATION_EXTRA)
		-- 对方场上存在从额外卡组特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(Card.IsSummonLocation,tp,0,LOCATION_MZONE,1,nil,LOCATION_EXTRA)
end
-- 判断是否满足融合召唤条件：获取融合素材并检查是否有符合条件的融合怪兽
function c31444249.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		if c31444249.dmcon(tp) then
			-- 获取玩家卡组中符合条件的怪兽（可作为融合素材、可送入墓地）
			local sg=Duel.GetMatchingGroup(c31444249.filter0,tp,LOCATION_DECK,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置融合素材检查附加条件为fcheck函数
				aux.FCheckAdditional=c31444249.fcheck
				-- 设置融合素材检查附加条件为gcheck函数
				aux.GCheckAdditional=c31444249.gcheck
			end
		end
		-- 检查是否有符合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c31444249.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除融合素材检查附加条件
		aux.FCheckAdditional=nil
		-- 清除融合素材检查附加条件
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否有符合条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c31444249.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置融合召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理融合召唤效果
function c31444249.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材并过滤掉被免疫的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(c31444249.filter1,nil,e)
	local exmat=false
	if c31444249.dmcon(tp) then
		-- 获取玩家卡组中符合条件的怪兽（可作为融合素材、可送入墓地）
		local sg=Duel.GetMatchingGroup(c31444249.filter0,tp,LOCATION_DECK,0,nil)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置融合素材检查附加条件为fcheck函数
		aux.FCheckAdditional=c31444249.fcheck
		-- 设置融合素材检查附加条件为gcheck函数
		aux.GCheckAdditional=c31444249.gcheck
	end
	-- 获取符合条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(c31444249.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除融合素材检查附加条件
	aux.FCheckAdditional=nil
	-- 清除融合素材检查附加条件
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取符合条件的融合怪兽
		sg2=Duel.GetMatchingGroup(c31444249.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用额外卡组的融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置融合素材检查附加条件为fcheck函数
				aux.FCheckAdditional=c31444249.fcheck
				-- 设置融合素材检查附加条件为gcheck函数
				aux.GCheckAdditional=c31444249.gcheck
			end
			-- 选择融合召唤的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除融合素材检查附加条件
			aux.FCheckAdditional=nil
			-- 清除融合素材检查附加条件
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
