--アルトメギア・メセナ－覚醒－
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组把1只「神艺」怪兽或「无垢者 米底乌斯」特殊召唤。这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把卡的效果发动。
-- ②：把墓地的这张卡除外，以自己场上1只「神艺」怪兽为对象才能发动。那只怪兽回到手卡·额外卡组，对方场上1张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果，设置两个效果，①为发动效果，②为墓地发动效果
function s.initial_effect(c)
	-- 记录该卡拥有「无垢者 米底乌斯」的卡名
	aux.AddCodeList(c,97556336)
	-- ①：从卡组把1只「神艺」怪兽或「无垢者 米底乌斯」特殊召唤。这个回合，包含把融合怪兽融合召唤效果的效果由自己发动的场合，那个发动不会被无效化，在那次融合召唤成功时对方不能把卡的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「神艺」怪兽为对象才能发动。那只怪兽回到手卡·额外卡组，对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 发动效果需要把此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「神艺」怪兽或「无垢者 米底乌斯」
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x1cd) or c:IsCode(97556336)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果的发动
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的卡特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- ①效果发动后，使自己发动的融合召唤效果不会被无效化
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_INACTIVATE)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使自己发动的融合召唤效果不会被无效化
	Duel.RegisterEffect(e1,tp)
	-- ①效果发动后，限制对方在融合召唤成功后不能发动卡的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.limcon)
	e2:SetOperation(s.limop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，限制对方在融合召唤成功后不能发动卡的效果
	Duel.RegisterEffect(e2,tp)
	-- ①效果发动后，设置连锁结束时的处理
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetReset(RESET_PHASE+PHASE_END)
	e3:SetOperation(s.limop2)
	-- 注册效果，设置连锁结束时的处理
	Duel.RegisterEffect(e3,tp)
end
-- 判断是否为融合召唤效果
function s.efilter(e,ct)
	local p=e:GetHandlerPlayer()
	-- 获取当前连锁的触发效果和玩家
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 过滤满足条件的融合召唤怪兽
function s.limfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT):IsHasCategory(CATEGORY_FUSION_SUMMON)
end
-- 判断是否有融合召唤成功
function s.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil,tp)
end
-- 处理融合召唤成功后的连锁限制
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁为0时
	if Duel.GetCurrentChain()==0 then
		-- 设置连锁限制
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前连锁为1时
	elseif Duel.GetCurrentChain()==1 then
		-- 注册标识效果
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 注册连锁中处理效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册连锁中处理效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册连锁中处理效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置标识效果
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,id)
	e:Reset()
end
-- 处理连锁结束时的连锁限制
function s.limop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否有标识效果
	if Duel.GetFlagEffect(tp,id)~=0 then
		-- 设置连锁限制
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	-- 重置标识效果
	Duel.ResetFlagEffect(tp,id)
end
-- 连锁限制函数
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤满足条件的「神艺」怪兽
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否满足②效果的发动条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.thfilter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 判断场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在卡
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时要送入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 获取对方场上的卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置效果处理时要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
end
-- 处理②效果的发动
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡是否有效
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND+LOCATION_EXTRA) then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择满足条件的卡
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			-- 显示选卡动画
			Duel.HintSelection(g)
			-- 破坏选中的卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
