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
-- 注册自爆并从卡组/手卡放置刻度1灵摆怪、场上卡被破坏手卡特召并特召被破坏怪兽、以及解放自身融合召唤龙族怪兽的效果
function s.initial_effect(c)
	-- 为怪兽卡片启用并注册灵摆卡特有的双向刻度规程
	aux.EnablePendulumAttribute(c)
	-- ①：自己主要阶段才能发动。这张卡破坏，从手卡·卡组把「星霜之魔术师-宙读之魔术士」以外的1只灵摆刻度是1的灵摆怪兽在自己的灵摆区域放置。这个效果放置的卡的灵摆效果在这一回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"在灵摆区域放置"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ptg)
	e1:SetOperation(s.pop)
	c:RegisterEffect(e1)
	-- 注册用于监听己方场上卡片被破坏并累积在延迟事件中触发特召的延迟事件管理器
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
	-- ②：自己·对方的主要阶段才能发动。这张卡解放。那之后，可以把自己的额外卡组（表侧）·场上的怪兽作为融合素材回到卡组，把1只龙族融合怪兽融合召唤。
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
-- 手卡或卡组中不为此卡名称、且左刻度为1的可放置到灵摆区域的灵摆怪兽 of 过滤条件
function s.pfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and not c:IsCode(id) and c:GetLeftScale()==1
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 灵摆自爆与放置刻度1怪兽效果的发动准备与合法性检查
function s.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable()
		-- 检查手卡或卡组是否存在符合放置条件的刻度1灵摆怪兽
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息为破坏这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,c,1,0,0)
end
-- 自爆并将手卡/卡组的刻度1灵摆怪兽放置到灵摆区且本回合禁发动效果的执行
function s.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将处于灵摆区域的此卡自身破坏
	if Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 向玩家发送提示，请选择需要放置到灵摆区域的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从手卡或卡组选择1只符合条件的灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽放置到己方的灵摆区域，若成功则继续处理
	if tc and Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true) then
		-- 注册使该被放置怪兽在本回合内无法主动发动其灵摆效果的单体限制持续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- 己方场上原本由自己控制的表侧表示怪兽，因战斗或效果被破坏送去墓地或额外卡组时的过滤条件
function s.desfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:GetOriginalType()&TYPE_MONSTER~=0 and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 判断是否触发了己方场上表侧表示怪兽被战斗或效果破坏送墓/额外表侧的时点
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil,tp)
end
-- 被破坏送至墓地或额外卡组中、归自己控制且能够特殊召唤的怪兽的过滤条件
function s.spfilter1(c,e,tp)
	if not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or not c:IsControler(tp) then return false end
	-- 确认怪兽如果处于额外卡组，则其必须呈表侧表示且自己额外怪兽格有空位
	if c:IsLocation(LOCATION_EXTRA) then return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0 end
	-- 确认怪兽如果处于墓地，则自己场上有空闲怪兽格
	if c:IsLocation(LOCATION_GRAVE) then return aux.NecroValleyFilter()(c) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	return false
end
-- 特召自身并特召被破坏怪兽效果的发动准备与合法性检查
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 检查自己场上是否有空余的怪兽区域
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	local desg=eg:Filter(s.desfilter,nil,tp)
	-- 将刚才这批符合被破坏过滤条件的怪兽全数作为本连锁的对象予以注册
	Duel.SetTargetCard(desg)
	-- 设置操作信息为从手卡特殊召唤这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤手卡此卡以及从墓地/额外特召一只刚被破坏的怪兽的效果执行
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将此卡从手卡以表侧表示特殊召唤到场上，若成功则处理后续动作
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 从连锁对象中筛选出符合能够特殊召唤条件的那些被破坏怪兽
	local desg=Duel.GetTargetsRelateToChain():Filter(s.spfilter1,nil,e,tp)
	-- 若有可用对象，询问玩家是否决定特殊召唤其中1只被破坏的怪兽
	if #desg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把怪兽特殊召唤？"
		-- 向玩家发送提示，请选择需要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=desg:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		if tc then
			-- 决定进行特召时，切断效果连锁以执行后续特召
			Duel.BreakEffect()
			-- 将选中的被破坏怪兽表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 限制此解放融合效果只能在自己或对方的主要阶段发动
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前是否确实处于主要阶段
	return Duel.IsMainPhase()
end
-- 自己场上表侧表示存在的、能够返回卡组作融合素材的怪兽的过滤条件
function s.filter0(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 额外卡组中表侧表示存在的、能够返回卡组作融合素材的怪兽的过滤条件
function s.filter1(c,e)
	return c:IsFaceupEx() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
end
-- 额外卡组中属于龙族、可以通过让素材返回卡组进行融合召唤特殊召唤的融合怪兽过滤条件
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 解放自身以进行融合效果的发动准备与合法性检查
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable(REASON_EFFECT) end
	-- 设置操作信息为解放这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,e:GetHandler(),1,0,0)
end
-- 解放此卡、将场上/额外的融合素材返回卡组以及融合召唤龙族怪兽的效果执行
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() or not c:IsReleasable(REASON_EFFECT) then return end
	-- 将场上的此卡自身解放送去墓地
	Duel.Release(c,REASON_EFFECT)
	local chkf=tp
	-- 获取自己场上所有可作为融合素材返回卡组的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter0,nil,e)
	-- 获取额外卡组表侧表示中可作为融合素材返回卡组的怪兽
	local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_EXTRA,0,nil,e)
	mg1:Merge(mg2)
	-- 获取玩家在将上述两个区域的素材合并后，可以融合召唤的龙族融合怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 确认是否能够通过系统融合规则接口进行融合素材匹配
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取系统规则链能够支持召唤的龙族融合怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	-- 确认有至少一侧可以合法融合时，询问玩家是否决定进行融合召唤
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否融合召唤？"
		-- 决定进行融合时，切断效果连锁以执行后续动作
		Duel.BreakEffect()
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家发送提示，请选择需要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 从额外卡组中选择1只符合条件的龙族融合怪兽
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce~=nil and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择由场上或额外表侧素材构成的可返回卡组的融合素材组
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat)
			if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg=mat:Filter(Card.IsFacedown,nil)
				-- 若素材中存在里侧卡片，将其展示给对方玩家确认
				Duel.ConfirmCards(1-tp,cg)
			end
			if mat:Filter(s.cfilter,nil):GetCount()>0 then
				local cg=mat:Filter(s.cfilter,nil)
				-- 高亮显示这些被选作融合素材的场上或额外表侧表示的怪兽
				Duel.HintSelection(cg)
			end
			-- 将这批融合素材怪兽送回持有者的卡组并洗牌
			Duel.SendtoDeck(mat,nil,SEQ_DECKSHUFFLE,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 素材送回卡组后切断连锁以执行后续的融合召唤
			Duel.BreakEffect()
			-- 将选中的龙族融合怪兽以表侧表示当作融合召唤特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 适用外部链融合系统规则以执行其特有的特殊融合流程
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 被选中的怪兽必须属于场上或额外卡组且呈表侧表示的过滤条件
function s.cfilter(c)
	return c:IsLocation(LOCATION_EXTRA+LOCATION_MZONE) and c:IsFaceupEx()
end
