--魔妖変生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
-- ①：丢弃1张手卡，从自己墓地的怪兽以及除外的自己怪兽之中以1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会成为对方的效果的对象。
function c39753577.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,39753577+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c39753577.cost)
	e1:SetTarget(c39753577.target)
	e1:SetOperation(c39753577.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合是否已经进行过特殊召唤操作
	Duel.AddCustomActivityCounter(39753577,ACTIVITY_SPSUMMON,c39753577.counterfilter)
end
-- 计数器过滤函数，若怪兽不是从额外卡组召唤或为魔妖族，则不计入计数
function c39753577.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x121)
end
-- 发动时的处理函数，检查是否为该回合第一次发动且丢弃一张手牌，然后设置不能特殊召唤额外卡组怪兽的效果
function c39753577.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否为该回合第一次发动且手牌中有可丢弃的卡
	if chk==0 then return Duel.GetCustomActivityCount(39753577,tp,ACTIVITY_SPSUMMON)==0 and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃一张手牌作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
	-- ①：丢弃1张手卡，从自己墓地的怪兽以及除外的自己怪兽之中以1只「魔妖」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c39753577.splimit)
	-- 将效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止从额外卡组召唤非魔妖族怪兽
function c39753577.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end
-- 特殊召唤目标怪兽的过滤函数，筛选魔妖族怪兽
function c39753577.spfilter(c,e,tp)
	return c:IsSetCard(0x121) and (c:IsFaceup() or not c:IsLocation(LOCATION_REMOVED)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 选择特殊召唤目标怪兽的处理函数
function c39753577.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and c39753577.spfilter(chkc,e,tp) end
	-- 判断是否有满足条件的怪兽可作为特殊召唤对象
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingTarget(c39753577.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择特殊召唤的目标怪兽
	local g1=Duel.SelectTarget(tp,c39753577.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，记录即将特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g1,1,0,0)
end
-- 发动效果的处理函数，将目标怪兽特殊召唤
function c39753577.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不会成为对方的效果的对象。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		-- 设置效果值，使怪兽不会成为对方的效果对象
		e2:SetValue(aux.tgoval)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
