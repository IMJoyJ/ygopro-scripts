--HSRマッハゴー・イータ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。场上的全部表侧表示怪兽的等级直到回合结束时上升1星。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在，自己场上有「疾行机人」调整存在的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
function c21516908.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整，1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：把这张卡解放才能发动。场上的全部表侧表示怪兽的等级直到回合结束时上升1星。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21516908,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c21516908.lvcost)
	e1:SetTarget(c21516908.lvtg)
	e1:SetOperation(c21516908.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「疾行机人」调整存在的场合才能发动。这张卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21516908,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21516908)
	e2:SetCondition(c21516908.spcon)
	e2:SetTarget(c21516908.sptg)
	e2:SetOperation(c21516908.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时的费用支付，需要解放自身
function c21516908.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身从游戏中解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤满足条件的场上表侧表示怪兽（等级大于0）
function c21516908.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果的发动条件判断，检查场上是否存在满足条件的怪兽
function c21516908.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21516908.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
end
-- 效果的处理过程，将场上所有满足条件的怪兽等级上升1星
function c21516908.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c21516908.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为满足条件的怪兽添加等级上升1星的效果，持续到回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 过滤满足条件的场上「疾行机人」调整
function c21516908.hsfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2016) and c:IsType(TYPE_TUNER)
end
-- 效果发动的条件判断，检查自己场上是否存在「疾行机人」调整
function c21516908.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「疾行机人」调整
	return Duel.IsExistingMatchingCard(c21516908.hsfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动条件判断，检查是否有足够的召唤区域并可特殊召唤自身
function c21516908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，确定特殊召唤的目标和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 限制特殊召唤的条件，非风属性怪兽不能特殊召唤
function c21516908.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果的处理过程，将自身特殊召唤并设置风属性限制
function c21516908.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 设置风属性限制效果，使自己不能特殊召唤非风属性怪兽，持续到回合结束
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c21516908.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将风属性限制效果注册到游戏中
	Duel.RegisterEffect(e1,tp)
end
