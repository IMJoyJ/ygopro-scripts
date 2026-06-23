--EMトランプ・ガール
-- 效果：
-- ←4 【灵摆】 4→
-- 【怪兽效果】
-- ①：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在灵摆区域被破坏的场合，以自己墓地1只龙族融合怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c42002073.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c42002073.target)
	e2:SetOperation(c42002073.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡在灵摆区域被破坏的场合，以自己墓地1只龙族融合怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCondition(c42002073.spcon)
	e6:SetTarget(c42002073.sptg)
	e6:SetOperation(c42002073.spop)
	c:RegisterEffect(e6)
end
-- 过滤函数，用于筛选场上且未被效果免疫的卡片
function c42002073.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足融合召唤条件的融合怪兽
function c42002073.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 判断是否可以发动效果，检查是否存在满足条件的融合怪兽
function c42002073.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家可用的融合素材，并筛选出在场上的卡片
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查是否存在满足融合召唤条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c42002073.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否存在满足连锁融合素材条件的融合怪兽
				res=Duel.IsExistingMatchingCard(c42002073.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息，指定将要特殊召唤的卡片数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤效果，选择融合怪兽并进行融合召唤
function c42002073.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取玩家可用的融合素材，并筛选出满足条件的卡片
	local mg1=Duel.GetFusionMaterial(tp):Filter(c42002073.filter1,nil,e)
	-- 获取满足融合召唤条件的融合怪兽组
	local sg1=Duel.GetMatchingGroup(c42002073.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足连锁融合素材条件的融合怪兽组
		sg2=Duel.GetMatchingGroup(c42002073.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合召唤所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 判断该卡是否从灵摆区域被破坏
function c42002073.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE)
end
-- 过滤函数，用于筛选龙族融合怪兽
function c42002073.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤目标，检查是否存在满足条件的墓地龙族融合怪兽
function c42002073.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42002073.spfilter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地龙族融合怪兽
		and Duel.IsExistingTarget(c42002073.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中的龙族融合怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c42002073.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，指定将要特殊召唤的卡片数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，将目标怪兽特殊召唤并设置结束阶段破坏效果
function c42002073.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡片是否有效并进行特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(42002073,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 创建结束阶段破坏效果，用于特殊召唤的怪兽在结束阶段被破坏
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c42002073.descon)
		e1:SetOperation(c42002073.desop)
		-- 注册结束阶段破坏效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断结束阶段破坏效果是否触发
function c42002073.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(42002073)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段破坏效果，将目标怪兽破坏
function c42002073.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽以效果原因破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
