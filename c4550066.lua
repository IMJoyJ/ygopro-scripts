--リビルディア
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时，以自己墓地1只攻击力1500以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
function c4550066.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽时，以自己墓地1只攻击力1500以下的电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4550066,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果发动条件：本卡与对方怪兽战斗并将其战斗破坏时才能发动（通过aux.bdocon检测本卡与战斗相关且与对方怪兽战斗）。
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c4550066.sptg)
	e1:SetOperation(c4550066.spop)
	c:RegisterEffect(e1)
end
-- 定义候选过滤函数：筛选出自己墓地中满足电子界族、攻击力1500以下且可以被当前效果特殊召唤的怪兽。
function c4550066.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsAttackBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标选择函数：先处理连锁中指定对象（chkc）时校验该对象是否合法，再在发动确认时（chk==0）判断是否存在满足条件的墓地电子界族怪兽以及我方怪兽区是否有空位。
function c4550066.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c4550066.spfilter(chkc,e,tp) end
	-- 发动时检查自己墓地是否存在至少1只满足spfilter条件的电子界族怪兽（可作为取对象目标）。
	if chk==0 then return Duel.IsExistingTarget(c4550066.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 发动时检查我方主要怪兽区是否有空余区域，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向操作玩家显示选择提示消息，提示文本为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的满足条件的电子界族怪兽中选择1只，并将其登记为当前连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c4550066.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息设置为：将1只对象怪兽特殊召唤，供其他卡效果进行发动判定或响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：在效果处理时，获取效果对象，确认对象仍与效果关联后，将其特殊召唤到自己场上。
function c4550066.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个对象卡（此处为选中的墓地怪兽），用于后续处理。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的怪兽区域（采用通常特殊召唤规则，检查召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
