--ワーム・テンタクルス
-- 效果：
-- 把自己墓地存在的1只名字带有「异虫」的爬虫类族怪兽从游戏中除外发动。这个回合这张卡在同1次的战斗阶段中可以作2次攻击。这个效果1回合只能使用1次。
function c30299166.initial_effect(c)
	-- 把自己墓地存在的1只名字带有「异虫」的爬虫类族怪兽从游戏中除外发动。这个回合这张卡在同1次的战斗阶段中可以作2次攻击。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30299166,0))  --"两次攻击"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c30299166.mtcon)
	e1:SetCost(c30299166.mtcost)
	e1:SetTarget(c30299166.mttg)
	e1:SetOperation(c30299166.mtop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前回合玩家可以进入战斗阶段（Duel.IsAbleToEnterBP），即满足自己主要阶段且能进入战斗阶段的发动时机。
function c30299166.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否能够进入战斗阶段，作为效果发动条件的确定依据。
	return Duel.IsAbleToEnterBP()
end
-- 代价筛选函数：选择满足以下条件的卡：卡名包含「异虫」（SetCard 0x3e）、种族为爬虫类族、并且可以作为代价从墓地除外。
function c30299166.costfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
-- 代价处理：首先检查自己墓地是否存在至少1只满足costfilter的「异虫」爬虫类族怪兽；若存在，则提示玩家选择1只，将其以表侧表示除外（REASON_COST）作为发动代价。
function c30299166.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查阶段（chk==0）：判断自己墓地是否存在至少1只满足代价筛选条件的「异虫」爬虫类族怪兽，以确定能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c30299166.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向当前玩家显示“请选择要除外的卡”的选择消息（HINTMSG_REMOVE），用于后续选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让当前玩家从自己墓地选择1只满足代价筛选条件的「异虫」爬虫类族怪兽，作为本效果发动的代价。
	local g=Duel.SelectMatchingCard(tp,c30299166.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡片以表侧表示除外，除外原因为代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 发动可行性检查：确认这张卡当前没有被附加额外攻击次数（EFFECT_EXTRA_ATTACK计数为0），从而防止在该效果已适用时再次发动造成重复叠加。
function c30299166.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 效果处理：若这张卡仍与当前连锁效果关联，则给自己注册一个额外的攻击次数效果（EFFECT_EXTRA_ATTACK，数值为1），该效果随离场、回手牌/卡组/墓地、除外、翻面等状态变化或结束阶段时重置。
function c30299166.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合这张卡在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
