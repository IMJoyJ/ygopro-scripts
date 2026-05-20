--神鳥の烈戦
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的鸟兽族怪兽之内除攻击力最高的鸟兽族怪兽以外的鸟兽族怪兽不会成为攻击对象，也不会成为对方的效果的对象。
-- ②：把自己场上2只原本等级是7星以上而原本属性不同的「斯摩夫」怪兽和这张卡送去墓地才能发动。场上的卡全部回到持有者手卡，自己受到回到手卡的数量×500伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
function c57823578.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的鸟兽族怪兽之内除攻击力最高的鸟兽族怪兽以外的鸟兽族怪兽不会成为攻击对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c57823578.atlimit)
	c:RegisterEffect(e2)
	-- 也不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c57823578.tgtg)
	-- 设置不能成为对方卡片效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ②：把自己场上2只原本等级是7星以上而原本属性不同的「斯摩夫」怪兽和这张卡送去墓地才能发动。场上的卡全部回到持有者手卡，自己受到回到手卡的数量×500伤害。那之后，给与对方为和自己受到的伤害相同数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57823578,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_END_PHASE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,57823578)
	e4:SetCondition(c57823578.thcon)
	e4:SetCost(c57823578.thcost)
	e4:SetTarget(c57823578.thtg)
	e4:SetOperation(c57823578.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数：筛选场上表侧表示、攻击力大于指定值的鸟兽族怪兽
function c57823578.cfilter(c,atk)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:GetAttack()>atk
end
-- 攻击限制的目标过滤函数：判断怪兽是否为除攻击力最高以外的鸟兽族怪兽
function c57823578.atlimit(e,c)
	-- 检查自己场上是否存在比当前怪兽攻击力更高的表侧表示鸟兽族怪兽
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and Duel.IsExistingMatchingCard(c57823578.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetAttack())
end
-- 效果对象抗性的目标过滤函数：判断怪兽是否为除攻击力最高以外的鸟兽族怪兽
function c57823578.tgtg(e,c)
	-- 检查自己场上是否存在比当前怪兽攻击力更高的鸟兽族怪兽
	return c:IsRace(RACE_WINDBEAST) and Duel.IsExistingMatchingCard(c57823578.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetAttack())
end
-- 效果发动条件：此卡已在魔法与陷阱区域表侧表示存在
function c57823578.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 过滤函数：筛选原本等级在7星以上、原本卡名含有「斯摩夫」且能送去墓地的怪兽
function c57823578.costfilter(c)
	return c:GetOriginalLevel()>=7 and c:IsSetCard(0x12d) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：检查选中的怪兽原本属性是否互不相同，且场上是否存在其他能回到手牌的卡
function c57823578.fselect(g,tp,mc)
	local sg=g:Clone()
	sg:AddCard(mc)
	return g:GetClassCount(Card.GetOriginalAttribute)==g:GetCount()
		-- 检查场上是否存在至少1张不属于被选为代价的卡且能回到手牌的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,sg)
end
-- 效果发动代价：将自身和场上2只原本等级7星以上且原本属性不同的「斯摩夫」怪兽送去墓地
function c57823578.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己场上所有满足代价条件的「斯摩夫」怪兽
	local g=Duel.GetMatchingGroup(c57823578.costfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return c:IsAbleToGraveAsCost()
		and g:CheckSubGroup(c57823578.fselect,2,2,tp,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,c57823578.fselect,false,2,2,tp,c)
	sg:AddCard(c)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 效果发动目标：注册场上所有卡回到手牌以及双方受到伤害的操作信息
function c57823578.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有可以回到手牌的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置将场上所有卡回到手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置双方玩家受到伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 效果处理核心：将场上的卡全部回到持有者手卡，自己受到相应伤害，之后给与对方同等数值的伤害
function c57823578.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有可以回到手牌的卡
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 如果场上有卡且成功将这些卡送回手牌
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
		-- 计算实际回到手牌的卡的数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_HAND)
		-- 自己受到回到手牌数量×500的伤害，并记录实际受到的伤害值
		local val=Duel.Damage(tp,ct*500,REASON_EFFECT)
		-- 如果自己受到了伤害且生命值大于0
		if val>0 and Duel.GetLP(tp)>0 then
			-- 中断当前效果，使后续伤害处理与之前的伤害处理不视为同时进行
			Duel.BreakEffect()
			-- 给与对方与自己受到的伤害相同数值的伤害
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end
