--R.B. Stage Landing
-- 效果：
-- 从自己的卡组·额外卡组把同名卡不在自己场上存在的1只「奏悦机组」怪兽特殊召唤。
-- 自己场上的「奏悦机组」怪兽被战斗·效果破坏的场合，可以作为代替把墓地的这张卡除外。
-- 这张卡发动的回合，自己不是原本攻击力在1500以下的机械族怪兽不能从额外卡组特殊召唤。
-- 
local s,id,o=GetID()
-- 初始化效果函数，创建两个效果：一是发动时特殊召唤怪兽的效果；二是墓地中的此卡被破坏时可代替除外的效果。
function s.initial_effect(c)
	-- 此效果为发动时的主效果，允许从卡组或额外卡组特殊召唤符合条件的「奏悦机组」怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 此效果为当自己场上的「奏悦机组」怪兽被战斗或效果破坏时，可以代替破坏将此卡从墓地除外的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于记录本回合内玩家从额外卡组特殊召唤的次数，以限制发动回合不能特殊召唤非机械族且攻击力超过1500的怪兽。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，判断是否为从额外卡组召唤的机械族怪兽且攻击力在1500以下，若满足则不计入计数。
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500
end
-- 此函数为发动费用函数，检查本回合是否已使用过特殊召唤次数，若未使用则设置不能特殊召唤的限制效果。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次特殊召唤，若是则返回true以允许继续发动。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 创建并注册一个禁止从额外卡组特殊召唤非机械族或攻击力超过1500的怪兽的效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 将上述禁止特殊召唤的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的函数，判断是否为从额外卡组召唤的非机械族或攻击力超过1500的怪兽。
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:GetTextAttack()>=0 and c:GetTextAttack()<=1500)
end
-- 特殊召唤过滤函数，筛选满足条件的「奏悦机组」怪兽用于特殊召唤。
function s.spfilter(c,e,tp,cost)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and (not cost or not s.splimit(e,c))
		-- 检查场上是否存在同名卡，若存在则不能特殊召唤该怪兽。
		and not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,c:GetCode())
		-- 判断目标为卡组中的怪兽时，检查是否有可用的怪兽区域。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 判断目标为额外卡组中的怪兽时，检查是否有足够的额外卡组召唤区域。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 设置发动时的目标信息，表示将要特殊召唤一张怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤条件，即是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,e:IsCostChecked()) end
	-- 设置操作信息，表示本次连锁处理的是特殊召唤效果。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 发动时执行的函数，选择并特殊召唤符合条件的怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 根据过滤条件选择一张满足要求的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp,false)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 代替破坏的过滤函数，判断是否为己方场上的「奏悦机组」怪兽被战斗或效果破坏。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_MONSTER)
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的触发函数，检查是否可以发动此效果并询问玩家是否选择发动。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的效果值函数，返回是否满足代替破坏条件。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的处理函数，将此卡从墓地除外。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从场上除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
