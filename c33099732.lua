--超未来融合－オーバーフューチャー・フュージョン
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤，不能把那些怪兽效果发动。
-- ●自己墓地的怪兽作为融合素材除外，把1只机械族·暗属性的融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册这张卡作为魔法卡可发动的空效果，并注册两个1回合各1次的起动效果：①的从卡组送墓效果和融合召唤效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"把素材送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- 自己墓地的怪兽作为融合素材除外，把1只机械族·暗属性的融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"进行融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.fstg)
	e3:SetOperation(s.fsop)
	c:RegisterEffect(e3)
end
-- 额外卡组融合怪兽的检索过滤：选择额外卡组中满足‘其卡名记述的融合素材怪兽在卡组中存在’的融合怪兽。
function s.filter(c,tp)
	-- 判断额外融合怪兽是否满足：其卡名记述的融合素材怪兽在卡组中存在且可送去墓地。
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 卡组素材的过滤：筛选出指定融合怪兽卡名记述的融合素材，且该素材可以送去墓地。
function s.sfilter(c,tc)
	-- 判断卡组中的怪兽是否为指定融合怪兽的融合素材且能送去墓地。
	return aux.IsMaterialListCode(tc,c:GetCode()) and c:IsAbleToGrave()
end
-- 第一个效果的发动条件检查与操作信息设置：存在符合条件的额外融合怪兽时，将本次操作登记为从卡组送1张卡去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：额外卡组是否存在1只满足s.filter的融合怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 向对方玩家提示己方发动了第一个效果，并显示效果说明。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次将把卡组中的1张卡送去墓地，用于连锁反应检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 第一个效果处理：选择额外融合怪兽给对方确认，从卡组选择其素材送去墓地，并给己方附加不能特殊召唤/不能发效果的限制。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张额外卡组的融合怪兽以向对方确认。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择1只符合条件的融合怪兽（s.filter），并取得第一张。
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	-- 将选择的额外融合怪兽展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,tc)
	-- 提示玩家选择一张卡组中的怪兽送去墓地。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只符合条件的融合素材（满足s.sfilter）。
	local sc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,tc):GetFirst()
	-- 将选择的素材送去墓地；若成功且该卡确实在墓地，则继续附加限制效果。
	if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
		-- 这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤，不能把那些怪兽效果发动。自己墓地的怪兽作为融合素材除外，把1只机械族·暗属性的融合怪兽融合召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(sc:GetCode())
		e1:SetTarget(s.slimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将限制效果e1注册到场上：为己方附加‘不能特殊召唤指定卡名怪兽’的永续效果，直到回合结束。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetValue(s.alimit)
		-- 将限制效果e2注册到场上：为己方附加‘不能发动指定卡名怪兽的效果’的永续效果，直到回合结束。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制效果的判定：当特殊召唤的怪兽卡名与e1记录的素材卡名相同时，禁止该特殊召唤。
function s.slimit(e,c,sp,st,spos,tp,se)
	return c:IsCode(e:GetLabel())
end
-- 限制效果的判定：当要发动的效果来自卡名与e1记录的素材卡名相同的怪兽时，禁止发动。
function s.alimit(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsCode(e:GetLabel())
end
-- 墓地融合素材的过滤：必须是怪兽、可作为融合素材且可以除外。
function s.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 额外融合怪兽的过滤：必须为机械族·暗属性融合怪兽，能够以融合召唤方式特殊召唤，并使用指定素材满足融合条件。
function s.ffilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 第二个效果的发动条件检查：确认墓地存在可除外的融合素材，且额外卡组存在可融合召唤的机械族暗属性融合怪兽；若普通素材不够，尝试使用连锁素材效果。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取墓地中可作为融合素材且可除外的怪兽集合，作为普通融合素材候选。
		local mg1=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查额外卡组是否存在可用墓地素材融合召唤的机械族暗属性融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家拥有的连锁素材效果（若存在则用于代替融合素材）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在存在连锁素材效果的情况下，重新检查额外卡组是否存在可用连锁素材融合召唤的机械族暗属性融合怪兽。
				res=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示己方发动了第二个效果，并显示效果说明。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：本次将进行1只特殊召唤（从额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：本次将除外墓地中的融合素材。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 第二个效果处理：选择额外卡组中符合条件的机械族暗属性融合怪兽，选择融合素材（墓地或连锁素材），素材除外后进行融合召唤。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取墓地中可作为融合素材且可除外的怪兽集合（已考虑王家长眠之谷的影响）。
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mfilter),tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中可用普通墓地素材融合召唤的机械族暗属性融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前玩家拥有的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 在使用连锁素材效果时，获取额外卡组中可用连锁素材融合召唤的机械族暗属性融合怪兽集合。
		sg2=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2~=nil then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家从候选集合中选择1只要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc)
			-- 若所选怪兽也能用普通墓地素材召唤，则询问玩家是否使用连锁素材效果；否则进入普通融合召唤流程。
			or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 不使用连锁素材时，从墓地素材中选择一组融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat<2 then goto cancel end
			tc:SetMaterial(mat)
			-- 将选择的融合素材除外，作为融合召唤素材。
			Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤视为一个独立的处理（避免错过时点）。
			Duel.BreakEffect()
			-- 将选择的融合怪兽以融合召唤方式特殊召唤到己方场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材效果时，从连锁素材提供的素材组中选择融合素材。
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat<2 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
