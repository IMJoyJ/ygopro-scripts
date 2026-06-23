--強化支援メカ・ヘビーアーマー
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只同盟怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ③：装备怪兽不会成为对方的效果的对象。
function c39890958.initial_effect(c)
	-- 为卡片注册同盟怪兽机制，包括装备代替破坏、装备限制、装备发动和特殊召唤效果
	aux.EnableUnionAttribute(c,c39890958.filter)
	-- 装备怪兽不会成为对方的效果的对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置装备怪兽不能成为对方效果的对象
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ①：这张卡召唤成功的场合，以自己墓地1只同盟怪兽为对象才能发动。那只怪兽特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(39890958,2))  --"墓地同盟怪兽特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetTarget(c39890958.sumtg)
	e5:SetOperation(c39890958.sumop)
	c:RegisterEffect(e5)
end
c39890958.has_text_type=TYPE_UNION
-- 定义同盟怪兽可以装备的怪兽必须是机械族
function c39890958.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 定义可用于特殊召唤的卡片必须是同盟怪兽且可以特殊召唤
function c39890958.spfilter(c,e,tp)
	return c:IsType(TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为己方墓地的同盟怪兽，检查是否有满足条件的怪兽可特殊召唤
function c39890958.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39890958.spfilter(chkc,e,tp) end
	-- 检查己方墓地是否存在满足条件的同盟怪兽
	if chk==0 then return Duel.IsExistingTarget(c39890958.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查己方场上是否有足够的怪兽区域用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地同盟怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c39890958.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作，将选中的同盟怪兽从墓地特殊召唤到场上
function c39890958.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
