--トークンコレクター
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，衍生物特殊召唤的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合发动。场上的衍生物全部破坏，这张卡的攻击力上升破坏的衍生物数量×400。
-- ③：只要这张卡在怪兽区域存在，双方不能把衍生物特殊召唤。
function c43534808.initial_effect(c)
	-- 注册一个监听卡片送入墓地事件的单次持续效果，用于记录卡片是否已从墓地发动过效果
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡在手卡·墓地存在，衍生物特殊召唤的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43534808,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,43534808)
	e1:SetLabelObject(e0)
	e1:SetCondition(c43534808.spcon)
	e1:SetTarget(c43534808.sptg)
	e1:SetOperation(c43534808.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合发动。场上的衍生物全部破坏，这张卡的攻击力上升破坏的衍生物数量×400。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43534808,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c43534808.destg)
	e2:SetOperation(c43534808.desop)
	c:RegisterEffect(e2)
	-- ③：只要这张卡在怪兽区域存在，双方不能把衍生物特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,1)
	e3:SetTarget(c43534808.sumlimit)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断目标卡是否为衍生物且不是由当前效果触发的召唤
function c43534808.cfilter(c,se)
	return c:IsType(TYPE_TOKEN) and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否有衍生物被特殊召唤，且该召唤不是由当前效果自身触发
function c43534808.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c43534808.cfilter,1,nil,se)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及该卡是否可以被特殊召唤
function c43534808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡以正面表示形式特殊召唤到场上
function c43534808.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置破坏衍生物的效果目标，准备将场上所有衍生物破坏
function c43534808.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有衍生物的卡片组
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 设置操作信息，表示将要破坏场上所有衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏衍生物并提升攻击力的操作，根据破坏的衍生物数量增加攻击力
function c43534808.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有衍生物的卡片组
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 将场上所有衍生物破坏，并返回实际破坏的数量
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 为自身增加攻击力，增加量等于破坏的衍生物数量乘以400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 限制对方不能特殊召唤衍生物
function c43534808.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_TOKEN)
end
