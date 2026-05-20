--スプリガンズ・ピード
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡解放，以「护宝炮妖·鱼雷」以外的自己墓地1只「护宝炮妖」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
function c56818977.initial_effect(c)
	-- ①：把这张卡解放，以「护宝炮妖·鱼雷」以外的自己墓地1只「护宝炮妖」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56818977,0))  --"解放并特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56818977)
	e1:SetCost(c56818977.spcost)
	e1:SetTarget(c56818977.sptg)
	e1:SetOperation(c56818977.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在手卡·场上·墓地存在的场合，以自己场上1只「护宝炮妖」超量怪兽为对象才能发动。把这张卡作为那只怪兽的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56818977,1))  --"补充超量素材"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetCountLimit(1,56818978)
	e2:SetTarget(c56818977.ovtg)
	e2:SetOperation(c56818977.ovop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动代价（解放自身）判定与执行
function c56818977.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤自己墓地中「护宝炮妖·鱼雷」以外的「护宝炮妖」怪兽
function c56818977.spfilter(c,e,tp)
	return c:IsSetCard(0x155) and c:IsType(TYPE_MONSTER) and not c:IsCode(56818977) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动判定与对象选择
function c56818977.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56818977.spfilter(chkc,e,tp) end
	-- 判定是否有可用的怪兽区域（计算解放自身后释放的格子）以及墓地是否存在合法的特殊召唤对象
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0 and Duel.IsExistingTarget(c56818977.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只合法的「护宝炮妖」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c56818977.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的执行（特殊召唤目标怪兽）
function c56818977.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己场上表侧表示的「护宝炮妖」超量怪兽
function c56818977.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x155) and c:IsType(TYPE_XYZ)
end
-- ②号效果的发动判定与对象选择
function c56818977.ovtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c56818977.ovfilter(chkc) and chkc~=e:GetHandler() end
	-- 判定自己场上是否存在合法的「护宝炮妖」超量怪兽，且自身是否能作为超量素材
	if chk==0 then return Duel.IsExistingTarget(c56818977.ovfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and e:GetHandler():IsCanOverlay() end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「护宝炮妖」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c56818977.ovfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若自身在墓地，设置效果处理信息为涉及墓地卡片移动
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ②号效果的执行（将自身作为超量素材叠放）
function c56818977.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay() then
		local og=c:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 若自身原本拥有超量素材，根据规则将那些素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将自身重叠作为目标超量怪兽的超量素材
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
