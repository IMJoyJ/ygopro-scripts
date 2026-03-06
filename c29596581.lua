--雷獣龍－サンダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡从手卡丢弃才能发动。「雷兽龙-雷龙」以外的自己的墓地·除外状态的1张「雷龙」卡加入手卡。
-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷龙」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
function c29596581.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。「雷兽龙-雷龙」以外的自己的墓地·除外状态的1张「雷龙」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29596581,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,29596581)
	e1:SetCost(c29596581.cost)
	e1:SetTarget(c29596581.target)
	e1:SetOperation(c29596581.operation)
	c:RegisterEffect(e1)
	c29596581.discard_effect=e1
	-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷龙」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29596581,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,29596581)
	e2:SetTarget(c29596581.sptg)
	e2:SetOperation(c29596581.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c29596581.spcon)
	c:RegisterEffect(e3)
end
-- 支付效果代价：将自身从手卡丢弃
function c29596581.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手卡丢弃至墓地作为效果的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤器函数：用于筛选墓地或除外区的「雷龙」卡（排除自身）且能加入手牌的卡片
function c29596581.filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x11c) and not c:IsCode(29596581) and c:IsAbleToHand()
end
-- 效果的发动条件判断：确认场上是否存在满足条件的「雷龙」卡
function c29596581.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：确认场上是否存在满足条件的「雷龙」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c29596581.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置效果处理信息：准备将一张「雷龙」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果处理函数：选择并把符合条件的卡加入手牌
function c29596581.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「雷龙」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29596581.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断该卡是否从场上被送去墓地的条件
function c29596581.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤器函数：用于筛选可以特殊召唤的「雷龙」怪兽
function c29596581.spfilter(c,e,tp)
	return c:IsSetCard(0x11c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动条件判断：确认是否有足够的召唤位置和满足条件的卡
function c29596581.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否场上有满足条件的「雷龙」怪兽
		and Duel.IsExistingMatchingCard(c29596581.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息：准备特殊召唤一只「雷龙」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理函数：选择并特殊召唤一只「雷龙」怪兽
function c29596581.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤的条件：是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「雷龙」怪兽
	local tc=Duel.SelectMatchingCard(tp,c29596581.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(29596581,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 注册一个在结束阶段触发的效果，使特殊召唤的怪兽回到手牌
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c29596581.thcon)
		e1:SetOperation(c29596581.thop)
		-- 将结束阶段回手效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断结束阶段回手效果是否仍然有效
function c29596581.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(29596581)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段触发效果：将特殊召唤的怪兽送回手牌
function c29596581.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回手牌
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
