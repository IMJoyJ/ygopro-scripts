--星霜の魔術師－アストログラフ・マジシャン
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「星霜之魔术师-宙读之魔术士」以外的1只灵摆刻度是1的灵摆怪兽在自己的灵摆区域放置。这个效果放置的卡的灵摆效果在这个回合不能发动。
-- 【怪兽效果】
-- 这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己场上的表侧表示的怪兽卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把那些破坏的怪兽之内1只从自己的额外卡组（表侧）·墓地特殊召唤。
-- ②：自己·对方的主要阶段才能发动。这张卡解放。那之后，可以让自己的额外卡组（表侧）·场上的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 启用灵摆属性与灵摆召唤机制
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「星霜之魔术师-宙读之魔术士」以外的1只灵摆刻度是1的灵摆怪兽在自己的灵摆区域放置。这个效果放置的卡的灵摆效果在这个回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"在灵摆区域放置"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- 注册怪兽破坏的合并延迟事件
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_DESTROYED)
	-- ①：自己场上的表侧表示的怪兽卡被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。那之后，可以把那些破坏的怪兽之内1只从自己的额外卡组（表侧）·墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon1)
	e2:SetTarget(s.sptg1)
	e2:SetOperation(s.spop1)
	c:RegisterEffect(e2)
	-- ②：自己·对方的主要阶段才能发动。这张卡解放。那之后，可以让自己的额外卡组（表侧）·场上的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"融合召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.fspcon)
	e3:SetTarget(s.fsptg)
	e3:SetOperation(s.fspop)
	c:RegisterEffect(e3)
end
-- 过滤手卡·卡组中灵摆刻度是1的非同名灵摆怪兽
function s.pfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and not c:IsCode(id) and c:GetLeftScale()==1
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 灵摆效果的发动检测与操作整理
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 检测手卡和卡组是否存在符合条件的灵摆怪兽
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 设置破坏自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- 灵摆效果的具体处理：破坏自身并将选中的灵摆怪兽在灵摆区域放置
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 若破坏自身失败则不处理后续效果
	if Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要放置在场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择1只符合条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽放置在自己的灵摆区域
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)~=0 then
		-- 这个效果放置的卡的灵摆效果在这个回合不能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 过滤自己场上因战斗·效果破坏的表侧表示怪兽
function s.desfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 触发条件：自己场上的表侧表示怪兽卡被战斗·效果破坏的场合
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end
-- 过滤墓地或额外卡组中可特殊召唤的被破坏怪兽
function s.spfilter1(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not c:IsControler(tp) then return false end
	-- 若怪兽在额外卡组，则必须是表侧表示且自己额外怪兽区域有空位
	if c:IsLocation(LOCATION_EXTRA) then return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 end
	-- 若怪兽在墓地，则需不受墓地限制且主要怪兽区域有空位
	if c:IsLocation(LOCATION_GRAVE) then return aux.NecroValleyFilter()(c) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	return false
end
-- 特殊召唤效果的发动检测与操作整理
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检测主要怪兽区域是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	local desg=eg:Filter(s.desfilter,nil,tp)
	-- 将破坏的怪兽设为当前连锁的目标卡片
	Duel.SetTargetCard(desg)
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的具体处理
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 若特殊召唤自身失败则不处理后续效果
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取关联该连锁且符合特殊召唤条件的破坏怪兽
	local desg=Duel.GetTargetsRelateToChain():Filter(s.spfilter1,nil,e,tp)
	-- 若存在符合条件的被破坏怪兽且玩家选择特殊召唤
	if #desg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把怪兽特殊召唤？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=desg:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 触发条件：自己·对方的主要阶段
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 过滤场上可作为融合素材回到卡组的怪兽
function s.filter0(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组表侧表示的可作为融合素材回到卡组的怪兽
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以用指定素材进行融合召唤的龙族融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动检测与操作整理
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable(REASON_EFFECT) end
	-- 设置解放自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,e:GetHandler(),1,0,0)
end
-- 融合召唤效果的具体处理
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsReleasable(REASON_EFFECT) then return end
	-- 将这张卡解放
	Duel.Release(c,REASON_EFFECT)
	local chkf=tp
	-- 获取玩家可用的场上融合素材并过滤
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
	-- 获取额外卡组表侧表示的融合素材并过滤
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e)
	mg1:Merge(mg2)
	-- 检测额外卡组是否存在可用当前素材融合召唤的龙族融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 检测额外卡组是否存在可用连锁素材效果融合召唤的龙族融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	-- 若有可融合召唤的怪兽且玩家选择进行融合召唤
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否融合召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用自身场上/额外卡组素材进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce~=nil and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合素材
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 给对方确认里侧表示的融合素材
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(s.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(s.cfilter,nil)
				-- 对选中的表侧表示素材显示选择动画
				Duel.HintSelection(cg)
			end
			-- 将融合素材送回卡组并洗切
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 使用连锁素材效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤位于额外卡组或怪兽区域的表侧表示融合素材
function s.cfilter(c)
	return c:IsLocation(LOCATION_EXTRA+LOCATION_MZONE) and c:IsFaceupEx()
end
