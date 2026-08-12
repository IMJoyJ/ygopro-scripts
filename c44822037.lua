--碑像の天使－アズルーン
-- 效果：
-- ①：这张卡发动后变成效果怪兽（天使族·光·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
-- ②：这张卡是已用这张卡的效果特殊召唤的场合，1回合1次，对方把怪兽特殊召唤之际，把从魔法与陷阱区域特殊召唤的自己的怪兽区域1张永续陷阱卡送去墓地才能发动。那次特殊召唤无效，那些怪兽破坏。
-- ③：这张卡被战斗破坏时才能发动。把让这张卡破坏的怪兽破坏。
function c44822037.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（天使族·光·4星·攻/守1800）在怪兽区域特殊召唤（也当作陷阱卡使用）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44822037.target)
	e1:SetOperation(c44822037.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡是已用这张卡的效果特殊召唤的场合，1回合1次，对方把怪兽特殊召唤之际，把从魔法与陷阱区域特殊召唤的自己的怪兽区域1张永续陷阱卡送去墓地才能发动。那次特殊召唤无效，那些怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44822037,0))
	e2:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_SPSUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c44822037.discon)
	e2:SetCost(c44822037.discost)
	e2:SetTarget(c44822037.distg)
	e2:SetOperation(c44822037.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏时才能发动。把让这张卡破坏的怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44822037,1))
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetTarget(c44822037.destg)
	e3:SetOperation(c44822037.desop)
	c:RegisterEffect(e3)
end
-- 检查是否满足特殊召唤的条件，包括是否已支付费用、场上是否有空位以及是否可以特殊召唤该怪兽。
function c44822037.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家的怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤该怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44822037,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 设置特殊召唤的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将该卡作为效果怪兽特殊召唤到场上。
function c44822037.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次检查是否可以特殊召唤该怪兽。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,44822037,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将该卡以特殊召唤方式送入场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断是否满足无效召唤的条件，包括是否为对方召唤、当前连锁是否为空以及是否为该卡的效果召唤。
function c44822037.discon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
	-- 判断是否为对方召唤、当前连锁是否为空且该卡为效果召唤。
	return tp~=ep and Duel.GetCurrentChain()==0 and se and se:GetHandler()==e:GetHandler()
end
-- 定义用于选择送去墓地的陷阱卡的过滤函数。
function c44822037.discfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsSummonLocation(LOCATION_SZONE) and (c:GetType()&(TYPE_TRAP+TYPE_CONTINUOUS))==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 设置发动效果的费用，选择一张满足条件的陷阱卡送去墓地。
function c44822037.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44822037.discfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张满足条件的陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c44822037.discfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的陷阱卡送去墓地作为费用。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置无效召唤和破坏的效果处理信息。
function c44822037.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效召唤的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置破坏的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行无效召唤和破坏操作。
function c44822037.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使目标怪兽的召唤无效。
	Duel.NegateSummon(eg)
	-- 破坏目标怪兽。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 设置战斗破坏时的效果处理信息。
function c44822037.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsRelateToBattle() end
	-- 设置破坏的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行战斗破坏时的效果，将破坏的怪兽破坏。
function c44822037.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 破坏目标怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
