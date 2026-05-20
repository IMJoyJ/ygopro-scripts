--フィッシュアンドビッズ
-- 效果：
-- ①：自己主要阶段1开始时，把1张手卡除外才能发动。对方可以把2张手卡除外。没除外的场合，自己让以下效果适用。
-- ●从卡组选2只鱼族怪兽全部送去墓地或全部除外。这个回合，自己不是鱼族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 创建并注册卡片发动时的效果
function s.initial_effect(c)
	-- ①：自己主要阶段1开始时，把1张手卡除外才能发动。对方可以把2张手卡除外。没除外的场合，自己让以下效果适用。●从卡组选2只鱼族怪兽全部送去墓地或全部除外。这个回合，自己不是鱼族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数：把1张手卡除外
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检查阶段，确认自己手卡中是否存在除这张卡以外可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,c) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张手卡作为发动代价
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,c)
	-- 将选择的手卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义发动条件函数：自己主要阶段1开始时
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己主要阶段1的开始时（尚未进行任何行动）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 过滤卡组中的鱼族怪兽
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_FISH)
end
-- 检查选出的2张卡是否能全部送去墓地或全部除外
function s.gcheck(g)
	return #g==2 and (g:FilterCount(Card.IsAbleToGrave,nil)==2 or g:FilterCount(Card.IsAbleToRemove,nil)==2)
end
-- 定义效果的目标处理（Target）函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有的鱼族怪兽
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return dg:CheckSubGroup(s.gcheck,2,2) end
	-- 设置将2张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置将2张卡除外的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 定义效果的运行处理（Operation）函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡中可以除外的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,1-tp)
	-- 如果对方手卡有2张以上，询问对方是否选择除外2张手卡
	if #g>1 and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then  --"是否除外手卡？"
		-- 提示对方玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local tc=g:Select(1-tp,2,2,nil)
		-- 将对方选择的2张手卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
		return
	end
	-- 获取自己卡组中所有的鱼族怪兽
	local dg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	if dg:CheckSubGroup(s.gcheck,2,2) then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sg1=dg:SelectSubGroup(tp,s.gcheck,false,2,2)
		-- 判断选中的卡是否能送去墓地，并让玩家选择是送去墓地还是除外
		if sg1:GetFirst():IsAbleToGrave() and (not sg1:GetFirst():IsAbleToRemove() or Duel.SelectOption(tp,1191,1192)==0) then
			-- 将选中的2只鱼族怪兽全部送去墓地
			Duel.SendtoGrave(sg1,REASON_EFFECT)
		elseif sg1:GetFirst():IsAbleToRemove() then
			-- 将选中的2只鱼族怪兽全部除外
			Duel.Remove(sg1,POS_FACEUP,REASON_EFFECT)
		end
	end
	-- 这个回合，自己不是鱼族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册不能特殊召唤鱼族以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制只能特殊召唤鱼族怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_FISH)
end
