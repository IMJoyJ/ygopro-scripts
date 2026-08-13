--浮上
-- 效果：
-- ①：以自己墓地1只3星以下的鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c33057951.initial_effect(c)
	-- ①：以自己墓地1只3星以下的鱼族·海龙族·水族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c33057951.target)
	e1:SetOperation(c33057951.activate)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的候选怪兽过滤条件：必须是3星以下、是鱼族·海龙族·水族（0x60040对应这三族的种族位），并且能够以表侧守备表示被当前效果特殊召唤。
function c33057951.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(0x60040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的必要处理：若在连锁处理中选择对象（chkc非空），则验证对象是否是自己墓地的满足条件的怪兽；若在发动时点检测（chk==0），则判断自己主要怪兽区是否有空位，以及墓地是否存在满足条件的对象。
function c33057951.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33057951.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空格，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的、能够成为此效果对象的鱼族·海龙族·水族3星以下怪兽。
		and Duel.IsExistingTarget(c33057951.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出选择提示，提示文字为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的怪兽作为效果对象，并自动将其记录为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c33057951.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次特殊召唤将处理1只对象怪兽，用于后续效果发动检测等。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时的操作：取得之前选择的对象，若对象仍与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c33057951.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的第一张对象卡（即发动时选择的那1只墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己的主要怪兽区，不经过召唤条件检查、不经过苏生限制检查。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
