--R.B.ジャンプ・ナンバー
-- 效果：
-- 从自己的卡组·额外卡组把同名卡不在自己场上存在的1只「奏悦机组」怪兽特殊召唤。
-- 自己场上的「奏悦机组」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
-- 这张卡发动的回合，自己不是原本攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
-- 
local s,id,o=GetID()
-- 定义初始效果函数，用于注册卡片的效果。
function s.initial_effect(c)
	-- 创建并注册特殊召唤效果：从卡组/额外卡组特殊召唤同名怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 创建并注册场上永续效果：代替破坏时将墓地这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	-- 设置操作计数器，用于限制特殊召唤次数。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 定义计数器过滤函数：如果不是从额外卡组召唤或者满足机械族攻击力条件则不计入计数。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500
end
-- 定义效果发动时的代价函数：检查是否可以支付代价（即是否已经特殊召唤过），并设置限制特殊召唤的效果。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合是否已经特殊召唤过怪兽，如果未特殊召唤过则返回true。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 原文：这张卡发动的回合，自己不是原本攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 注册限制特殊召唤的效果。
	Duel.RegisterEffect(e1,tp)
end
-- 定义特殊召唤过滤函数：检查卡片是否符合特殊召唤的条件（同名、可召唤、不在场上）。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500)
end
-- 定义特殊召唤过滤函数，判断怪兽是否满足特殊召唤条件，包括种族、攻击力以及是否已经有面朝上的同名卡在场。
function s.spfilter(c,e,tp,cost)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not cost or not s.splimit(e,c))
		-- 检查当前场上是否存在面朝上的同名卡。
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		-- 检查卡片是否在卡组中且场上有空余的怪兽区。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 检查卡片是否在额外卡组中且有可用的额外怪兽区。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 定义目标选择函数：根据过滤条件选择特殊召唤的目标卡片。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足特殊召唤条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,e:IsCostChecked()) end
	-- 设置操作信息，表明这是一个特殊召唤效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 定义激活函数：提示玩家选择要特殊召唤的卡片，并执行特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示消息，要求选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组中选择满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,false)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义代替破坏效果过滤函数：检查目标怪兽是否符合除外条件（面朝上、同名、在场上）。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 定义代替破坏效果的目标选择函数：检查卡片是否可以被移除，并询问玩家是否要发动效果。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 向玩家询问是否要发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 定义代替破坏效果的值函数：返回符合条件的怪兽。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 定义代替破坏效果的操作函数：将墓地的卡片除外。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以REASON_EFFECT原因，POS_FACEUP形式移除卡片。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
