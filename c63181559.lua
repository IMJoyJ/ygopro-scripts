--トリックスター・ディフュージョン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●自己墓地的怪兽作为融合素材除外，把1只「淘气仙星」融合怪兽融合召唤。
-- ●进行1只「淘气仙星」连接怪兽的连接召唤。
-- ②：把墓地的这张卡除外，以自己场上1只「淘气仙星」怪兽为对象才能发动。这个回合，只要那只怪兽在自己场上表侧表示存在，对方怪兽只能选择作为对象的怪兽作为攻击对象。
local s,id,o=GetID()
-- 注册卡片效果：①发动时选择融合召唤或连接召唤的效果，②墓地除外使对方只能攻击指定怪兽的效果。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「淘气仙星」怪兽为对象才能发动。这个回合，只要那只怪兽在自己场上表侧表示存在，对方怪兽只能选择作为对象的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"强制攻击对象"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+o)
	-- 将墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.csbtg)
	e2:SetOperation(s.csbop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 融合素材过滤条件：自己墓地的怪兽且能被除外。
function s.filter1(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 融合怪兽过滤条件：额外卡组的「淘气仙星」融合怪兽，且能用给定的素材进行融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xfb) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 连接怪兽过滤条件：额外卡组的「淘气仙星」连接怪兽，且当前可以进行连接召唤。
function s.filter(c)
	return c:IsLinkSummonable(nil) and c:IsSetCard(0xfb)
end
-- ①效果的发动准备：检测是否满足融合召唤或连接召唤的条件，并让玩家选择其中一个效果发动，设置对应的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取自己墓地中可用作融合素材的怪兽组。
	local mg1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,tp)
	-- 检查额外卡组是否存在可以使用墓地素材进行融合召唤的「淘气仙星」融合怪兽。
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		-- 获取玩家受到的连锁素材效果（如「连锁物质」）。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 检查在连锁素材效果影响下，是否存在可融合召唤的「淘气仙星」融合怪兽。
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	if chk==0 then
		-- 返回是否至少有一个效果（融合召唤或连接召唤）可以发动。
		return res or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil)
	end
	local op=0
	-- 如果融合召唤和连接召唤两个效果都满足发动条件。
	if res and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil) then
		-- 提示玩家选择要发动的效果。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 让玩家在“融合召唤”和“连接召唤”中选择一个，并将选项序号加1存入变量。
		op=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))+1  --"融合效果/连接召唤"
	elseif res then
		-- 提示玩家选择要发动的效果。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 只能选择“融合召唤”效果，并将选项序号设为1。
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"融合效果"
	else
		-- 提示玩家选择要发动的效果。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
		-- 只能选择“连接召唤”效果，并将选项序号设为2。
		op=Duel.SelectOption(tp,aux.Stringid(id,3))+2  --"连接召唤"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		-- 设置特殊召唤的操作信息：从额外卡组特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
		-- 设置除外的操作信息：从墓地除外卡片。
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤的操作信息：特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	end
end
-- ①效果的处理：根据玩家的选择，执行融合召唤或连接召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		local chkf=tp
		-- 获取自己墓地中可用作融合素材且不受「王家之谷」影响的怪兽组。
		local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,tp)
		-- 获取额外卡组中可以使用墓地素材进行融合召唤的「淘气仙星」融合怪兽组。
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取玩家受到的连锁素材效果。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取在连锁素材效果影响下，可以进行融合召唤的「淘气仙星」融合怪兽组。
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用正常的墓地素材进行融合召唤（若可以使用连锁素材，则询问玩家是否使用连锁素材的效果）。
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家从墓地中选择所选融合怪兽的融合素材。
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选择的融合素材除外。
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果，使后续的特殊召唤处理不与除外同时处理。
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤的方式表侧表示特殊召唤到场上。
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 使用连锁素材效果，让玩家选择对应的融合素材。
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	elseif op==2 then
		-- 提示玩家选择要特殊召唤的连接怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只可以进行连接召唤的「淘气仙星」连接怪兽。
		local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_EXTRA,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的怪兽进行连接召唤。
			Duel.LinkSummon(tp,tc,nil)
		end
	end
end
-- ②效果的对象过滤条件：自己场上表侧表示的「淘气仙星」怪兽。
function s.csbfilter(c)
	return c:IsSetCard(0xfb) and c:IsFaceup()
end
-- ②效果的发动准备：选择自己场上1只表侧表示的「淘气仙星」怪兽作为对象。
function s.csbtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.csbfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的「淘气仙星」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.csbfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「淘气仙星」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.csbfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②效果的处理：给作为对象的怪兽添加效果，使其在表侧表示存在期间，对方怪兽只能选择其作为攻击对象。
function s.csbop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，只要那只怪兽在自己场上表侧表示存在，对方怪兽只能选择作为对象的怪兽作为攻击对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetValue(s.lklimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 攻击目标限制条件：不能选择除该怪兽以外的怪兽作为攻击对象。
function s.lklimit(e,c)
	return c~=e:GetHandler()
end
