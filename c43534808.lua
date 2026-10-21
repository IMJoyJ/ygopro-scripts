--トークンコレクター
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，衍生物特殊召唤的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合发动。场上的衍生物全部破坏，这张卡的攻击力上升破坏的衍生物数量×400。
-- ③：只要这张卡在怪兽区域存在，双方不能把衍生物特殊召唤。
function c43534808.initial_effect(c)
	-- 注册卡片在墓地存在的标记检测
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，衍生物特殊召唤的场合才能发动。这张卡特殊召唤。
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
-- 过滤条件：特殊召唤的衍生物
function c43534808.cfilter(c,se)
	return c:IsType(TYPE_TOKEN) and (se==nil or c:GetReasonEffect()~=se)
end
-- 发动条件：场上有衍生物特殊召唤
function c43534808.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c43534808.cfilter,1,nil,se)
end
-- 发动目标：自身在手卡·墓地存在且可以特殊召唤
function c43534808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主要怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身表侧表示特殊召唤
function c43534808.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 发动目标：场上的衍生物全部破坏
function c43534808.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有的衍生物
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	-- 设置操作信息：破坏场上所有的衍生物
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：破坏场上所有衍生物，自身攻击力上升破坏数量×400
function c43534808.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有的衍生物
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_TOKEN)
	-- 破坏所有衍生物并记录破坏数量
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升破坏的衍生物数量×400
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 限制特殊召唤的目标：衍生物
function c43534808.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_TOKEN)
end
