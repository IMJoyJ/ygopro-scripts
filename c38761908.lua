--バージェストマ・ディノミスクス
-- 效果：
-- ①：以场上1张表侧表示卡为对象才能发动。选自己1张手卡丢弃，作为对象的卡除外。
-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c38761908.initial_effect(c)
	-- ①：以场上1张表侧表示卡为对象才能发动。选自己1张手卡丢弃，作为对象的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c38761908.target)
	e1:SetOperation(c38761908.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38761908,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c38761908.spcon)
	e2:SetTarget(c38761908.sptg)
	e2:SetOperation(c38761908.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡是否可以因效果丢弃
function c38761908.filter1(c)
	return c:IsDiscardable(REASON_EFFECT)
end
-- 过滤函数，用于判断场上卡是否可以除外
function c38761908.filter2(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 效果处理时的判定函数，检查是否满足发动条件
function c38761908.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c38761908.filter2(chkc) and chkc~=e:GetHandler() end
	-- 检查玩家手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c38761908.filter1,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查场上是否存在可除外的卡
		and Duel.IsExistingTarget(c38761908.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张卡作为除外对象
	local g=Duel.SelectTarget(tp,c38761908.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置效果处理信息，表示将要除外一张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，执行丢弃手卡并除外目标卡的操作
function c38761908.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 丢弃一张手卡
	if Duel.DiscardHand(tp,c38761908.filter1,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0
		and tc:IsRelateToEffect(e) then
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断是否为陷阱卡发动时的效果
function c38761908.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 特殊召唤效果的处理函数，检查是否满足特殊召唤条件
function c38761908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤此卡
		and Duel.IsPlayerCanSpecialSummonMonster(tp,38761908,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理函数，执行特殊召唤操作
function c38761908.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 检查此卡是否可以特殊召唤
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,38761908,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 此卡特殊召唤后，获得不受怪兽效果影响的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c38761908.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		-- 此卡特殊召唤后，获得从场上离开时除外的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 效果过滤函数，用于判断是否为怪兽效果
function c38761908.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
