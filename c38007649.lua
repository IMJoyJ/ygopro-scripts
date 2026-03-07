--終刻変転
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「终刻转变」以外的自己的手卡·卡组·场上（表侧表示）1张「终刻」卡破坏。
-- ②：这张卡被效果破坏的场合才能发动。从自己墓地把「终刻转变」以外的1张「终刻」卡加入手卡。那之后，可以从手卡把1只「终刻」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，第一个为发动效果，第二个为被破坏时的诱发效果
function s.initial_effect(c)
	-- ①：「终刻转变」以外的自己的手卡·卡组·场上（表侧表示）1张「终刻」卡破坏。
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
-- 过滤函数，用于筛选满足条件的「终刻」卡（表侧表示且非终刻转变）
function s.desfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1d2)
end
-- 效果处理时检查是否满足条件，即场上是否存在满足条件的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置连锁操作信息，表示将要破坏场上/手牌/卡组的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD)
end
-- 发动效果，选择并破坏满足条件的卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	if g:GetCount()>0 then
		if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
			-- 显示被选中的卡
			Duel.HintSelection(g)
		end
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断该卡是否因效果被破坏
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选满足条件的「终刻」卡（非终刻转变且可加入手牌）
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d2) and c:IsAbleToHand()
end
-- 效果处理时检查是否满足条件，即墓地是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤函数，用于筛选满足条件的「终刻」怪兽（可特殊召唤）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动效果，从墓地选择卡加入手牌，并可特殊召唤手牌中的怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选中的卡
		Duel.HintSelection(g)
		-- 将卡加入手牌并判断是否在手牌中
		if Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
			-- 获取满足条件的可特殊召唤的怪兽
			local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			-- 判断是否满足特殊召唤条件
			if sg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				-- 将选中的怪兽特殊召唤
				Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
