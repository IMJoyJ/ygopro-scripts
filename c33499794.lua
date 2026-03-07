--ネムレリア・レペッテ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有其他的「妮穆蕾莉娅」卡存在的场合，可以把「梦见之妮穆蕾莉娅」以外的额外卡组的卡的以下数量里侧除外，那个效果发动。
-- ●1张：从自己墓地把1张「妮穆蕾莉娅」卡加入手卡。
-- ●2张：这个回合，自己受到的全部伤害变成一半。
-- ●3张：自己场上1只兽族·10星怪兽送去墓地，对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的通用发动效果和三个不同数量的除外效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1张：从自己墓地把1张「妮穆蕾莉娅」卡加入手卡
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
	-- 2张：这个回合，自己受到的全部伤害变成一半
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
	-- 3张：对方场上的全部表侧表示怪兽的效果无效
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
-- 筛选场上存在的「妮穆蕾莉娅」卡的过滤函数
function s.cfilter(c)
	return c:IsSetCard(0x191) and c:IsFaceup()
end
-- 效果发动条件：自己场上有其他的「妮穆蕾莉娅」卡存在
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「妮穆蕾莉娅」卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,e:GetHandler())
end
-- 筛选可以作为除外代价的额外卡组卡片的过滤函数
function s.rmfilter(c)
	return c:IsAbleToRemoveAsCost() and not c:IsCode(70155677)
end
-- 效果发动的费用处理：选择指定数量的额外卡组卡片除外
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetLabel()
	-- 检查是否满足除外费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_EXTRA,0,ct,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的除外卡片组
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_EXTRA,0,ct,ct,nil)
	-- 将选中的卡片以里侧形式除外
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 筛选可以加入手牌的「妮穆蕾莉娅」卡的过滤函数
function s.thfilter(c)
	return c:IsSetCard(0x191) and c:IsAbleToHand()
end
-- 设置效果发动的处理目标：从墓地选择1张「妮穆蕾莉娅」卡加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足加入手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息，指定将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果发动的处理：选择墓地的「妮穆蕾莉娅」卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地卡片组
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对手查看加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果发动的处理：使自己受到的伤害减半
function s.changeop(e,tp,eg,ep,ev,re,r,rp)
	-- 注册使伤害减半的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害减半效果注册到游戏环境
	Duel.RegisterEffect(e1,tp)
end
-- 设置伤害减半的计算函数
function s.damval(e,re,val,r,rp,rc)
	return math.floor(val/2)
end
-- 筛选可以送去墓地的10星兽族怪兽的过滤函数
function s.tgfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsLevel(10) and c:IsAbleToGrave()
end
-- 设置效果发动的处理目标：选择1只10星兽族怪兽送去墓地并无效对方怪兽效果
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足送去墓地的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在表侧表示的怪兽
		and Duel.IsExistingMatchingCard(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置效果处理信息，指定将1只怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
-- 效果发动的处理：选择1只10星兽族怪兽送去墓地并无效对方怪兽效果
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的场上怪兽
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	-- 判断选择的怪兽是否成功送去墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取对方场上的所有表侧表示怪兽
		local dg=Duel.GetMatchingGroup(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,nil)
		local dc=dg:GetFirst()
		while dc do
			-- 使目标怪兽相关的连锁无效
			Duel.NegateRelatedChain(dc,RESET_TURN_SET)
			-- 使目标怪兽效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dc:RegisterEffect(e1)
			-- 使目标怪兽效果无效
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
