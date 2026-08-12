--ARG☆S－紫電のテュデル
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的战士族怪兽的攻击力·守备力上升500。
-- ②：1回合1次，丢弃1张手卡才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从卡组把「阿尔戈☆群星-紫电的堤丢尔」以外的1张「阿尔戈☆群星」卡加入手卡。
-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔陷区发动、攻守上升永续效果、特招并检索的即时诱发效果，以及在魔陷区放置的即时诱发效果。
function s.initial_effect(c)
	-- 将这张卡在魔法与陷阱区域发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为不在伤害步骤的伤害计算后。
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的战士族怪兽的攻击力……上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的目标为战士族怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WARRIOR))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：1回合1次，丢弃1张手卡才能发动。这张卡变成持有以下效果的效果怪兽（战士族·光·4星·攻/守2000）在怪兽区域特殊召唤（也当作陷阱卡使用）。那之后，可以从卡组把「阿尔戈☆群星-紫电的堤丢尔」以外的1张「阿尔戈☆群星」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	-- ●自己·对方回合1次，可以发动。这张卡在自己的魔法与陷阱区域表侧表示放置。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"表侧表示放置"
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMING_MAIN_END)
	e5:SetCondition(s.setcon)
	e5:SetTarget(s.settg)
	e5:SetOperation(s.setop)
	c:RegisterEffect(e5)
end
-- 特殊召唤效果的Cost函数，检查并执行丢弃1张手卡。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡作为发动Cost。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤效果的Target函数，检查怪兽区域空格、同名卡发动限制以及是否能将自身作为陷阱怪兽特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格，且本回合尚未注册该效果的Flag（用于限制同名卡1回合1次）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:GetFlagEffect(id)==0
		-- 检查玩家是否能将这张卡作为指定的陷阱怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,2000,2000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) end
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD-RESET_LEAVE-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁处理的操作信息，表示此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数，用于筛选卡组中「阿尔戈☆群星-紫电的堤丢尔」以外的「阿尔戈☆群星」卡片。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1c1) and c:IsAbleToHand()
end
-- 特殊召唤效果的Operation函数，处理自身特殊召唤为陷阱怪兽，并可选地从卡组检索一张「阿尔戈☆群星」卡。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否满足特殊召唤该陷阱怪兽的条件，若不满足则直接结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1c1,TYPES_EFFECT_TRAP_MONSTER,2000,2000,4,RACE_WARRIOR,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将自身以表侧表示特殊召唤，并检查是否特殊召唤成功。
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)~=0
		-- 检查卡组中是否存在满足检索条件的卡。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否选择将卡加入手卡。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的「阿尔戈☆群星」卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的检索处理与特殊召唤不视为同时进行。
			Duel.BreakEffect()
			-- 将选择的卡加入玩家手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 放置效果的发动条件函数，检查自身未被战斗破坏，且是通过自身效果特殊召唤上场的。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsStatus(STATUS_BATTLE_DESTROYED) and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 放置效果的Target函数，检查魔法与陷阱区域是否有空位，且自身是否可以放置到场上。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and e:GetHandler():IsCanBePlacedOnField() end
end
-- 放置效果的Operation函数，将自身移动到魔法与陷阱区域表侧表示放置。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否仍有空位，若无则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身移动到自己的魔法与陷阱区域表侧表示放置，并立刻适用其效果。
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
