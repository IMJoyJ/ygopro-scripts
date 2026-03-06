--エルフェンノーツ～狂奏のラプソディア～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的中央的主要怪兽区域有怪兽存在，对方怪兽只能向那只怪兽攻击。
-- ②：从自己的手卡·场上把1只怪兽送去墓地，以原本属性和那只怪兽不同的自己墓地1只「耀圣」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上有同调怪兽存在的场合，可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动、攻击限制和特殊召唤效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要自己的中央的主要怪兽区域有怪兽存在，对方怪兽只能向那只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atklimit)
	c:RegisterEffect(e2)
	-- 从自己的手卡·场上把1只怪兽送去墓地，以原本属性和那只怪兽不同的自己墓地1只「耀圣」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上有同调怪兽存在的场合，可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetHintTiming(TIMING_END_PHASE)
	e3:SetCountLimit(1,id)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 判断是否为中央怪兽区的怪兽
function s.atkfilter(c)
	return c:GetSequence()==2
end
-- 判断己方中央怪兽区是否存在怪兽
function s.atkcon(e)
	-- 判断己方中央怪兽区是否存在怪兽
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制非中央怪兽区的怪兽成为攻击对象
function s.atklimit(e,c)
	return c:GetSequence()~=2
end
-- 筛选满足送去墓地条件的怪兽，包括怪兽类型、可送去墓地、怪兽区有空位、墓地存在符合条件的「耀圣」怪兽
function s.costfilter(c,e,tp)
	-- 满足怪兽类型和可送去墓地的条件
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 满足墓地存在符合条件的「耀圣」怪兽的条件
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalAttribute())
end
-- 筛选墓地中的「耀圣」怪兽，属性与送去墓地的怪兽不同，且可特殊召唤
function s.spfilter(c,e,tp,attr)
	return c:IsSetCard(0x1d8) and c:GetOriginalAttribute()&attr==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理特殊召唤效果的费用，选择送去墓地的怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽可作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalAttribute())
	-- 将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 设置特殊召唤效果的目标选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local attr=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,attr) end
	if chk==0 then return e:IsCostChecked() end
	-- 提示玩家选择要特殊召唤的「耀圣」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择要特殊召唤的「耀圣」怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,attr)
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤效果，若成功则判断是否可使对方卡效果无效
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取特殊召唤效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍在连锁中且未受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将目标怪兽特殊召唤到场上
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断己方场上是否存在同调怪兽
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAllTypes),tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO+TYPE_MONSTER)
		-- 判断对方场上是否存在可无效的卡
		and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否要使对方卡效果无效
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把卡效果无效？"
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择要无效的卡
		local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		local dc=g:GetFirst()
		if dc then
			-- 显示被选为对象的卡
			Duel.HintSelection(g)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 使目标卡的连锁无效
			Duel.NegateRelatedChain(dc,RESET_TURN_SET)
			-- 使目标卡效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e1)
			-- 使目标卡效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e2)
			if dc:IsType(TYPE_TRAPMONSTER) then
				-- 使目标陷阱怪兽效果无效
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				dc:RegisterEffect(e3)
			end
		end
	end
end
