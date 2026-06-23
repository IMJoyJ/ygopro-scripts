--エルフェンノーツ～狂奏のラプソディア～
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要自己的中央的主要怪兽区域有怪兽存在，对方怪兽只能向那只怪兽攻击。
-- ②：从自己的手卡·场上把1只怪兽送去墓地，以原本属性和那只怪兽不同的自己墓地1只「耀圣」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上有同调怪兽存在的场合，可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化此卡的效果注册：注册卡片的发动效果；注册①效果（限制对方的攻击对象只能选择自己中央怪兽区域的怪兽，并且不能直接攻击）；注册②效果（将1只怪兽送墓，特殊召唤属性不同的「耀圣」怪兽，并在场上有同调怪兽时可以额外无效对方场上卡片的效果）。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己的中央的主要怪兽区域有怪兽存在，对方怪兽只能向那只怪兽攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atkcon)
	e2:SetValue(s.atklimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：从自己的手卡·场上把1只怪兽送去墓地，以原本属性和那只怪兽不同的自己墓地1只「耀圣」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上有同调怪兽存在的场合，可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(TIMING_END_PHASE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上中央主要怪兽区域（序列为2）的怪兽。
function s.atkfilter(c)
	return c:GetSequence()==2
end
-- ①效果的适用条件判断：确认自己的中央主要怪兽区域是否存在怪兽。
function s.atkcon(e)
	-- 判断自己的中央主要怪兽区域是否存在怪兽。
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 限制攻击对象：对方不能选择除了中央主要怪兽区域（序列为2）以外的怪兽作为攻击对象。
function s.atklimit(e,c)
	return c:GetSequence()~=2
end
-- 过滤可以送去墓地作为发动代价的怪兽（且保证有怪兽区域空位，并且墓地中存在属性不同的「耀圣」怪兽可以被选择为对象）。
function s.costfilter(c,e,tp)
	-- 判断卡片是否为怪兽卡、是否能作为代价送去墓地，以及该卡离开场上后自己场上是否有可用于特殊召唤的怪兽区数量。
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
		-- 判断墓地中是否存在至少1只原本属性和送墓怪兽不同、且可特殊召唤的「耀圣」怪兽可以被选为效果对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetOriginalAttribute())
end
-- 过滤墓地中原本属性与attr不同，且可以特殊召唤的「耀圣」怪兽。
function s.spfilter(c,e,tp,attr)
	return c:IsSetCard(0x1d8) and c:GetOriginalAttribute()&attr==0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动代价处理：从自己的手卡或场上选择1只怪兽送去墓地，并记录其原本属性作为后续过滤对象的条件。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动前，检查是否存在可以作为代价送去墓地的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只用于作为代价送去墓地的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	e:SetLabel(tc:GetOriginalAttribute())
	-- 作为效果发动代价，将选中的怪兽送去墓地。
	Duel.SendtoGrave(tc,REASON_COST)
end
-- ②效果的发动准备与取对象：选择墓地中1只属性满足过滤条件的「耀圣」怪兽为对象，并注册特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local attr=e:GetLabel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp,attr) end
	if chk==0 then return e:IsCostChecked() end
	-- 提示玩家选择要特殊召唤的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地中选择1只符合属性限制的「耀圣」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,attr)
	-- 设置当前连锁的操作信息，标记该效果包含从墓地特殊召唤怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的实效处理：将作为对象的「耀圣」怪兽特殊召唤。特殊召唤成功后，若自己场上有同调怪兽存在且对方场上有表侧表示卡，可以由玩家选择是否将对方场上1张表侧表示卡片的效果直到回合结束时无效。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的发动对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽是否仍与效果关联（且不受「王家长眠之谷」影响）。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将选中的「耀圣」怪兽特殊召唤，并判断是否特殊召唤成功。
		and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查自己场上是否存在表侧表示的同调怪兽。
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsAllTypes),tp,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO+TYPE_MONSTER)
		-- 检查对方场上是否存在可以被无效的表侧表示卡片。
		and Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 询问玩家是否选择发动后续的“将对方场上1张表侧表示卡的效果无效”的追加效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否把卡效果无效？"
		-- 提示玩家选择要无效效果的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从对方场上选择1张可无效的表侧表示卡。
		local g=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
		local dc=g:GetFirst()
		if dc then
			-- 显示被选为无效对象的卡片的动画效果。
			Duel.HintSelection(g)
			-- 进行时点分割，使之后的无效效果处理与特殊召唤处理不视为同时进行。
			Duel.BreakEffect()
			-- 使与选中的卡片有关的已发动连锁效果都无效化。
			Duel.NegateRelatedChain(dc,RESET_TURN_SET)
			-- 可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e1)
			-- 可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e2)
			if dc:IsType(TYPE_TRAPMONSTER) then
				-- 可以把对方场上1张表侧表示卡的效果直到回合结束时无效。
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
