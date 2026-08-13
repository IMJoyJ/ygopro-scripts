--剛鬼フェイスターン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1张「刚鬼」卡和自己墓地1只「刚鬼」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。
function c26285557.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己场上1张「刚鬼」卡和自己墓地1只「刚鬼」怪兽为对象才能发动。作为对象的场上的卡破坏，作为对象的墓地的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,26285557+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c26285557.target)
	e1:SetOperation(c26285557.activate)
	c:RegisterEffect(e1)
end
-- 定义场上「刚鬼」卡的破坏筛选函数：要求该卡表侧表示且属于「刚鬼」字段，并确认破坏该卡后自己场上仍有可用的怪兽区。
function c26285557.desfilter(c,tp)
	-- 返回真当候选卡为表侧表示且为「刚鬼」字段，同时破坏后自己的怪兽区仍有空格（为后续特殊召唤做准备）。
	return c:IsFaceup() and c:IsSetCard(0xfc) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义墓地「刚鬼」怪兽的特殊召唤筛选函数：要求该卡属于「刚鬼」字段，并且可以被当前效果以表侧表示特殊召唤（满足苏生限制）。
function c26285557.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动目标处理函数：检查发动时对象选择是否合法，若是在连锁中确认对象则返回 false；在发动时确认存在满足条件的场上卡和墓地卡各至少1张。
function c26285557.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local c=e:GetHandler()
	-- 在效果发动（chk==0）时，检查自己场上是否存在至少1张满足 desfilter 的「刚鬼」卡（排除效果发动者自身）。
	if chk==0 then return Duel.IsExistingTarget(c26285557.desfilter,tp,LOCATION_ONFIELD,0,1,c,tp)
		-- 同时检查自己墓地是否存在至少1只满足 spfilter 的「刚鬼」怪兽，以保证两个对象都能合法选取。
		and Duel.IsExistingTarget(c26285557.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己场上符合条件的「刚鬼」卡中选择1张，并将其登记为本次效果的对象（破坏对象）。
	local g1=Duel.SelectTarget(tp,c26285557.desfilter,tp,LOCATION_ONFIELD,0,1,1,c,tp)
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地符合条件的「刚鬼」怪兽中选择1只，并将其登记为本次效果的对象（特殊召唤对象）。
	local g2=Duel.SelectTarget(tp,c26285557.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁包含破坏处理，目标为 g1，预定处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息：本次连锁包含特殊召唤处理，目标为 g2，预定处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	e:SetLabelObject(g1:GetFirst())
end
-- 效果处理函数：从登记的对象中取出场上卡和墓地卡，校正顺序后，若场上卡仍可控且与效果关联，先将其破坏；成功后再将墓地卡特殊召唤。
function c26285557.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的两张对象卡，分别赋给 tc1 和 tc2（顺序可能为选择时的顺序）。
	local tc1,tc2=Duel.GetFirstTarget()
	if tc1~=e:GetLabelObject() then tc1,tc2=tc2,tc1 end
	-- 当 tc1 是自己场上的卡且与效果关联，并成功被效果破坏，且 tc2 仍与效果关联时，才继续特殊召唤。
	if tc1:IsControler(tp) and tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)>0 and tc2:IsRelateToEffect(e) then
		-- 将墓地对象怪兽 tc2 以表侧表示特殊召唤到当前玩家场上（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
