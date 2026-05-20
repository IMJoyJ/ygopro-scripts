--勇気の天使ヴィクトリカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。从手卡把1只5星以上的光属性怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这个效果特殊召唤的怪兽的攻击力直到回合结束时变成2倍。
-- ②：怪兽区域的这张卡被破坏的场合，从自己墓地把这张卡以外的1只天使族怪兽除外才能发动。和除外的怪兽等级相同的1只天使族怪兽从卡组加入手卡。
function c79928401.initial_effect(c)
	-- ①：这张卡特殊召唤成功的场合才能发动。从手卡把1只5星以上的光属性怪兽特殊召唤，自己失去那只怪兽的原本攻击力数值的基本分。这个效果特殊召唤的怪兽的攻击力直到回合结束时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79928401,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,79928401)
	e1:SetTarget(c79928401.sptg)
	e1:SetOperation(c79928401.spop)
	c:RegisterEffect(e1)
	-- ②：怪兽区域的这张卡被破坏的场合，从自己墓地把这张卡以外的1只天使族怪兽除外才能发动。和除外的怪兽等级相同的1只天使族怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(79928401,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,79928402)
	e2:SetCost(c79928401.thcost)
	e2:SetCondition(c79928401.thcon)
	e2:SetTarget(c79928401.thtg)
	e2:SetOperation(c79928401.thop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的5星以上的光属性怪兽
function c79928401.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果①的发动条件及效果处理检查函数
function c79928401.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足特殊召唤条件的5星以上光属性怪兽
		and Duel.IsExistingMatchingCard(c79928401.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从手卡特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理函数
function c79928401.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c79928401.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		local atk=tc:GetAttack()
		-- 尝试将选中的怪兽以表侧表示特殊召唤
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的攻击力直到回合结束时变成2倍。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(math.ceil(atk*2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 计算自己失去该怪兽原本攻击力数值后的基本分
			local lp=Duel.GetLP(tp)-tc:GetBaseAttack()
			-- 扣除自己相应的基本分
			Duel.SetLP(tp,lp)
		end
		-- 完成特殊召唤的流程
		Duel.SpecialSummonComplete()
	end
end
-- 过滤自己墓地中可以作为Cost除外、且卡组中存在相同等级天使族怪兽的天使族怪兽
function c79928401.cfilter(c,tp)
	return c:IsLevelAbove(1) and c:IsRace(RACE_FAIRY) and c:IsAbleToRemoveAsCost()
		-- 检查卡组中是否存在与该墓地怪兽等级相同的天使族怪兽
		and Duel.IsExistingMatchingCard(c79928401.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetLevel())
end
-- 过滤卡组中与指定等级相同且可以加入手牌的天使族怪兽
function c79928401.thfilter(c,lv)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToHand() and c:IsLevel(lv)
end
-- 效果②的发动代价处理函数，用于在Target中执行Cost
function c79928401.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 效果②的发动条件检查函数，检查这张卡是否在怪兽区域被破坏
function c79928401.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果②的发动条件、发动代价及效果处理检查函数
function c79928401.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己墓地中除这张卡以外满足除外条件的天使族怪兽组
	local cg=Duel.GetMatchingGroup(c79928401.cfilter,tp,LOCATION_GRAVE,0,c,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return cg:GetCount()>0
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:Select(tp,1,1,nil)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 获取刚刚被除外的卡片组
	local og=Duel.GetOperatedGroup()
	local tc=og:GetFirst()
	local lv=tc:GetLevel()
	e:SetLabel(lv)
	-- 设置连锁处理中的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理函数
function c79928401.thop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只与除外怪兽等级相同的天使族怪兽
	local g=Duel.SelectMatchingCard(tp,c79928401.thfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
