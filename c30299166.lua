--ワーム・テンタクルス
-- 效果：
-- 把自己墓地存在的1只名字带有「异虫」的爬虫类族怪兽从游戏中除外发动。这个回合这张卡在同1次的战斗阶段中可以作2次攻击。这个效果1回合只能使用1次。
function c30299166.initial_effect(c)
	-- 创建一个起动效果，效果描述为“两次攻击”，类型为起动效果，适用区域为主怪兽区，限制每回合只能发动1次，条件为可以进入战斗阶段，费用为除外1只墓地的异虫爬虫类族怪兽，目标为自身，效果为使自身在该回合可进行2次攻击
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
-- 效果发动的条件：检查回合玩家是否可以进入战斗阶段
function c30299166.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 费用过滤函数：检查是否为名字带有「异虫」且种族为爬虫类且可以作为除外费用的怪兽
function c30299166.costfilter(c)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
-- 效果的费用处理：检查是否满足条件的卡牌存在，若存在则提示选择并除外1张满足条件的卡牌
function c30299166.mtcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在自己墓地是否存在至少1张满足条件的卡牌
	if chk==0 then return Duel.IsExistingMatchingCard(c30299166.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡牌
	local g=Duel.SelectMatchingCard(tp,c30299166.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡牌除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标处理：检查自身是否已拥有额外攻击效果
function c30299166.mttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 效果的发动处理：若自身存在于场上，则赋予自身1次额外攻击次数，该效果在结束阶段重置
function c30299166.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 赋予自身1次额外攻击次数
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
