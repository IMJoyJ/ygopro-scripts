--超重武者ツヅ－3
-- 效果：
-- 「超重武者 鼓-3」的效果1回合只能使用1次。
-- ①：场上的这张卡被破坏送去墓地的场合，以「超重武者 鼓-3」以外的自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽特殊召唤。
function c87535691.initial_effect(c)
	-- 「超重武者 鼓-3」的效果1回合只能使用1次。①：场上的这张卡被破坏送去墓地的场合，以「超重武者 鼓-3」以外的自己墓地1只「超重武者」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87535691,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,87535691)
	e1:SetCondition(c87535691.spcon)
	e1:SetTarget(c87535691.sptg)
	e1:SetOperation(c87535691.spop)
	c:RegisterEffect(e1)
end
-- 判定发动条件：此卡是否在场上被破坏并送去墓地
function c87535691.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤条件：自己墓地中「超重武者 鼓-3」以外的、可以特殊召唤的「超重武者」怪兽
function c87535691.spfilter(c,e,tp)
	return c:IsSetCard(0x9a) and not c:IsCode(87535691) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检测
function c87535691.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87535691.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c87535691.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「超重武者」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87535691.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽特殊召唤
function c87535691.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
