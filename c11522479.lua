--BK アッパーカッター
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤·特殊召唤的场合才能发动。「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽或1张「反击」反击陷阱卡从卡组加入手卡。
-- ②：这张卡被效果送去墓地的场合，可以从以下效果选择1个发动。
-- ●从自己墓地把「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽特殊召唤。
-- ●从自己墓地把1张「反击」反击陷阱卡在自己场上盖放。
function c11522479.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽或1张「反击」反击陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11522479,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,11522479)
	e1:SetTarget(c11522479.thtg)
	e1:SetOperation(c11522479.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合，可以从以下效果选择1个发动。●从自己墓地把「燃烧拳击手 上勾拳手」以外的1只「燃烧拳击手」怪兽特殊召唤。●从自己墓地把1张「反击」反击陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,11522479)
	e3:SetCondition(c11522479.lgcon)
	e3:SetTarget(c11522479.lgtg)
	e3:SetOperation(c11522479.lgop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「燃烧拳击手」怪兽或「反击」陷阱卡
function c11522479.thfilter(c)
	return (c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and not c:IsCode(11522479)
		or c:IsSetCard(0x199) and c:IsType(TYPE_COUNTER)) and c:IsAbleToHand()
end
-- 判断是否可以发动①效果
function c11522479.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c11522479.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息为检索卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果的处理
function c11522479.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c11522479.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断②效果是否可以发动
function c11522479.lgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤满足条件的「燃烧拳击手」怪兽
function c11522479.spfilter(c,e,tp)
	return c:IsSetCard(0x1084) and c:IsType(TYPE_MONSTER) and not c:IsCode(11522479) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤满足条件的「反击」陷阱卡
function c11522479.setfilter(c)
	return c:IsSetCard(0x199) and c:IsType(TYPE_COUNTER) and c:IsSSetable()
end
-- 判断是否可以发动②效果
function c11522479.lgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c11522479.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查墓地是否存在满足条件的陷阱卡
	local b2=Duel.IsExistingMatchingCard(c11522479.setfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	-- 当两个选项都存在时，让玩家选择其中一个
	if b1 and b2 then op=Duel.SelectOption(tp,aux.Stringid(11522479,1),aux.Stringid(11522479,2))  --"从墓地特殊召唤怪兽"
	-- 当只有特殊召唤选项存在时，选择该选项
	elseif b1 then op=Duel.SelectOption(tp,aux.Stringid(11522479,1))  --"从墓地特殊召唤怪兽"
	-- 当只有盖放选项存在时，选择该选项
	else op=Duel.SelectOption(tp,aux.Stringid(11522479,2))+1 end  --"从墓地盖放反击陷阱"
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置连锁操作信息为特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
		-- 设置连锁操作信息为盖放
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 执行②效果的处理
function c11522479.lgop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 检查场上是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		-- 选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11522479.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 提示玩家选择要盖放的陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		-- 选择满足条件的陷阱卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c11522479.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的陷阱卡盖放
			Duel.SSet(tp,g)
		end
	end
end
