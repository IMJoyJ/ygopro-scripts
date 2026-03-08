--セリオンズ・クロス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「兽带斗神」怪兽存在，对方把怪兽的效果发动时，可以从以下效果选择1个发动（自己墓地有「无尽机关 银星系统」存在的场合，可以选择两方）。
-- ●那个发动的效果无效。
-- ●那只怪兽除外。
function c43270827.initial_effect(c)
	-- 效果原文：这个卡名的卡在1回合只能发动1张。
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
-- 过滤函数，检查场上是否有表侧表示的「兽带斗神」怪兽
function c43270827.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x179)
end
-- 效果条件函数，判断是否满足发动条件：对方怪兽效果发动且自己场上有兽带斗神怪兽
function c43270827.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER)
		-- 检查自己场上是否存在至少1只表侧表示的「兽带斗神」怪兽
		and Duel.IsExistingMatchingCard(c43270827.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，根据连锁效果是否可无效和怪兽是否可除外决定选择选项
function c43270827.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	-- 检查当前连锁的效果是否可以被无效
	local b1=Duel.IsChainDisablable(ev)
	local b2=rc:IsRelateToEffect(re) and rc:IsAbleToRemove() and not rc:IsLocation(LOCATION_REMOVED)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 检查自己墓地是否存在「无尽机关 银星系统」
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,21887075) then
			-- 选择两方效果：使效果无效或除外怪兽
			op=Duel.SelectOption(tp,aux.Stringid(43270827,1),aux.Stringid(43270827,2),aux.Stringid(43270827,3))  --"那个效果无效/那只怪兽除外/选择两方"
		else
			-- 选择一方效果：使效果无效
			op=Duel.SelectOption(tp,aux.Stringid(43270827,1),aux.Stringid(43270827,2))  --"那个效果无效/那只怪兽除外"
		end
	elseif b1 then
		-- 选择一方效果：使效果无效
		op=Duel.SelectOption(tp,aux.Stringid(43270827,1))  --"那个效果无效"
	else
		-- 选择一方效果：除外怪兽
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
			-- 设置操作信息，确定将要除外的怪兽
			Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
		end
	else
		e:SetCategory(CATEGORY_DISABLE)
	end
end
-- 效果处理函数，根据选择的效果执行对应操作
function c43270827.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local res=0
	if op~=1 then
		-- 使当前连锁的效果无效
		Duel.NegateEffect(ev)
	end
	if op~=0 then
		local rc=re:GetHandler()
		if rc:IsRelateToEffect(re) then
			-- 将目标怪兽除外
			Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
		end
	end
end
