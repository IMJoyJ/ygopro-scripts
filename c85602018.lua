--遺言状
-- 效果：
-- 只要该回合有怪兽从自己场上送入自己墓地就可以从卡组特殊召唤攻击力1500以下的1只怪兽到场上。
function c85602018.initial_effect(c)
	-- 只要该回合有怪兽从自己场上送入自己墓地就可以从卡组特殊召唤攻击力1500以下的1只怪兽到场上。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85602018.target)
	e1:SetOperation(c85602018.activate)
	c:RegisterEffect(e1)
	if not c85602018.global_check then
		c85602018.global_check=true
		-- 只要该回合有怪兽从自己场上送入自己墓地
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(c85602018.checkop)
		-- 注册全局环境效果，用于在整局游戏中监听怪兽送去墓地的事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤条件：属于自己且从自己怪兽区域送去自己墓地的卡
function c85602018.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查是否有怪兽从场上送去墓地，若有则为对应玩家注册一个回合内有效的标识效果
function c85602018.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		if eg:IsExists(c85602018.cfilter,1,nil,p) then
			-- 为玩家注册一个持续到回合结束的标识效果，表示该回合已有怪兽从场上送去墓地
			Duel.RegisterFlagEffect(p,85602018,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 卡片发动时的效果目标处理，检查当前是否已满足送墓条件，并据此设置效果分类和标签
function c85602018.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查当前回合自己是否有怪兽从场上送去墓地
	if Duel.GetFlagEffect(tp,85602018)~=0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息为从卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		e:SetLabel(1)
	else
		e:SetCategory(0)
		e:SetLabel(0)
	end
end
-- 卡片发动时的效果处理：若已满足送墓条件则可选择直接特殊召唤；否则注册一个在回合内可自由时点发动的延迟特殊召唤效果
function c85602018.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的攻击力1500以下的怪兽
		and Duel.IsExistingMatchingCard(c85602018.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 询问玩家是否现在就发动特殊召唤的效果
		and Duel.SelectYesNo(tp,aux.Stringid(85602018,0)) then  --"是否要使用「遗言状」的效果？"
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c85602018.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	else
		-- 从卡组特殊召唤攻击力1500以下的1只怪兽到场上。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetCountLimit(1)
		e1:SetCondition(c85602018.spcon)
		e1:SetOperation(c85602018.spop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 为玩家注册该延迟特殊召唤效果，使其在回合结束前可以自由时点发动
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤条件：攻击力1500以下且可以特殊召唤的怪兽
function c85602018.spfilter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 延迟效果的发动条件：该回合已有怪兽送墓、自己场上有空位且卡组有可召唤的怪兽
function c85602018.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该回合是否有怪兽从自己场上送入自己墓地
	return Duel.GetFlagEffect(tp,85602018)~=0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的攻击力1500以下的怪兽
		and Duel.IsExistingMatchingCard(c85602018.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
end
-- 延迟效果的操作处理：在场上展示卡片并从卡组特殊召唤1只怪兽
function c85602018.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在场上展示“遗言状”的卡片动画，提示该效果正在解决
	Duel.Hint(HINT_CARD,0,85602018)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85602018.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽在自己场上表侧表示特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
