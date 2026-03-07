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
-- 检查目标怪兽是否满足等级3以下、种族为鱼族·海龙族·水族、且可以被守备表示特殊召唤的条件
function c33057951.filter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsRace(0x60040) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理效果的发动条件，判断是否满足特殊召唤的条件
function c33057951.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c33057951.filter(chkc,e,tp) end
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c33057951.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c33057951.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽特殊召唤
function c33057951.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
