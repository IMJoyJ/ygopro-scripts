--ティンダングル・ドールス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组送去墓地的场合，以「廷达魔三角之巨噬蠕虫」以外的自己墓地1只「廷达魔三角」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
-- ②：这张卡反转的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
-- ③：这张卡为连接素材的「廷达魔三角」连接怪兽在同1次的战斗阶段中可以作3次攻击。
function c12678601.initial_effect(c)
	-- ①：这张卡从手卡·卡组送去墓地的场合，以「廷达魔三角之巨噬蠕虫」以外的自己墓地1只「廷达魔三角」怪兽为对象才能发动。那只怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12678601,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,12678601)
	e1:SetCondition(c12678601.spcon)
	e1:SetTarget(c12678601.sptg)
	e1:SetOperation(c12678601.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡反转的场合才能发动。从卡组把1张魔法·陷阱卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12678601,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,12678602)
	e2:SetTarget(c12678601.tgtg)
	e2:SetOperation(c12678601.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡为连接素材的「廷达魔三角」连接怪兽在同1次的战斗阶段中可以作3次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCondition(c12678601.effcon)
	e3:SetOperation(c12678601.effop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否从手卡或卡组送去墓地
function c12678601.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 过滤满足条件的墓地「廷达魔三角」怪兽
function c12678601.spfilter(c,e,tp)
	return c:IsSetCard(0x10b) and not c:IsCode(12678601) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 设置效果目标，选择满足条件的墓地怪兽
function c12678601.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12678601.spfilter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c12678601.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c12678601.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理特殊召唤效果
function c12678601.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽有效且成功特殊召唤，则确认对方可见
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)~=0 then
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 过滤卡组中可送去墓地的魔法或陷阱卡
function c12678601.tgfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 设置反转效果的目标
function c12678601.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c12678601.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果操作信息，确定送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 处理反转效果
function c12678601.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的魔法或陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择卡组中满足条件的魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c12678601.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断此卡是否作为连接素材被使用
function c12678601.effcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(0x10b)
end
-- 设置连接素材效果
function c12678601.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 「廷达魔三角之巨噬蠕虫」作为连接素材
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12678601,2))  --"「廷达魔三角之巨噬蠕虫」作为连接素材"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
