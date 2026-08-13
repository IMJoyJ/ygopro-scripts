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
	-- 这个卡名的②的效果1回合只能使用1次。②：对方怪兽的直接攻击宣言时，把墓地的这张卡除外才能发动。自己从卡组抽1张。那张抽到的卡是怪兽的场合，可以再把那只怪兽特殊召唤。那之后，攻击对象转移为那只怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46613515,1))  --"把墓地的这张卡除外"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,46613515)
	e2:SetCondition(c46613515.drcon)
	-- 设置②效果的发动代价：将墓地的这张卡除外（作为发动②效果的费用）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c46613515.drtg)
	e2:SetOperation(c46613515.drop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：当前连锁可被无效，且是对方（ep≠tp）发动的怪兽效果（含有给任意玩家造成伤害/恢复的效果）。
function c46613515.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁是否可被无效，并确认该效果为会给己方或对方造成伤害（或恢复）的怪兽效果。
	return Duel.IsChainNegatable(ev) and (aux.damcon1(e,tp,eg,ep,ev,re,r,rp) or aux.damcon1(e,1-tp,eg,ep,ev,re,r,rp))
		and re:IsActiveType(TYPE_MONSTER) and ep~=tp
end
-- ①效果的代价函数：发动时确认手卡的这张卡可以丢弃，然后将它送去墓地作为发动代价。
function c46613515.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡丢弃（送去墓地），丢弃原因记为代价与丢弃（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- ①效果的目标（发动合法性）函数：发动时总是合法，并设置需要无效化的对象为当前连锁上的效果（eg）。
function c46613515.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将本次无效的对象确定为连锁中的那个怪兽效果（eg），数量为1，分类为无效发动（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①效果处理函数：执行时使对方发动的那个给与伤害的怪兽效果的发动无效。
function c46613515.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 将连锁 ev 的发动无效化。
	Duel.NegateActivation(ev)
end
-- ②效果的发动条件判断函数：当对方怪兽进行直接攻击宣言（攻击者为对方控制且没有攻击对象）时允许发动。
function c46613515.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击者是对方控制的怪兽，且攻击目标为空（即直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- ②效果的发动目标函数：确认自己可以抽1张卡，并提交抽卡的操作信息。
function c46613515.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己是否能够抽1张卡；若不能则无法发动②效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置操作信息：声明本效果将让自己从卡组抽1张卡（目标暂不指定，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理函数：抽1张卡；若抽到怪兽且自己场上有空位，可将其特殊召唤；特殊召唤成功且攻击怪兽不免疫此效果时，将攻击对象转移为那只怪兽。
function c46613515.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己以效果抽1张卡；若实际没有抽到卡则结束这次效果处理。
	if Duel.Draw(tp,1,REASON_EFFECT)==0 then return end
	-- 取得刚刚抽到的那张卡，作为后续判断是否特殊召唤的对象。
	local tc=Duel.GetOperatedGroup():GetFirst()
	if tc:IsType(TYPE_MONSTER) then
		-- 检查自己场上是否有可用的主要怪兽区空格；若没有则无法特殊召唤，直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 若抽到的卡可以被特殊召唤，并且玩家选择“是”，则执行后续特殊召唤流程；否则跳过。
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(46613515,2)) then  --"是否把那只怪兽特殊召唤？"
			-- 将抽到的那只怪兽展示给对手确认。
			Duel.ConfirmCards(1-tp,tc)
			-- 中断当前效果链，使后续的特殊召唤作为独立动作处理（避免错过时点）。
			Duel.BreakEffect()
			-- 将抽到的那只怪兽以表侧攻击表示特殊召唤到自己场上；若特殊召唤成功，且攻击怪兽不免疫这张卡的效果，则继续处理攻击转移。
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 and not Duel.GetAttacker():IsImmuneToEffect(e) then
				-- 再次中断效果处理，使攻击转移在特殊召唤成功后的时点单独处理。
				Duel.BreakEffect()
				-- 将正在攻击的对方怪兽的攻击对象改为特殊召唤出来的那只怪兽。
				Duel.ChangeAttackTarget(tc)
			end
		end
	end
end
