--ジュラック・アウロ
-- 效果：
-- ①：把这张卡解放，以「朱罗纪异特龙」以外的自己墓地1只4星以下的「朱罗纪」怪兽为对象才能发动。那只怪兽特殊召唤。
function c80727721.initial_effect(c)
	-- ①：把这张卡解放，以「朱罗纪异特龙」以外的自己墓地1只4星以下的「朱罗纪」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80727721,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c80727721.spcost)
	e1:SetTarget(c80727721.sptg)
	e1:SetOperation(c80727721.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的代价：检查自身是否可以解放，并执行解放操作。
function c80727721.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：等级4以下、卡名含有「朱罗纪」、非「朱罗纪异特龙」且可以特殊召唤的怪兽。
function c80727721.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x22) and not c:IsCode(80727721) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的目标选择与检测，确认墓地中存在符合条件的怪兽，且有可用的怪兽区域。
function c80727721.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c80727721.filter(chkc,e,tp) end
	-- 检查怪兽区域空位数（由于自身作为代价解放，怪兽区空位数大于-1即可）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己墓地是否存在符合条件的、可以作为效果对象的怪兽。
		and Duel.IsExistingTarget(c80727721.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c80727721.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为：特殊召唤选中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选中的对象怪兽特殊召唤。
function c80727721.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
