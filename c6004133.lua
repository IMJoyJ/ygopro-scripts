--魔界劇団のゲネプロ
-- 效果：
-- ①：自己主要阶段1开始时才能发动。从卡组把1张「魔界剧团」卡和1张「魔界台本」魔法卡加入手卡。这张卡的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能灵摆召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己主要阶段1开始时才能发动。从卡组把1张「魔界剧团」卡和1张「魔界台本」魔法卡加入手卡。这张卡的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能灵摆召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查发动条件是否为自己主要阶段1开始时的函数
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1，且玩家尚未进行任何操作（即阶段开始时）
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and not Duel.CheckPhaseActivity()
end
-- 过滤卡组中「魔界剧团」卡片的条件函数，且卡组中还必须存在另一张不同的「魔界台本」魔法卡
function s.filter1(c,tp)
	return c:IsSetCard(0x10ec) and c:IsAbleToHand()
		-- 检查卡组中是否存在至少1张与当前选择的卡不同的「魔界台本」魔法卡
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,c)
end
-- 过滤卡组中「魔界台本」魔法卡的条件函数
function s.filter2(c)
	return c:IsSetCard(0x20ec) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果发动的目标选择与合法性检查函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的「魔界剧团」卡和「魔界台本」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置连锁处理的操作信息，表示此效果会将卡组的2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 效果处理（检索并加入手牌，以及适用后续的灵摆召唤限制）的执行函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「魔界剧团」卡片
	local g1=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_DECK,0,nil,tp)
	if g1:GetCount()>0 then
		-- 提示玩家选择要加入手牌的第一张卡片（「魔界剧团」卡）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg1=g1:Select(tp,1,1,nil)
		-- 提示玩家选择要加入手牌的第二张卡片（「魔界台本」魔法卡）
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张与第一张选择的卡不同的「魔界台本」魔法卡
		local sg2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,sg1:GetFirst())
		sg1:Merge(sg2)
		-- 将选中的2张卡加入玩家手牌
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg1)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是「魔界剧团」怪兽不能灵摆召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家灵摆召唤的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制非「魔界剧团」怪兽进行灵摆召唤的过滤函数
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x10ec) and sumtype&SUMMON_TYPE_PENDULUM==SUMMON_TYPE_PENDULUM
end
