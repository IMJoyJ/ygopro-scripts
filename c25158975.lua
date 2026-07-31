--D－HERO デスドグマガイ
local s,id,o=GetID()
-- 初始化卡片效果，注册D-HERO系列字段，设置特殊召唤条件和伤害效果、融合特殊召唤效果
function s.initial_effect(c)
	-- 向卡片注册「D-HERO」系列字段（0xc008）
	aux.AddSetNameMonsterList(c,0xc008)
	c:EnableReviveLimit()
	-- 设置特殊召唤的限制条件：只能通过自身效果特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 设置特殊召唤程序：需要除外3张暗属性或战士族怪兽才能特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e2)
	-- 设置特殊召唤成功时的伤害效果：给对方2000伤害
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	-- 设置速攻融合效果：自己怪兽被效果破坏时可融合召唤暗属性或战士族融合怪兽
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.fspcon)
	e4:SetTarget(s.fsptg)
	e4:SetOperation(s.fspop)
	c:RegisterEffect(e4)
end
-- 定义特殊召唤的费用过滤器：暗属性或战士族且可以除外的怪兽
function s.spfilter(c)
	return (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_WARRIOR)) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤条件判断：有空位且墓地有3张符合条件的卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回特殊召唤条件：场上有空位且墓地存在至少3张暗属性或战士族怪兽
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,3,c)
end
-- 特殊召唤目标函数：让玩家从墓地选择3张符合条件的卡作为除外费用
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取墓地中所有符合条件的怪兽
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,c)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作函数：除外选中的卡并清理对象
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤原因将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 伤害效果触发条件：自身通过特殊召唤方式登场
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 伤害效果注册函数：在准备阶段造成伤害
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建在准备阶段触发的伤害效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetOperation(s.damop2)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY)
	-- 向玩家注册伤害效果
	Duel.RegisterEffect(e1,tp)
end
-- 实际造成伤害的函数：显示卡并造成2000伤害
function s.damop2(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片动画提示
	Duel.Hint(HINT_CARD,0,id)
	-- 给对方玩家造成2000伤害
	Duel.Damage(1-tp,2000,REASON_EFFECT)
end
-- 速攻融合效果触发条件：自己怪兽被对方效果破坏
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 融合素材过滤器：怪兽且不会被无效且可以送入牌组
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 融合怪兽过滤器：暗属性或战士族的融合怪兽且可以特殊召唤
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (c:IsAttribute(ATTRIBUTE_DARK) or c:IsRace(RACE_WARRIOR)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合特殊召唤目标函数：检查是否有可用的融合怪兽和素材
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手牌和场上的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取玩家墓地的融合素材
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否有符合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材检查是否有可融合的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置送牌组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 融合特殊召唤操作函数：选择素材并融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 重新获取融合素材（手牌和场上）
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取墓地的融合素材（受王家长眠之谷影响）
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 从额外卡组筛选符合条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用连锁素材从额外卡组筛选融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是使用普通素材还是连锁素材进行融合
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择普通融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				-- 确认融合素材（对手可见）
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.gdfilter,1,nil) then
				local gg=mat1:Filter(s.gdfilter,nil)
				-- 高亮显示要送入墓地的素材
				Duel.HintSelection(gg)
			end
			-- 将融合素材送入牌组
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前连锁以处理特殊召唤
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家选择连锁素材进行融合
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 正面素材过滤器：场上的里侧表示怪兽或手牌怪兽
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 墓地素材过滤器：场上的表侧表示怪兽或墓地的怪兽
function s.gdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
