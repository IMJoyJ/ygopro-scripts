--セリオンズ・クロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「兽带斗神」怪兽存在，对方把怪兽的效果发动时，可以从以下效果选择1个发动（自己墓地有「无尽机关 银星系统」存在的场合，可以选择两方）。
-- ●那个发动的效果无效。
-- ●那只怪兽除外。
function c43270827.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「兽带斗神」怪兽存在，对方把怪兽的效果发动时，可以从以下效果选择1个发动（自己墓地有「无尽机关 银星系统」存在的场合，可以选择两方）。●那个发动的效果无效。●那只怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43270827,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,43270827+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43270827.condition)
	e1:SetTarget(c43270827.target)
	e1:SetOperation(c43270827.activate)
	c:RegisterEffect(e1)
end
-- 筛选表侧表示且属于「兽带斗神」系列的怪兽，用于后续判断自己场上是否存在符合条件的兽带斗神。
function c43270827.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x179)
end
-- 该卡发动的条件：对方把怪兽效果发动时，且自己场上有表侧表示的「兽带斗神」怪兽存在，此时本卡才能发动。
function c43270827.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上是否存在1张以上满足confilter条件的表侧表示「兽带斗神」怪兽。
		and Duel.IsExistingMatchingCard(c43270827.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时选择处理：根据对方发动的怪兽效果能否被无效、其怪兽能否被除外，以及自己墓地是否存在「无尽机关 银星系统」，让玩家选择要执行的效果（无效/除外/两方），并设定对应的效果分类与操作信息。
function c43270827.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 检查连锁中对方发动的那个怪兽效果是否满足可被无效的条件（即能否被无效化）。
	local b1=Duel.IsChainDisablable(ev)
	local b2=rc:IsRelateToEffect(re) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 检查自己墓地是否存在卡号21887075的「无尽机关 银星系统」，用于决定是否能选择“选择两方”这一选项。
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,21887075) then
			-- 当无效和除外两项都可用，且墓地有「无尽机关 银星系统」时，弹窗让玩家选择「那个效果无效」「那只怪兽除外」「选择两方」之一。
			op=Duel.SelectOption(tp,aux.Stringid(43270827,1),aux.Stringid(43270827,2),aux.Stringid(43270827,3))  --"那个效果无效/那只怪兽除外/选择两方"
		else
			-- 当无效和除外两项都可用，但墓地没有「无尽机关 银星系统」时，弹窗让玩家选择「那个效果无效」或「那只怪兽除外」。
			op=Duel.SelectOption(tp,aux.Stringid(43270827,1),aux.Stringid(43270827,2))  --"那个效果无效/那只怪兽除外"
		end
	elseif b1 then
		-- 当只有“无效”可用时，弹窗让玩家选择「那个效果无效」，选择结果对应op=0（只执行无效）。
		op=Duel.SelectOption(tp,aux.Stringid(43270827,1))  --"那个效果无效"
	else
		-- 当只有“除外”可用时，弹窗让玩家选择「那只怪兽除外」；为与内部标记一致，返回值+1使op=1，表示执行除外。
		op=Duel.SelectOption(tp,aux.Stringid(43270827,2))+1  --"那只怪兽除外"
	end
	e:SetLabel(op)
	if op~=0 then
		if op==1 then
			e:SetCategory(CATEGORY_REMOVE)
		else
			e:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
		end
		if rc:IsRelateToEffect(re) then
			-- 设置操作信息：将对方发动的效果怪兽（eg中的卡）标记为将要被除外（CATEGORY_REMOVE），数量为1。
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
		end
	else
		e:SetCategory(CATEGORY_DISABLE)
	end
end
-- 效果处理阶段：根据之前选择的op执行对应操作——若op≠1则无效对方发动的那只怪兽效果；若op≠0则将该怪兽除外。
function c43270827.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=1 then
		-- 使连锁中对方发动的那个怪兽效果无效化。
		Duel.NegateEffect(ev)
	end
	if op~=0 then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) then
			-- 将发动效果的那只对方怪兽以表侧表示除外。
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
