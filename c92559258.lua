--サーヴァント・オブ・エンディミオン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把这张卡3个魔力指示物取除才能发动。卡组1只可以放置魔力指示物的攻击力1000以上的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
-- 【怪兽效果】
-- 自己对「恩底弥翁的仆从」1回合只能有1次特殊召唤。
-- ①：有魔力指示物放置的这张卡可以直接攻击。
-- ②：对方回合1次，丢弃1张手卡才能发动。给这张卡以及自己场上的可以放置魔力指示物的卡全部各放置1个魔力指示物。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
function c92559258.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE+LOCATION_MZONE)
	-- 设置灵摆怪兽属性（允许放置在灵摆区域发动）
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(92559258)
	-- 注册连锁判定监控效果：在魔法卡发动连锁时为卡片标记FLAG，用于确保魔法卡成功发动并结算后放置魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	-- 设置操作函数为系统的连锁注册辅助函数（给卡片注册FLAG_ID_CHAINING）
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- P效果①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c92559258.counterop)
	c:RegisterEffect(e2)
	-- P效果②：把这张卡3个魔力指示物取除才能发动。卡组1只可以放置魔力指示物的攻击力1000以上的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92559258,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCost(c92559258.spcost)
	e3:SetTarget(c92559258.sptg)
	e3:SetOperation(c92559258.spop)
	c:RegisterEffect(e3)
	-- 怪兽效果①：有魔力指示物放置的这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c92559258.dacon)
	c:RegisterEffect(e4)
	-- 怪兽效果②：对方回合1次，丢弃1张手牌才能发动。给这张卡以及自己场上的可以放置魔力指示物的卡全部各放置1个魔力指示物。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(92559258,1))  --"放置指示物"
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetCondition(c92559258.countercon2)
	e5:SetCost(c92559258.countercost2)
	e5:SetTarget(c92559258.countertg2)
	e5:SetOperation(c92559258.counterop2)
	c:RegisterEffect(e5)
	-- 怪兽效果③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(92559258,2))  --"在灵摆区域放置"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c92559258.pencon)
	e6:SetTarget(c92559258.pentg)
	e6:SetOperation(c92559258.penop)
	c:RegisterEffect(e6)
	-- 注册离场预备监控效果：在怪兽离场前记录其身上原有的魔力指示物数量，传递给破坏后在P区放置的效果。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD_P)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetOperation(c92559258.regop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
end
c92559258.mentioned_counter={
	[0x1]=true,
}
-- P效果①处理：确认发动的连锁类型为魔法卡且FLAG标记有效，给自身放置1个魔力指示物
function c92559258.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- P效果②Cost：取除自身3个魔力指示物
function c92559258.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 卡组特召过滤条件：攻击力在1000以上、可放置魔力指示物且可特殊召唤的怪兽
function c92559258.spfilter(c,e,tp)
	-- 判断怪兽是否满足攻击力>=1000、能放置魔力指示物且能被特殊召唤
	return c:IsAttackAbove(1000) and c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- P效果②发动准备与目标确认：检查场位、青眼精灵龙限制、卡组是否存在符合条件怪兽
function c92559258.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自身是否可以特殊召唤并放置魔力指示物
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c92559258.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组及灵摆区特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_DECK)
end
-- P效果②处理：将自身与从卡组选出的1只怪兽特殊召唤，并各放置1个魔力指示物
function c92559258.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92559258.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选中的卡组怪兽和自身表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 遍历本次特殊召唤的2只怪兽并为它们各添加1个魔力指示物
		for tc in aux.Next(g) do
			tc:AddCounter(0x1,1)
		end
	end
end
-- 怪兽效果①条件：自身拥有至少1个魔力指示物
function c92559258.dacon(e)
	return e:GetHandler():GetCounter(0x1)>0
end
-- 怪兽效果②条件：处于对方回合
function c92559258.countercon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 怪兽效果②Cost：丢弃1张手牌
function c92559258.countercost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否有可丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌丢弃1张卡去墓地
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 怪兽效果②发动准备与目标确认
function c92559258.countertg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(0x1,1) end
	-- 获取自己场上除自身外所有可放置魔力指示物的卡
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,c,0x1,1)
	g:AddCard(c)
	-- 设置连锁操作信息：为目标卡片放置指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,0,0)
end
-- 怪兽效果②处理：给自身及场上所有可放置魔力指示物的卡各放置1个魔力指示物
function c92559258.counterop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有可放置魔力指示物的卡片组
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,c,0x1,1)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 遍历目标卡片组并逐一放置1个魔力指示物
	for tc in aux.Next(g) do
		if tc:IsCanAddCounter(0x1,1) then
			tc:AddCounter(0x1,1)
		end
	end
end
-- 怪兽效果③触发条件：原本在怪兽区域且被破坏时处于表侧表示
function c92559258.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③发动准备：检查灵摆区域是否有空位
function c92559258.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否至少有一个空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③处理：将这张卡放置在灵摆区域，并继承原先持有的魔力指示物数量
function c92559258.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 将卡片放置到灵摆区域并继承放置原数量的魔力指示物
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 离场前处理：读取并保存当前卡片上的魔力指示物数量到目标效果Label中
function c92559258.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetCounter(0x1))
end
