--プランキッズ・ウェザー
-- 效果：
-- 「调皮宝贝」怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的「调皮宝贝」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ②：对方回合把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
function c44509529.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用2个满足「调皮宝贝」属性的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x120),2,true)
	-- ①：自己的「调皮宝贝」怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(c44509529.actcon)
	c:RegisterEffect(e1)
	-- ②：对方回合把这张卡解放，以融合怪兽以外的自己墓地2只「调皮宝贝」怪兽为对象才能发动（同名卡最多1张）。那些怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44509529,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,44509529)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e2:SetCondition(c44509529.spcon)
	e2:SetCost(c44509529.spcost)
	e2:SetTarget(c44509529.sptg)
	e2:SetOperation(c44509529.spop)
	c:RegisterEffect(e2)
end
-- 判断攻击方是否为「调皮宝贝」怪兽
function c44509529.actcon(e)
	-- 获取当前攻击的怪兽
	local a=Duel.GetAttacker()
	return a and a:IsControler(e:GetHandlerPlayer()) and a:IsSetCard(0x120)
end
-- 判断是否为对方回合
function c44509529.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤满足条件的怪兽，包括场上正面表示或墓地的怪兽，且能作为解放或除外的代价
function c44509529.excostfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(25725326,tp)
end
-- 检查是否满足特殊召唤的条件，包括怪兽区空位和卡名不同数量
function c44509529.costfilter(c,tp,g)
	local tg=g:Clone()
	tg:RemoveCard(c)
	-- 检查怪兽区空位是否大于1且剩余卡组中卡名种类数大于等于2
	return Duel.GetMZoneCount(tp,c)>1 and tg:GetClassCount(Card.GetCode)>=2
end
-- 设置效果发动的费用，包括选择解放或除外的卡
function c44509529.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	-- 获取满足条件的可作为费用的怪兽组
	local g=Duel.GetMatchingGroup(c44509529.excostfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,tp)
	-- 获取满足特殊召唤条件的墓地怪兽组
	local tg=Duel.GetMatchingGroup(c44509529.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if e:GetHandler():IsReleasable() then g:AddCard(e:GetHandler()) end
	if chk==0 then
		e:SetLabel(100)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133) and g:IsExists(c44509529.costfilter,1,nil,tp,tg)
	end
	local cg=g:Filter(c44509529.costfilter,nil,tp,tg)
	local tc
	if #cg>1 then
		-- 提示玩家选择要解放或代替解放除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(25725326,0))  --"请选择要解放或代替解放除外的卡"
		tc=cg:Select(tp,1,1,nil):GetFirst()
	else
		tc=cg:GetFirst()
	end
	local te=tc:IsHasEffect(25725326,tp)
	if te then
		te:UseCountLimit(tp)
		-- 将选中的卡除外作为费用
		Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选中的卡解放作为费用
		Duel.Release(tc,REASON_COST)
	end
end
-- 过滤满足特殊召唤条件的墓地怪兽
function c44509529.spfilter(c,e,tp)
	return c:IsSetCard(0x120) and not c:IsType(TYPE_FUSION)
		and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤的效果目标
function c44509529.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:GetLabel()==100 end
	e:SetLabel(0)
	-- 获取满足特殊召唤条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c44509529.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2只卡名不同的怪兽
	local g1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 设置特殊召唤的目标卡
	Duel.SetTargetCard(g1)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,2,0,0)
end
-- 执行特殊召唤操作并设置效果
function c44509529.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取连锁中目标卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or ft<=0 or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<g:GetCount() then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,ft,ft,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 设置特殊召唤的怪兽在战斗中不会被破坏
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
