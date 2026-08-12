--クリアクリボー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：给与伤害的怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外才能发动。自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以再把那只怪兽特殊召唤。那之后，攻击对象转移为那只怪兽。
function c46613515.initial_effect(c)
	-- ①：给与伤害的怪兽的效果由对方发动时，把这张卡从手卡丢弃才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46613515,0))  --"伤害效果的发动无效"
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c46613515.negcon)
	e1:SetCost(c46613515.negcost)
	e1:SetTarget(c46613515.negtg)
	e1:SetOperation(c46613515.negop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外才能发动。自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以再把那只怪兽特殊召唤。那之后，攻击对象转移为那只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46613515,1))  --"把墓地的这张卡除外"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,46613515)
	e2:SetCondition(c46613515.drcon)
	-- 将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c46613515.drtg)
	e2:SetOperation(c46613515.drop)
	c:RegisterEffect(e2)
end
-- 效果发动时，检查连锁是否可无效，并判断是否为对方造成的伤害效果
function c46613515.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可无效，并判断是否为对方造成的伤害效果
	return Duel.IsChainNegatable(ev) and (aux.damcon1(e,tp,eg,ep,ev,re,r,rp) or aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp))
		and re:IsActiveType(TYPE_MONSTER) and ep~=tp
end
-- 将此卡从手牌丢弃作为费用
function c46613515.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手牌丢弃作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 设置效果处理时的发动无效操作信息
function c46613515.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的发动无效操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 使连锁发动无效
function c46613515.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效
	Duel.NegateActivation(ev)
end
-- 攻击宣言时，检查是否为对方怪兽直接攻击
function c46613515.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击宣言时，检查是否为对方怪兽直接攻击
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 设置效果处理时的抽卡操作信息
function c46613515.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽一张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理时的抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡和特殊召唤逻辑
function c46613515.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行从卡组抽一张卡的操作
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 获取抽到的卡
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsType(TYPE_MONSTER) then
		-- 检查玩家场上是否有怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 判断是否可以特殊召唤该卡并询问玩家选择
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(46613515,2)) then  --"是否把那只怪兽特殊召唤？"
			-- 向对方确认抽到的卡
			Duel.ConfirmCards(1-tp,tc)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 执行特殊召唤操作并判断是否能转移攻击对象
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and not Duel.GetAttacker():IsImmuneToEffect(e) then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将攻击对象转移为特殊召唤的怪兽
				Duel.ChangeAttackTarget(tc)
			end
		end
	end
end
