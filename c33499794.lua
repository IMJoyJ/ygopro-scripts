--ネムレリア・レペッテ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有其他的「妮穆蕾莉娅」卡存在的场合，可以把「梦见之妮穆蕾莉娅」以外的额外卡组的卡的以下数量里侧除外，那个效果发动。
-- ●1张：从自己墓地把1张「妮穆蕾莉娅」卡加入手卡。
-- ●2张：这个回合，自己受到的全部伤害变成一半。
-- ●3张：自己场上1只兽族·10星怪兽送去墓地，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 注册该魔陷的发动用空效果以及①效果对应的三种可选发动分支（除外1张回收墓地、除外2张伤害减半、除外3张送墓兽族10星并无效对方表侧怪兽效果），各分支共享1回合1次。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1张：从自己墓地把1张「妮穆蕾莉娅」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"1张：从自己墓地把1张「妮穆蕾莉娅」卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.effcon)
	e2:SetCost(s.effcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	-- 2张：这个回合，自己受到的全部伤害变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"2张：这个回合，自己受到的全部伤害变成一半"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.effcon)
	e3:SetCost(s.effcost)
	e3:SetOperation(s.changeop)
	e3:SetLabel(2)
	c:RegisterEffect(e3)
	-- 3张：自己场上1只兽族·10星怪兽送去墓地，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"3张：对方场上的全部表侧表示怪兽的效果无效"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.effcon)
	e4:SetCost(s.effcost)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	e4:SetLabel(3)
	c:RegisterEffect(e4)
end
-- 过滤函数：筛选出表侧表示且卡名含有「妮穆蕾莉娅」（0x191）的卡。
function s.cfilter(c)
	return c:IsSetCard(0x191) and c:IsFaceup()
end
-- 发动条件判断：自己场上存在这张卡以外的表侧表示「妮穆蕾莉娅」卡时，①效果才可发动。
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足s.cfilter的卡，且用e:GetHandler()将这张卡自身排除在计数之外。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 代价过滤函数：选择额外卡组中可以被里侧除外且卡名不是「梦见之妮穆蕾莉娅」（70155677）的卡作为除外代价。
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost() and not c:IsCode(70155677)
end
-- 代价处理：根据当前效果Label（1/2/3）确定需要除外的数量ct，从额外卡组选择ct张符合条件的卡里侧除外；chk==0时仅检查是否足够。
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 代价检查：确认额外卡组中存在至少ct张满足s.rmfilter的卡可供选择。
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_EXTRA,0,ct,nil) end
	-- 弹出选择提示，提示玩家正在选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己的额外卡组选择ct张（数量由Label决定）满足s.rmfilter的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_EXTRA,0,ct,ct,nil)
	-- 将选中的代价卡以里侧表示除外（REASON_COST）。
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 回收目标过滤：选择墓地中卡名含有「妮穆蕾莉娅」且可以被加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x191) and c:IsAbleToHand()
end
-- 回收效果的目标设定：检查墓地有1张以上可回收的「妮穆蕾莉娅」卡，并设置操作信息为从墓地加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查：墓地是否存在至少1张满足s.thfilter的「妮穆蕾莉娅」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：本效果处理时将把1张卡从墓地加入手卡（CATEGORY_TOHAND），供其他卡连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 回收效果处理：从墓地选择1张「妮穆蕾莉娅」卡加入手卡，若加入成功则向对方展示该卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的「妮穆蕾莉娅」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 伤害减半效果的处理：为当前玩家（tp）注册一个持续到回合结束的伤害变更效果，使tp受到的所有伤害减半。
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	-- ●2张：这个回合，自己受到的全部伤害变成一半。●3张：自己场上1只兽族·10星怪兽送去墓地，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害减半效果注册到玩家tp，使其在当回合内持续适用。
	Duel.RegisterEffect(e1,tp)
end
-- 伤害变更值计算：将受到的伤害值除以2后向下取整，实现伤害减半。
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
-- 送墓目标过滤：选择自己场上兽族·10星且可以送去墓地的怪兽。
function s.tgfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsLevel(10) and c:IsAbleToGrave()
end
-- ③效果的目标设定：确认自己场上有1只兽族·10星怪兽可送墓，且对方场上有1只以上表侧表示效果怪兽可被无效，并设置将1张卡送去墓地的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足s.tgfilter（兽族·10星）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检查对方场上是否存在至少1只可以被无效的表侧表示效果怪兽（aux.NegateEffectMonsterFilter）。
		and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：本效果处理时将把自己场上1只怪兽送去墓地（CATEGORY_TOGRAVE）。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- ③效果处理：先选择自己场上1只兽族·10星怪兽送去墓地，若成功则获取对方场上全部可无效的表侧效果怪兽，对其分别赋予效果无效和效果无效化状态直到回合结束，并使相关连锁无效。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的兽族·10星怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1只满足s.tgfilter的怪兽并取得该卡对象。
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	-- 若选择的怪兽存在、成功被效果送去墓地且确实位于墓地，则继续执行对方怪兽的无效化处理。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取对方场上全部满足aux.NegateEffectMonsterFilter（表侧表示效果怪兽且未被无效）的卡，作为无效化对象。
		local dg=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
		local dc=dg:GetFirst()
		while dc do
			-- 使与这些怪兽相关的连锁（已发动效果）无效化，重置标志为RESET_TURN_SET。
			Duel.NegateRelatedChain(dc,RESET_TURN_SET)
			-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e1)
			-- 对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e2)
			dc=dg:GetNext()
		end
	end
end
