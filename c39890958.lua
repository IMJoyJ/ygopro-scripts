--強化支援メカ・ヘビーアーマー
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只同盟怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
-- ③：装备怪兽不会成为对方的效果的对象。
function c39890958.initial_effect(c)
	-- 为这张卡注册同盟怪兽通用的辅助效果：主要阶段可将自身作为装备卡给自己场上的机械族怪兽装备、装备怪兽被战斗/效果破坏时由这张卡代破、解除装备时特殊召唤自身以及同盟装备数量限制等效果。
	aux.EnableUnionAttribute(c,c39890958.filter)
	-- ③：装备怪兽不会成为对方的效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置“不能成为效果对象”的判定值为 aux.tgoval，即当效果由对方玩家发动时，使装备怪兽不会成为那些效果的对象。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ①：这张卡召唤成功的场合，以自己墓地1只同盟怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 定义装备对象过滤条件：只选择机械族怪兽，用于同盟装备时选择自己场上的机械族怪兽。
function c39890958.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 定义特殊召唤对象过滤条件：必须是同盟怪兽，且满足当前效果特殊召唤所需的召唤条件与苏生限制。
function c39890958.spfilter(c,e,tp)
	return c:IsType(TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件与取对象处理：确认自己墓地存在可特殊召唤的同盟怪兽，且自己主要怪兽区有空位。
function c39890958.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39890958.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足条件的同盟怪兽。
	if chk==0 then return Duel.IsExistingTarget(c39890958.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 并检查自己主要怪兽区是否有可用的空格，确保特殊召唤有充足的位置。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1张符合条件的同盟怪兽作为效果对象，并同时将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c39890958.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置本连锁的处理信息为特殊召唤，对象为已选择的1张卡，供后续时点或效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时取回对象卡，若其仍与效果相关联，则将其表侧表示特殊召唤到自己场上。
function c39890958.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果发动时选择的对象卡（墓地中的同盟怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选择的同盟怪兽以表侧表示特殊召唤到自己场上，正常适用召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
