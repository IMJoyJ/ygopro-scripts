--霆王の閃光
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
-- ①：以对方场上1只怪兽为对象才能发动。那只怪兽除外。自己墓地没有陷阱卡存在的场合，再让对方可以从自身手卡把1只怪兽特殊召唤。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把地·水·炎·风属性怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动效果、手卡发动效果，并添加自定义活动计数器。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只怪兽为对象才能发动。那只怪兽除外。自己墓地没有陷阱卡存在的场合，再让对方可以从自身手卡把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 对方把手卡·墓地的怪兽的效果发动的回合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「霆王的闪光」的效果从手卡发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	-- 注册自定义活动计数器，用于检测连锁中是否有卡片发动了效果。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数，用于判定连锁中发动的效果是否不属于“在手卡或墓地发动的怪兽效果”。
function s.chainfilter(re,tp,cid)
	-- 获取当前连锁发生的位置。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 手卡发动效果的允许条件判定函数。
function s.handcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方玩家在本回合内是否发动过符合条件的连锁效果（即手卡或墓地的怪兽效果）。
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- 效果①的发动准备与目标选择函数，若从手卡发动则标记Label为100。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	e:SetLabel(0)
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只可以被除外的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表明此效果包含除外操作，对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 过滤函数，用于判定手卡中的怪兽是否可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理函数，包含除外对象、判定自己墓地无陷阱卡时让对方特殊召唤，以及若从手卡发动则适用后续属性限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于连锁中，则将其表侧表示除外。
	if tc:IsRelateToChain() and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0
		-- 判定自己墓地中是否存在陷阱卡。
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP)
		-- 判定对方场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判定对方手卡中是否存在可以特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
		-- 询问对方玩家是否选择进行特殊召唤。
		and Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤不与除外同时处理。
		Duel.BreakEffect()
		-- 提示对方玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 对方玩家从自身手卡选择1只满足特殊召唤条件的怪兽。
		local g=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_HAND,0,1,1,nil,e,1-tp)
		if #g>0 then
			-- 将对方选择的怪兽表侧表示特殊召唤到对方场上。
			Duel.SpecialSummon(g,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，这次决斗中自己不能把地·水·炎·风属性怪兽的效果发动。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))  --"「霆王的闪光」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 注册该限制效果给发动玩家，使其在决斗中持续适用。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制发动效果的判定函数，阻止玩家发动地、水、炎、风属性怪兽的效果。
function s.aclimit(e,re,tp)
	local c=re:GetHandler()
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_WATER+ATTRIBUTE_FIRE+ATTRIBUTE_WIND) and re:IsActiveType(TYPE_MONSTER)
end
