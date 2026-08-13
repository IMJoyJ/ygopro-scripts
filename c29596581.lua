--雷獣龍－サンダー・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：把这张卡从手卡丢弃才能发动。「雷兽龙-雷龙」以外的自己的墓地·除外状态的1张「雷龙」卡加入手卡。
-- ②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷龙」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
function c29596581.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：把这张卡从手卡丢弃才能发动。「雷兽龙-雷龙」以外的自己的墓地·除外状态的1张「雷龙」卡加入手卡。
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
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：这张卡被除外的场合或者从场上送去墓地的场合才能发动。从卡组把1只「雷龙」怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
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
-- ①效果的代价函数：在发动时检查此卡是否在手卡且可以被丢弃，作为发动代价。
function c29596581.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将效果持有者（此卡）从手卡送去墓地，作为①效果的发动代价（丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义①效果的检索对象：位于自己墓地或表侧除外状态的「雷龙」卡，且卡名不是「雷兽龙-雷龙」，并且能够加入手卡。
function c29596581.filter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x11c) and not c:IsCode(29596581) and c:IsAbleToHand()
end
-- ①效果的目标设定：确认自己墓地·除外状态存在符合条件的「雷龙」卡，并设置效果处理时将1张卡加入手卡的操作信息。
function c29596581.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动检查：若自己墓地或表侧除外区域中存在满足filter的「雷龙」卡，则①效果满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c29596581.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 设置操作信息：本效果将把1张卡从自己的墓地或除外状态加入手卡（CATEGORY_TOHAND），用于连锁与发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：提示玩家选择1张符合条件的「雷龙」卡，将其加入手卡，并向对方玩家确认该卡。
function c29596581.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字“请选择要加入手牌的卡”给当前玩家。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己的墓地·除外状态中选择1张满足过滤条件且不受「王家长眠之谷」影响的「雷龙」卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c29596581.filter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的那张卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果中“从场上送去墓地”分支的追加条件：该卡被送去墓地前必须位于场上（排除从手牌或卡组等直接送去墓地的情况）。
function c29596581.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义②效果的特殊召唤对象：卡组中的「雷龙」怪兽，且能够以表侧守备表示特殊召唤。
function c29596581.spfilter(c,e,tp)
	return c:IsSetCard(0x11c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的目标设定：确认自己场上存在空位，且卡组中存在可特殊召唤的「雷龙」怪兽，并设置特殊召唤操作信息。
function c29596581.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查之一：自己场上的主要怪兽区存在可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查之二：自己的卡组中存在能够被特殊召唤的「雷龙」怪兽。
		and Duel.IsExistingMatchingCard(c29596581.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将从卡组特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：确认场上仍有空位后，从卡组选择1只「雷龙」怪兽以表侧守备表示特殊召唤，并为其注册结束阶段回到手卡的效果。
function c29596581.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认场上仍有可用的主要怪兽区空位，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示文字“请选择要特殊召唤的卡”给当前玩家。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的「雷龙」怪兽（不取对象）并取得该卡。
	local tc=Duel.SelectMatchingCard(tp,c29596581.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(29596581,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c29596581.thcon)
		e1:SetOperation(c29596581.thop)
		-- 将结束阶段让特殊召唤怪兽回到手卡的持续效果注册到场上，由tp控制；该效果不入连锁且不受免疫影响。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段回手效果的发动条件：检查特殊召唤的怪兽的标识（fid）是否仍与效果记录的标记一致；若不一致（如已离场或被重置）则取消该效果。
function c29596581.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(29596581)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段回手效果的处理：将标记对应的特殊召唤怪兽送回其持有者的手卡。
function c29596581.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因将特殊召唤时登记的怪兽加入持有者的手卡（完成结束阶段回手）。
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end
