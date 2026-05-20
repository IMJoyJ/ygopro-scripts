--HSR／CWライダー
-- 效果：
-- 风属性调整＋调整以外的风属性同调怪兽1只
-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。选最多有出现的数目数量的自己墓地的风属性怪兽回到卡组。那之后，可以选最多有回去数量的对方场上的卡破坏。这张卡的攻击力直到回合结束时上升这个效果破坏的数量×500。
-- ②：对方主要阶段，把同调召唤的这张卡解放才能发动。从额外卡组把最多2只7星风属性同调怪兽特殊召唤（同名卡最多1张）。
function c86154370.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：风属性调整 + 1只调整以外的风属性同调怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND),aux.NonTuner(c86154370.sfilter),1,1)
	-- ①：1回合1次，自己主要阶段才能发动。掷1次骰子。选最多有出现的数目数量的自己墓地的风属性怪兽回到卡组。那之后，可以选最多有回去数量的对方场上的卡破坏。这张卡的攻击力直到回合结束时上升这个效果破坏的数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86154370,0))  --"回卡组并破坏"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DICE+CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c86154370.destg)
	e1:SetOperation(c86154370.desop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，把同调召唤的这张卡解放才能发动。从额外卡组把最多2只7星风属性同调怪兽特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86154370,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c86154370.spcon)
	e2:SetCost(c86154370.spcost)
	e2:SetTarget(c86154370.sptg)
	e2:SetOperation(c86154370.spop)
	c:RegisterEffect(e2)
end
c86154370.material_type=TYPE_SYNCHRO
-- 过滤调整以外的同调素材：风属性且是同调怪兽
function c86154370.sfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)
end
-- 过滤自己墓地中可以回到卡组的风属性怪兽
function c86154370.gyfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToDeck()
end
-- 效果①的发动准备与检测：检查墓地是否存在风属性怪兽，并设置掷骰子和回卡组的操作信息
function c86154370.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只可以回到卡组的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86154370.gyfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置掷骰子的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 设置将墓地的卡送回卡组的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的运行处理：掷骰子，将墓地对应数量的风属性怪兽回到卡组，之后可选择对应数量的对方场上的卡破坏，并根据破坏数量提升自身攻击力
function c86154370.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 掷1次骰子，获取出现的数目
	local dc=Duel.TossDice(tp,1)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择最多有骰子数目数量的自己墓地的风属性怪兽
	local gy=Duel.SelectMatchingCard(tp,c86154370.gyfilter,tp,LOCATION_GRAVE,0,1,dc,nil)
	if #gy==0 then return end
	-- 将选中的怪兽送回卡组并洗牌，返回实际回到卡组的数量
	local yc=Duel.SendtoDeck(gy,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 若有卡片成功回到卡组且对方场上有卡，询问玩家是否选择对方场上的卡破坏
	if yc>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(86154370,2)) then  --"是否选对方的卡破坏？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local dg=g:Select(tp,1,yc,nil)
		-- 显式地在场上框选出被选择破坏的卡
		Duel.HintSelection(dg)
		-- 破坏选中的卡，并返回实际破坏的数量
		local ct=Duel.Destroy(dg,REASON_EFFECT)
		if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的攻击力直到回合结束时上升这个效果破坏的数量×500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
-- 效果②的发动条件：对方主要阶段，且这张卡是同调召唤的
function c86154370.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否为同调召唤，且当前不是自己的回合（即对方回合）
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and Duel.GetTurnPlayer()~=tp
		-- 检查当前阶段是否为主要阶段1或主要阶段2
		and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果②的发动代价：将这张卡解放
function c86154370.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤可以特殊召唤的怪兽：额外卡组的7星风属性同调怪兽，且能被特殊召唤，并且额外卡组特召区域有空位
function c86154370.spfilter(c,e,tp,mc)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
		-- 检查在解放自身后，额外卡组是否有可用的怪兽区域来特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果②的发动准备与检测：检查额外卡组是否存在符合条件的怪兽，并设置特殊召唤的操作信息
function c86154370.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只符合条件的7星风属性同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86154370.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,e:GetHandler()) end
	-- 设置从额外卡组特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤额外卡组中表侧表示的灵摆怪兽
function c86154370.exfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 检查选择的怪兽组合是否合法：卡名各不相同，且数量不超过额外怪兽区域的限制，且灵摆怪兽的数量不超过灵摆特召的区域限制
function c86154370.gcheck(g,ft1,ft2)
	-- 检查所选怪兽卡名是否各不相同，且总数量不超过额外卡组特召的可用区域数
	return aux.dncheck(g) and #g<=ft1
		and g:FilterCount(c86154370.exfilter,nil)<=ft2
end
-- 效果②的运行处理：计算可用区域，考虑特殊限制（如青眼精灵龙），从额外卡组选择最多2只卡名不同的7星风属性同调怪兽特殊召唤
function c86154370.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算从额外卡组特殊召唤同调怪兽的可用区域数量
	local ft=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_SYNCHRO)
	-- 考虑特定卡片效果（如某些限制特召数量的卡）对特召数量的额外限制
	local ect=(c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]) or ft
	local ct=math.min(ft,ect,2)
	if ct<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 计算从额外卡组特殊召唤表侧表示灵摆怪兽的可用区域数量
	local ft2=Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_PENDULUM)
	-- 获取额外卡组中所有符合条件的7星风属性同调怪兽
	local g=Duel.GetMatchingGroup(c86154370.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c86154370.gcheck,false,1,2,ct,ft2)
	if sg then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
