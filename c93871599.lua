--ドラゴン・導きの呼笛
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有魔法师族怪兽存在的场合才能发动。从卡组把1只5星以上的龙族怪兽特殊召唤。对方场上有怪兽2只以上存在的场合，可以再把1只所特殊召唤的怪兽的同名怪兽从卡组特殊召唤。这个回合，自己不是龙族·魔法师族怪兽不能特殊召唤。
-- ②：自己主要阶段2，把这个回合送去墓地的这张卡除外才能发动。自己抽1张。
local s,id,o=GetID()
-- 注册这张卡的发动效果以及在墓地发动的抽卡效果。
function s.initial_effect(c)
	-- ①：场上有魔法师族怪兽存在的场合才能发动。从卡组把1只5星以上的龙族怪兽特殊召唤。对方场上有怪兽2只以上存在的场合，可以再把1只所特殊召唤的怪兽的同名怪兽从卡组特殊召唤。这个回合，自己不是龙族·魔法师族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段2，把这个回合送去墓地的这张卡除外才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.drcon)
	-- 效果发动的代价：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的魔法师族怪兽的过滤函数。
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 效果①的发动条件：场上有魔法师族怪兽存在。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件检测：双方场上是否存在至少1只表侧表示的魔法师族怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤卡组中可特殊召唤的5星以上龙族怪兽的过滤函数。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①发动的检测处理：确认自身场上有怪兽空格且卡组中存在可特殊召唤的5星以上龙族怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动检测：确认自身场上是否存在可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动检测：确认自己卡组中是否存在至少1只满足条件的5星以上龙族怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤卡组中与特殊召唤的怪兽同名的可特殊召唤怪兽的过滤函数。
function s.spfilter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的处理：特殊召唤卡组中1只5星以上的龙族怪兽，若对方场上有2只以上怪兽，则可以选择再特殊召唤1只同名怪兽，并施加本回合不是龙族·魔法师族怪兽不能特殊召唤的限制效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自身场上是否存在可用的怪兽区域空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只满足条件的5星以上龙族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选中的怪兽特殊召唤至场上，并确认是否成功特殊召唤。
		if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			-- 处理条件检测：确认对方场上是否存在2只以上的怪兽。
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,2,nil)
			-- 处理条件检测：确认自身场上是否还有可用的怪兽区域空格。
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 处理条件检测：确认卡组中是否存在特殊召唤的怪兽的同名怪兽。
			and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp,tc:GetCode())
			-- 提示并询问玩家是否选择再特殊召唤1只同名怪兽。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
			-- 提示玩家选择要特殊召唤的同名怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从卡组中选择1只与前述特殊召唤怪兽同名的怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
			if sg:GetCount()>0 then
				-- 中断当前效果处理，使前后的特殊召唤处理不视为同时进行。
				Duel.BreakEffect()
				-- 将选中的同名怪兽以表侧表示特殊召唤。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个回合，自己不是龙族·魔法师族怪兽不能特殊召唤。②：自己主要阶段2，把这个回合送去墓地的这张卡除外才能发动。自己抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.spelimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内的特殊召唤限制效果给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制除龙族·魔法师族怪兽以外的怪兽特殊召唤的限制函数。
function s.spelimit(e,c)
	return not c:IsRace(RACE_DRAGON+RACE_SPELLCASTER)
end
-- 效果②的发动条件：在自己主要阶段2，且此卡是本回合送去墓地。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认这张卡是否是当前回合送去墓地。
	return e:GetHandler():GetTurnID()==Duel.GetTurnCount()
		and not e:GetHandler():IsReason(REASON_RETURN)
		-- 确认当前是否处于主要阶段2。
		and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果②发动的靶向处理：确认玩家是否可以效果抽卡，并设置连锁信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 抽卡条件检测：确认玩家是否具有可以效果抽1张卡的状态。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前连锁的操作目标玩家为发动效果的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的操作参数为抽1张卡。
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息：让玩家从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的处理：让玩家抽1张卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取效果处理的目标玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 按照连锁中设置的参数执行抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
