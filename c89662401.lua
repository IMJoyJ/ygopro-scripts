--転生炎獣フォウル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有「转生炎兽 孔雀」以外的「转生炎兽」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「转生炎兽」卡送去墓地，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。这个回合，那张盖放的魔法·陷阱卡不能发动。
function c89662401.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有「转生炎兽 孔雀」以外的「转生炎兽」怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89662401,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,89662401)
	e1:SetCondition(c89662401.spcon)
	e1:SetTarget(c89662401.sptg)
	e1:SetOperation(c89662401.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：从手卡以及自己场上的表侧表示的卡之中把1张「转生炎兽」卡送去墓地，以对方场上盖放的1张魔法·陷阱卡为对象才能发动。这个回合，那张盖放的魔法·陷阱卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89662401,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c89662401.actcost)
	e3:SetTarget(c89662401.acttg)
	e3:SetOperation(c89662401.actop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「转生炎兽 孔雀」以外的「转生炎兽」怪兽
function c89662401.spfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x119) and not c:IsCode(89662401)
end
-- 检查召唤·特殊召唤成功的怪兽中是否存在满足过滤条件的怪兽
function c89662401.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c89662401.spfilter,1,nil,tp)
end
-- ①效果的发动准备与效果分类设置
function c89662401.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理（将自身特殊召唤）
function c89662401.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡或自己场上表侧表示的、可以送去墓地作为代价的「转生炎兽」卡
function c89662401.costfilter(c)
	return c:IsSetCard(0x119) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- ②效果的代价处理（将手卡或场上表侧表示的1张「转生炎兽」卡送去墓地）
function c89662401.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可以作为代价送去墓地的「转生炎兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c89662401.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上表侧表示的「转生炎兽」卡
	local g=Duel.SelectMatchingCard(tp,c89662401.costfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的对象选择与发动准备
function c89662401.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 检查对方场上是否存在盖放的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择对方场上1张盖放的魔法·陷阱卡作为效果对象
	Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,nil)
end
-- ②效果的处理（使作为对象的盖放卡片在本回合不能发动）
function c89662401.actop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFacedown() then
		-- 这个回合，那张盖放的魔法·陷阱卡不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
