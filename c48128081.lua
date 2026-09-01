--宿命の決闘
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：作为这张卡发动时的效果处理，双方玩家可以从手卡把1只怪兽攻击表示特殊召唤。有特殊召唤的场合，场上的其他怪兽全部变成里侧守备表示。这张卡的发动后，直到回合结束时自己不能把怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的怪兽攻击宣言时，以对方场上1张里侧表示的卡为对象才能发动。那次攻击无效，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：对方结束阶段发动。这张卡回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可以表侧攻击表示特殊召唤的怪兽
function s.spfilter(c,e,p)
	return c:IsCanBeSpecialSummoned(e,0,p,false,false,POS_FACEUP_ATTACK)
end
-- 过滤手牌中公开且可特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时的目标检查：检查双方手牌是否有可特招的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌是否有可特招怪兽
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) and
		-- 检查自己怪兽区是否有空位
		Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local b2=false
	-- 检查对方是否有空位且可以特殊召唤
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) then
		-- 检查对方手牌是否有未公开的卡
		if Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) then
			for lv=1,12 do
				-- 检查对方是否能特招对应等级的怪兽
				if Duel.IsPlayerCanSpecialSummonMonster(1-tp,0,0,TYPE_MONSTER,-2,-2,lv,-2,-2,POS_FACEUP_ATTACK) then
					b2=true
					break
				end
			end
		end
		-- 检查对方手牌是否有公开的可特招怪兽
		b2=b2 or Duel.IsExistingMatchingCard(s.spfilter2,1-tp,LOCATION_HAND,0,1,nil,e,1-tp)
	end
	if chk==0 then return b1 or b2 end
end
-- 发动时的处理：双方各选怪兽特招，其他怪兽变里侧守备表示并施加召唤限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local res=false
	local g=Group.CreateGroup()
	-- 遍历双方玩家
	for p in aux.TurnPlayers() do
		-- 检查玩家怪兽区是否有空位
		if Duel.GetLocationCount(p,LOCATION_MZONE)>0
			-- 检查玩家手牌是否有可特招怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,p,LOCATION_HAND,0,1,nil,e,p)
			-- 玩家选择是否特殊召唤手牌怪兽
			and Duel.SelectYesNo(p,aux.Stringid(id,3)) then
			-- 提示选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择手牌1只怪兽
			local sc=Duel.SelectMatchingCard(p,s.spfilter,p,LOCATION_HAND,0,1,1,nil,e,p):GetFirst()
			-- 特殊召唤选中的怪兽
			if Duel.SpecialSummonStep(sc,0,p,p,false,false,POS_FACEUP_ATTACK) then
				g:AddCard(sc)
				if not res then
					res=true
				end
			end
		end
	end
	if res then
		-- 特殊召唤处理完成
		Duel.SpecialSummonComplete()
		-- 获取场上其他可变成里侧守备表示的怪兽
		local sg=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,g)
		if sg:GetCount()>0 then
			-- 动作连接，前后效果不同时处理
			Duel.BreakEffect()
			-- 将其他怪兽变成里侧守备表示
			Duel.ChangePosition(sg,POS_FACEDOWN_DEFENSE)
		end
	end
	-- 这张卡的发动后，直到回合结束时自己不能把怪兽召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册本回合不能通常召唤的限制
	Duel.RegisterEffect(e1,tp)
	-- 这张卡的发动后，直到回合结束时自己不能把怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 注册本回合不能特殊召唤的限制
	Duel.RegisterEffect(e2,tp)
end
-- ②效果的发动条件：自己的怪兽攻击宣言时
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由自己控制
	return Duel.GetAttacker():GetControler()==tp
end
-- ②效果的目标：选择对方场上1张里侧表示的卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在里侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有里侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理：无效攻击并破坏目标卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效攻击
	if not Duel.NegateAttack() then return end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张里侧表示的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显示选中的卡
		Duel.HintSelection(g)
		-- 破坏选中的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件：对方结束阶段
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- ③效果的目标：检查自身是否可以回到手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置回到手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③效果的处理：将自身送回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身送回手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 对方确认回到手牌的卡
		Duel.ConfirmCards(1-tp,c)
	end
end
