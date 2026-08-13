--終刻変転
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「终刻转变」以外的自己的手卡·卡组·场上（表侧表示）1张「终刻」卡破坏。
-- ②：这张卡被效果破坏的场合才能发动。从自己墓地把「终刻转变」以外的1张「终刻」卡加入手卡。那之后，可以从手卡把1只「终刻」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果注册函数：为本卡注册效果①（发动时选自己手卡·卡组·场上的「终刻」卡破坏）和效果②（被效果破坏时从墓地回收「终刻」卡，之后可选择手卡的「终刻」怪兽特殊召唤）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：「终刻转变」以外的自己的手卡·卡组·场上（表侧表示）1张「终刻」卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果破坏的场合才能发动。从自己墓地把「终刻转变」以外的1张「终刻」卡加入手卡。那之后，可以从手卡把1只「终刻」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果的筛选条件：选择「终刻」字段、不是「终刻转变」本身，且是场上表侧表示或位于手牌/卡组的卡（IsFaceupEx满足手卡·卡组及场上表侧）。
function s.desfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1d2)
end
-- ①效果发动时的目标判定与操作信息登记：确认有可破坏的「终刻」卡存在，并通知系统本次效果将破坏1张卡（区域为手卡·卡组·场上）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：自己的手卡·卡组·场上必须存在至少1张符合条件的「终刻」卡（不是本卡且可被破坏），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 登记破坏类操作信息：本次效果破坏1张卡，候选区域为手卡·卡组·场上，目标在效果处理时再确定（targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD)
end
-- ①效果处理：让玩家从手卡·卡组·场上选择1张符合条件的「终刻」卡，若在场上则展示选择，然后将其以效果原因破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己的手卡·卡组·场上的符合条件的「终刻」卡中选择1张（不能选本卡）。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
			-- 对被选中的卡播发选中动画并登记为对象（这里仅当选择到场上卡时使用，使双方明确对象）。
			Duel.HintSelection(g)
		end
		-- 将选择的卡以效果原因破坏（送入墓地）。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡是被卡的效果破坏（不是战斗破坏）的场合才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 回收筛选条件：是「终刻」字段的卡、不是「终刻转变」本身，并且能够加入手卡（不受“不能加入手卡”效果限制）。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d2) and c:IsAbleToHand()
end
-- ②效果发动判定：确认墓地存在可以回收的「终刻」卡，并登记将1张卡从墓地加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动时合法性检查：自己墓地存在至少1张满足回收条件的「终刻」卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 登记回手牌操作信息：效果处理时从墓地选1张「终刻」卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤筛选条件：手牌中的「终刻」字段怪兽，且满足本次效果的特殊召唤条件（可由当前效果正常特殊召唤）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果处理：从墓地选择1张「终刻」卡（避免王家长眠之谷干扰）加入手卡；若加入成功且该卡确实在手牌，则询问玩家是否从手卡特召1只「终刻」怪兽，若是则展示并表侧特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1张满足回收条件且不受王家长眠之谷效果影响的「终刻」卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 展示选中的要加入手牌的卡。
		Duel.HintSelection(g)
		-- 将选中的卡加入持有者手卡；若实际成功加入且该卡目前在手牌，则继续后续特殊召唤处理。
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 获取自己手牌中所有可以特殊召唤的「终刻」怪兽（包括刚回收的那张，若满足条件）。
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			-- 判断存在可特召的怪兽、自己的主要怪兽区有空位，并询问玩家是否进行特殊召唤。
			if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 切断连锁时点，使后续特殊召唤与之前的回收处理在时间上分开处理。
				Duel.BreakEffect()
				-- 弹出选择提示：请选择要特殊召唤的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将选中的「终刻」怪兽以表侧表示特殊召唤到自己场上（检查召唤条件和苏生限制）。
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
