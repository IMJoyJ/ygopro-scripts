--Mixousia the Confounder
local s,id,o=GetID()
-- 初始化函数，添加相关效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，条件是魔法师族怪兽和魔法师族以外的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunction(aux.NOT(Card.IsRace),RACE_SPELLCASTER),true)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽变成宣言的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.costg)
	e1:SetOperation(s.cosop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。从自己的场上·墓地把融合素材除外，把1只融合怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.fspcon)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- ③：起动效果，宣言1个属性才能发动。这张卡变成宣言的属性。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.atttg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3)
end
-- 过滤条件：表侧表示且不是全属性的怪兽
function s.cosfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=ATTRIBUTE_ALL
end
-- ①效果目标：以自己场上1只表侧表示怪兽为对象，宣言1个属性
function s.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cosfilter(chkc) end
	-- 检查是否有可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cosfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,s.cosfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言该怪兽没有的1个属性并记录
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- ①效果处理：作为对象的怪兽变成宣言的属性
function s.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只怪兽变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ②效果发动条件：对方的主要阶段
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否是对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 融合素材过滤条件：可以作为融合素材且能被除外的怪兽
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 融合怪兽过滤条件：能被融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- ②效果目标：检查是否可以融合召唤
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取场上的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter1,nil,e)
		-- 获取墓地的融合素材
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否有可以融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 应用连锁素材检查是否有可以融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：包含特殊召唤效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：将融合素材除外并融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取场上的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter1,nil,e)
	-- 获取墓地的融合素材并应用王家长眠之谷过滤
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 获取额外卡组可以融合召唤的怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 应用连锁素材获取额外卡组可以融合召唤的怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是使用正常素材还是连锁素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将素材除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，造成错时点
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材进行融合召唤
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ③效果目标：宣言1个属性
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言1个属性并记录
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置操作信息：包含离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- ③效果处理：这张卡变成宣言的属性
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否在连锁中且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 这张卡变成宣言的属性直到回合结束。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
