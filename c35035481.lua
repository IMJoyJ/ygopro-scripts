--バージェストマ・オレノイデス
-- 效果：
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c35035481.initial_effect(c)
	-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c35035481.target)
	e1:SetOperation(c35035481.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c35035481.spcon)
	e2:SetTarget(c35035481.sptg)
	e2:SetOperation(c35035481.spop)
	c:RegisterEffect(e2)
end
-- 过滤魔法·陷阱卡
function c35035481.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择场上1张魔法·陷阱卡作为对象
function c35035481.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c35035481.filter(chkc) and chkc~=e:GetHandler() end
	-- 判断是否满足选择对象的条件
	if chk==0 then return Duel.IsExistingTarget(c35035481.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c35035481.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理破坏效果
function c35035481.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤的条件
function c35035481.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 判断是否满足特殊召唤的条件
function c35035481.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤此卡
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35035481,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 处理特殊召唤效果
function c35035481.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断是否可以特殊召唤此卡
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,35035481,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 特殊召唤此卡
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 此效果特殊召唤的这张卡不受怪兽的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c35035481.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 从场上离开时移至除外区
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
-- 效果适用对象为怪兽效果
function c35035481.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
