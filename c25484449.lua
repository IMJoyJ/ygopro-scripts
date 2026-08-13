--ゼンマイシャーク
-- 效果：
-- ①：自己场上有「发条」怪兽召唤·特殊召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●这张卡的等级直到回合结束时上升1星。
-- ●这张卡的等级直到回合结束时下降1星。
function c25484449.initial_effect(c)
	-- ①：自己场上有「发条」怪兽召唤·特殊召唤时才能发动。这张卡从手卡特殊召唤。（此段代码注册的是通常召唤成功时触发的e1，特殊召唤成功部分由e2克隆实现）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25484449,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c25484449.spcon)
	e1:SetTarget(c25484449.sptg)
	e1:SetOperation(c25484449.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，可以从以下效果选择1个发动。●这张卡的等级直到回合结束时上升1星。●这张卡的等级直到回合结束时下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25484449,1))  --"等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c25484449.lvtg)
	e3:SetOperation(c25484449.lvop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断触发召唤/特殊召唤的怪兽是否为表侧表示、由己方控制且属于「发条」系列。
function c25484449.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x58)
end
-- 召唤/特殊召唤成功时，检查本次成功召唤的怪兽群中是否存在至少1只满足「发条」条件的怪兽，作为效果发动的契机。
function c25484449.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c25484449.cfilter,1,nil,tp)
end
-- 发动合法性的目标判定：需要己方主怪兽区有空位，且这张手卡中的自身当前可以被其效果特殊召唤。
function c25484449.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定己方场上是否存在可用的主怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次特殊召唤的操作信息告知系统（类别为特殊召唤，对象为这张卡），用于后续效果发动/连锁的检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先确认这张卡仍与当前效果关联（未离场或重置），随后将其特殊召唤到己方场上。
function c25484449.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将这张卡以表侧表示特殊召唤到其持有者的场上（此例为己方），按默认规则检查召唤条件和苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 起动效果的发动处理：此效果无需额外条件即可发动；先提示玩家选择要发动的效果，然后从“等级上升/下降”中选择一项，并将选择结果记录在效果的Label中。
function c25484449.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 显示“请选择要发动的效果”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 弹出选项菜单，让己方选择“等级上升”或“等级下降”，返回的选项序号存入效果的Label供处理时使用。
	local op=Duel.SelectOption(tp,aux.Stringid(25484449,2),aux.Stringid(25484449,3))  --"等级上升/等级下降"
	e:SetLabel(op)
end
-- 效果处理：若这张卡仍表侧表示且与效果关联，则根据之前选择的选项，给这张卡赋予等级上升1星或下降1星的效果，该效果持续到回合结束阶段，并在离场等标准重置时消失。
function c25484449.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- ●这张卡的等级直到回合结束时上升1星。●这张卡的等级直到回合结束时下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if e:GetLabel()==0 then
			e1:SetValue(1)
		else
			e1:SetValue(-1)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
