--アロマブレンド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从手卡·卡组把「湿润之风」「干渴之风」「恩惠之风」的其中1张在自己的魔法与陷阱区域表侧表示放置。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材除外，把1只植物族融合怪兽融合召唤。自己基本分比对方多的场合，也能把自己墓地的植物族怪兽除外作为融合素材。
local s,id,o=GetID()
-- 注册卡片效果，包括①放置效果和②融合召唤效果
function c25861589.initial_effect(c)
	-- 记录该卡可以检索的卡片代码
	aux.AddCodeList(c,15177750,92266279,28265983)
	-- ①：丢弃1张手卡才能发动。从手卡·卡组把「湿润之风」「干渴之风」「恩惠之风」的其中1张在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材除外，把1只植物族融合怪兽融合召唤。自己基本分比对方多的场合，也能把自己墓地的植物族怪兽除外作为融合素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置效果发动的除外代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- ①效果的发动条件：丢弃1张手卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃手卡操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义可放置的卡片过滤条件
function s.filter(c)
	return c:IsCode(15177750,92266279,28265983) and not c:IsForbidden()
end
-- ①效果的发动条件判断
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家魔法与陷阱区域的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 检查是否满足放置卡片的条件
		return ft>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	end
end
-- ①效果的发动处理
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查魔法与陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡片放置到魔法与陷阱区域
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 定义可作为融合素材的卡片过滤条件
function s.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义墓地中的植物族可作为融合素材的卡片过滤条件
function s.exfilter0(c)
	return c:IsRace(RACE_PLANT) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 定义墓地中的植物族可作为融合素材且未被无效的卡片过滤条件
function s.exfilter1(c,e)
	return c:IsRace(RACE_PLANT) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义可特殊召唤的融合怪兽过滤条件
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PLANT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义融合素材数量限制检查函数
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=10
end
-- 定义融合素材数量限制检查函数
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=10
end
-- ②效果的发动条件判断
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToRemove,nil)
		-- 判断自己基本分是否高于对方
		if Duel.GetLP(tp)>Duel.GetLP(1-tp) then
			-- 获取墓地中的植物族可作为融合素材的卡片组
			local sg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_GRAVE,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置融合素材数量限制检查函数
				aux.FCheckAdditional=s.fcheck
				-- 设置融合素材数量限制检查函数
				aux.GCheckAdditional=s.gcheck
			end
		end
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除融合素材数量限制检查函数
		aux.FCheckAdditional=nil
		-- 清除融合素材数量限制检查函数
		aux.GCheckAdditional=nil
		if not res then
			-- 获取当前连锁中的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的发动处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家当前可用的融合素材并过滤
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local exmat=false
	-- 判断自己基本分是否高于对方
	if Duel.GetLP(tp)>Duel.GetLP(1-tp) then
		-- 获取墓地中的植物族可作为融合素材且未被无效的卡片组
		local sg=Duel.GetMatchingGroup(s.exfilter1,tp,LOCATION_GRAVE,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置融合素材数量限制检查函数
		aux.FCheckAdditional=s.fcheck
		-- 设置融合素材数量限制检查函数
		aux.GCheckAdditional=s.gcheck
	end
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除融合素材数量限制检查函数
	aux.FCheckAdditional=nil
	-- 清除融合素材数量限制检查函数
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁中的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断是否使用墓地融合素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 设置融合素材数量限制检查函数
				aux.FCheckAdditional=s.fcheck
				-- 设置融合素材数量限制检查函数
				aux.GCheckAdditional=s.gcheck
			end
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除融合素材数量限制检查函数
			aux.FCheckAdditional=nil
			-- 清除融合素材数量限制检查函数
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(rg)
			-- 将融合素材除外
			Duel.Remove(mat1+rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
