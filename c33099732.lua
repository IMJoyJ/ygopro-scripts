--超未来融合－オーバーフューチャー・フュージョン
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤，不能把那些怪兽效果发动。
-- ●自己墓地的怪兽作为融合素材除外，把1只机械族·暗属性的融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动条件和两个效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 把额外卡组1只融合怪兽给对方观看，那只怪兽有卡名记述的1只融合素材怪兽从卡组送去墓地。这个回合，自己不能把这个效果送去墓地的怪兽以及那些同名怪兽特殊召唤，不能把那些怪兽效果发动。
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
-- 过滤函数，检查额外卡组是否存在满足条件的融合怪兽
function s.filter(c,tp)
	-- 检查额外卡组是否存在满足条件的融合怪兽
	return c:IsType(TYPE_FUSION) and Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤函数，检查卡组是否存在满足条件的融合素材
function s.sfilter(c,tc)
	-- 检查卡组是否存在满足条件的融合素材
	return aux.IsMaterialListCode(tc,c:GetCode()) and c:IsAbleToGrave()
end
-- 效果的处理目标函数，检查是否可以发动效果
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以发动效果
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息，准备将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，选择并确认融合怪兽，然后选择并送去墓地的融合素材
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要确认的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择一只融合怪兽
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	-- 向对方玩家确认该融合怪兽
	Duel.ConfirmCards(1-tp,tc)
	-- 提示玩家选择要送去墓地的融合素材
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择一只融合素材
	local sc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,tc):GetFirst()
	-- 将融合素材送去墓地并设置限制效果
	if Duel.SendtoGrave(sc,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_GRAVE) then
		-- 创建并注册不能特殊召唤的限制效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(sc:GetCode())
		e1:SetTarget(s.slimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能特殊召唤的限制效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetValue(s.alimit)
		-- 注册不能发动效果的限制效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制特殊召唤的过滤函数
function s.slimit(e,c,sp,st,spos,tp,se)
	return c:IsCode(e:GetLabel())
end
-- 限制发动效果的过滤函数
function s.alimit(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetHandler():IsCode(e:GetLabel())
end
-- 过滤函数，检查墓地是否存在可作为融合素材的怪兽
function s.mfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤函数，检查额外卡组是否存在满足条件的融合怪兽
function s.ffilter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的目标函数，检查是否可以发动效果
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取墓地中的可作为融合素材的怪兽组
		local mg1=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE,0,nil)
		-- 检查是否存在满足条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足条件的融合怪兽
				res=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息，准备特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置效果处理信息，准备除外墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 融合召唤效果的处理函数，选择融合怪兽并进行融合召唤
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取受王家长眠之谷影响的墓地可作为融合素材的怪兽组
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.mfilter),tp,LOCATION_GRAVE,0,nil)
	-- 获取满足条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(s.ffilter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2~=nil then sg:Merge(sg2) end
		::cancel::
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc)
			-- 判断是否选择发动连锁效果
			or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat<2 then goto cancel end
			tc:SetMaterial(mat)
			-- 将融合素材除外
			Duel.Remove(mat,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat<2 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
		end
		tc:CompleteProcedure()
	end
end
