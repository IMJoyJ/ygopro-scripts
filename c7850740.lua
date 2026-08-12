--エクシーズ・スライドルフィン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有超量怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在，自己场上有超量怪兽特殊召唤的场合，以那1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。这个效果在这张卡送去墓地的回合不能发动。
function c7850740.initial_effect(c)
	-- 注册一个用于检测这张卡是否在当前回合送去墓地的效果，以便后续判断墓地效果的发动限制。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：自己场上有超量怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7850740,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,7850740)
	e1:SetCondition(c7850740.spcon)
	e1:SetTarget(c7850740.sptg)
	e1:SetOperation(c7850740.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有超量怪兽特殊召唤的场合，以那1只超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7850740,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,7850741)
	e2:SetLabelObject(e0)
	e2:SetCondition(c7850740.matcon)
	e2:SetTarget(c7850740.mattg)
	e2:SetOperation(c7850740.matop)
	c:RegisterEffect(e2)
end
-- 过滤出自己场上表侧表示的超量怪兽。
function c7850740.spfilter(c,tp)
	return c:IsControler(tp) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- 效果①的发动条件：自己场上有超量怪兽特殊召唤。
function c7850740.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c7850740.spfilter,1,nil,tp)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤）。
function c7850740.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的处理：若自身仍在手卡，则将自身特殊召唤。
function c7850740.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤出自己场上新特殊召唤的、可作为效果对象的表侧表示超量怪兽（且排除导致其特殊召唤的效果本身）。
function c7850740.cfilter1(c,e,tp,se)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp) and c:IsCanBeEffectTarget(e)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 效果②的发动条件：这张卡不在送去墓地的回合，且自己场上有超量怪兽特殊召唤。
function c7850740.matcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	-- 确保当前不是这张卡送去墓地的回合，且特殊召唤的怪兽中存在符合条件的自己场上的超量怪兽。
	return aux.exccon(e) and eg:IsExists(c7850740.cfilter1,1,nil,e,tp,se)
end
-- 过滤出本次特殊召唤的、自己场上表侧表示的超量怪兽。
function c7850740.tgfilter(c,tp,eg)
	return eg:IsContains(c) and c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControler(tp)
end
-- 效果②的发动准备与对象选择（选择那1只特殊召唤的超量怪兽为对象）。
function c7850740.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7850740.tgfilter(chkc,tp,eg) end
	-- 检查场上是否存在可以作为效果对象的、本次特殊召唤的自己超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c7850740.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp,eg)
		and e:GetHandler():IsCanOverlay() end
	if eg:GetCount()==1 then
		-- 当只有1只符合条件的超量怪兽特殊召唤时，直接将其设为效果对象。
		Duel.SetTargetCard(eg)
	else
		-- 提示玩家选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家手动选择1只符合条件的超量怪兽作为效果对象。
		Duel.SelectTarget(tp,c7850740.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,eg)
	end
	-- 设置连锁处理中的操作信息为：这张卡离开墓地。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的处理：将墓地的这张卡重叠在作为对象的超量怪兽下面作为超量素材。
function c7850740.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的超量怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将这张卡重叠在目标超量怪兽下面作为超量素材。
		Duel.Overlay(tc,Group.FromCards(c))
	end
end
