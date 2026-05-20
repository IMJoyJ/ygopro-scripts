--スプリガンズ・ブラザーズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡·卡组送去墓地的场合，以「护宝炮妖兄弟」以外的自己墓地1只「护宝炮妖」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
function c67436768.initial_effect(c)
	-- ①：这张卡从手卡·卡组送去墓地的场合，以「护宝炮妖兄弟」以外的自己墓地1只「护宝炮妖」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67436768,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,67436768)
	e1:SetCondition(c67436768.spcon)
	e1:SetTarget(c67436768.sptg)
	e1:SetOperation(c67436768.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67436768,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,67436769)
	e2:SetTarget(c67436768.ovtg)
	e2:SetOperation(c67436768.ovop)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是从手卡或卡组送去墓地
function c67436768.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_DECK)
end
-- 过滤自己墓地中「护宝炮妖兄弟」以外、可以守备表示特殊召唤的「护宝炮妖」怪兽
function c67436768.spfilter(c,e,tp)
	return c:IsSetCard(0x155) and not c:IsCode(67436768) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①号效果的发动准备与目标选择判定
function c67436768.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c67436768.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足特殊召唤条件的「护宝炮妖」怪兽
		and Duel.IsExistingTarget(c67436768.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「护宝炮妖」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67436768.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的效果处理（特殊召唤目标怪兽）
function c67436768.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤自己场上表侧表示的「护宝炮妖」超量怪兽
function c67436768.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- ②号效果的发动准备与目标选择判定
function c67436768.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67436768.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 判定自己场上是否存在除自身以外的「护宝炮妖」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c67436768.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「护宝炮妖」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c67436768.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若此卡在墓地发动，设置效果处理信息为涉及墓地卡片离地的操作
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ②号效果的效果处理（将自身作为超量素材）
function c67436768.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为超量素材载体的目标超量怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay() then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 根据规则，将自身原本拥有的超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将这张卡重叠作为目标超量怪兽的超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
