--トークンコレクター
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，衍生物特殊召唤的场合才能发动。这张卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合发动。场上的衍生物全部破坏，这张卡的攻击力上升破坏的衍生物数量×400。
-- ③：只要这张卡在怪兽区域存在，双方不能把衍生物特殊召唤。
function c43534808.initial_effect(c)
	-- 为衍生物收集者注册“已在墓地”的标记检测效果，用于①效果在墓地时能正确判定其存在时机，并防止同一连锁内产生重复判定。
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
-- 过滤条件：被特殊召唤的卡是衍生物，且其特殊召唤的效果原因不是本卡①效果自身引发的情况。
function c43534808.cfilter(c,se)
	return c:IsType(TYPE_TOKEN) and (se==nil or c:GetReasonEffect()~=se)
end
-- ①效果的发动条件：本次特殊召唤成功的衍生物中存在至少一个符合cfilter的衍生物，即存在衍生物被特殊召唤且该特殊召唤不是由本卡①效果自身引发的。
function c43534808.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c43534808.cfilter,1,nil,se)
end
-- ①效果的发动时追加判定：自己主要怪兽区域有空位，且这张卡满足特殊召唤条件，可以被特殊召唤。
function c43534808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在至少1个可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果将把效果持有者自身特殊召唤，数量为1，用于连锁检测和效果发动确认。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与发动的效果关联（没有离场或失去关联），则将其特殊召唤。
function c43534808.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到持有者（tp）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的目标判定：发动无条件满足；随后取得场上所有衍生物，并将其作为破坏对象写入操作信息。
function c43534808.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上所有衍生物组成的集合。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 设置操作信息：本次效果将破坏场上所有衍生物，数量为当前衍生物的总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果实际处理：重新取得场上所有衍生物并全部破坏；若实际破坏数大于0，且这张卡仍表侧表示且与效果关联，则使这张卡的攻击力上升破坏数×400。
function c43534808.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前场上所有衍生物的集合。
	local sg=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_MZONE,LOCATION_MZONE,nil,TYPE_TOKEN)
	-- 以效果原因破坏这些衍生物，并返回实际破坏的数量。
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	if ct>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升破坏的衍生物数量×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③效果的限制判定：对于准备特殊召唤的怪兽，只有当它是衍生物时才适用“不能特殊召唤”的限制。
function c43534808.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsType(TYPE_TOKEN)
end
