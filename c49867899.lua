--刻まれし魔の大聖棺
-- 效果：
-- 包含恶魔族·光属性怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。自己墓地的怪兽作为融合素材回到卡组，把1只恶魔族融合怪兽融合召唤。
-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
-- ●对方不能把装备怪兽作为效果的对象。
local s,id,o=GetID()
-- 初始化效果，设置连接召唤手续并启用复活限制
function s.initial_effect(c)
	-- 添加连接召唤手续，要求使用2只满足条件的怪兽作为素材
	aux.AddLinkProcedure(c,nil,2,2,s.lcheck)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。自己墓地的怪兽作为融合素材回到卡组，把1只恶魔族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以连接怪兽以外的自己场上1只恶魔族·光属性怪兽为对象才能发动。从自己的场上·墓地把这张卡当作持有以下效果的装备魔法卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"装备效果"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 连接召唤条件检查函数，判断是否存在满足条件的怪兽
function s.lcheck(g)
	return g:IsExists(s.mfilter,1,nil)
end
-- 连接召唤条件过滤器，判断是否为恶魔族且光属性
function s.mfilter(c)
	return c:IsLinkRace(RACE_FIEND) and c:IsLinkAttribute(ATTRIBUTE_LIGHT)
end
-- 墓地怪兽过滤器，用于融合召唤时检索可作为素材的怪兽
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 墓地怪兽过滤器，用于融合召唤时检索可作为素材的怪兽（排除受王家长眠之谷影响的怪兽）
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and not c:IsImmuneToEffect(e) and c:IsAbleToDeck()
end
-- 融合怪兽过滤器，判断是否为恶魔族融合怪兽且满足特殊召唤条件
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动条件判定函数，检查是否有符合条件的融合怪兽可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取墓地中的所有怪兽作为融合素材候选
		local mg1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE,0,nil)
		-- 检查是否存在满足融合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在通过连锁获得的融合素材的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示将要特殊召唤一只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息，表示将要将融合素材送入卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 融合召唤效果的处理函数，执行融合召唤过程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取墓地中的所有怪兽（排除受王家长眠之谷影响的怪兽）作为融合素材候选
	local mg1=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	-- 获取满足融合条件的融合怪兽列表
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取通过连锁获得的融合素材的融合怪兽列表
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用普通融合召唤方式
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			if mat1:IsExists(s.fdfilter,1,nil) then
				local cg=mat1:Filter(s.fdfilter,nil)
				-- 确认对方可见的融合素材（翻开面朝下的卡）
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat1:IsExists(s.gdfilter,1,nil) then
				local gg=mat1:Filter(s.gdfilter,nil)
				-- 显示被选为融合素材的卡的动画效果
				Duel.HintSelection(gg)
			end
			-- 将融合素材送入卡组并洗牌
			Duel.SendtoDeck(mat1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续处理视为不同时进行
			Duel.BreakEffect()
			-- 特殊召唤融合怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择通过连锁获得的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 装备怪兽过滤器，判断是否为恶魔族·光属性且非连接怪兽
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsType(TYPE_LINK)
end
-- 装备效果的发动条件判定函数，检查是否有符合条件的装备对象
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) end
	-- 检查场上是否存在可用的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否存在满足装备条件的怪兽
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将要装备一张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置操作信息，表示将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数，执行装备过程
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsControler(tp) then
		-- 检查装备条件是否满足
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or not tc:IsLocation(LOCATION_MZONE) then
			-- 将装备卡送入墓地
			Duel.SendtoGrave(c,REASON_EFFECT)
			return
		end
		-- 尝试进行装备操作
		if not Duel.Equip(tp,c,tc) then return end
		-- 设置装备限制效果，确保只有指定怪兽能装备此卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备后效果，使装备怪兽不能成为对方效果的对象
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 使用辅助函数tgoval设置效果值，防止被对方效果选为对象
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制效果的判断函数，确保只能装备给特定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 融合素材过滤器，判断是否为面朝下的怪兽或手牌中的怪兽
function s.fdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFacedown() or c:IsLocation(LOCATION_HAND)
end
-- 融合素材过滤器，判断是否为面朝上的怪兽或墓地中的怪兽
function s.gdfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
