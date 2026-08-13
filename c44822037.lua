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
-- 效果①的发动条件判定：确认满足代价检查、我方主要怪兽区域有空位，且玩家可以特殊召唤符合该陷阱怪兽参数的怪兽。
function c44822037.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查我方主要怪兽区域是否存在可用空位，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否能够将这张卡作为天使族·光·4星·攻/守1800的效果怪兽特殊召唤（通常还受到陷阱怪兽特殊召唤资格的限制）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,44822037,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_FAIRY,ATTRIBUTE_LIGHT) end
	-- 登记本次效果将进行特殊召唤的操作信息，对象为这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①处理：将这张卡变为效果怪兽（也当作陷阱卡使用），并以表侧攻击表示特殊召唤到自己的怪兽区域。
function c44822037.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认玩家仍能特殊召唤该怪兽，若不能则直接终止本次特殊召唤处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,44822037,0,TYPES_EFFECT_TRAP_MONSTER,1800,1800,4,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以自身效果特殊召唤到自己的怪兽区域，表侧表示，不检查召唤条件、不检查苏生限制。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 效果②的发动条件：仅当这张卡是由自身效果特殊召唤成功过、对方正在进行怪兽的特殊召唤，且当前连锁为空时才能发动。
function c44822037.discon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetHandler():GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
	-- 具体条件：这次特殊召唤的玩家是对方、当前连锁为空、且这张卡有来自自身效果的特殊召唤记录。
	return tp~=ep and Duel.GetCurrentChain()==0 and se and se:GetHandler()==e:GetHandler()
end
-- 代价过滤条件：表侧表示、可以作为代价送去墓地、从魔法与陷阱区域特殊召唤的永续陷阱卡。
function c44822037.discfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsSummonLocation(LOCATION_SZONE) and (c:GetType()&(TYPE_TRAP+TYPE_CONTINUOUS))==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 效果②的代价：从我方怪兽区域选择1张从魔法与陷阱区域特殊召唤的表侧表示永续陷阱卡送去墓地。
function c44822037.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足代价条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c44822037.discfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡，提示消息为‘请选择要送去墓地的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张满足条件的永续陷阱卡（从我方怪兽区域）。
	local g=Duel.SelectMatchingCard(tp,c44822037.discfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选择的卡送去墓地，作为发动效果的代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的发动时目标处理：无取对象，但登记无效对方那次特殊召唤并破坏那些怪兽的操作信息。
function c44822037.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记无效召唤的操作信息，对象为对方正在特殊召唤的那些怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 登记破坏那些怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果②处理：无效对方那次特殊召唤，并将因此破坏那些怪兽。
function c44822037.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效对方正在进行的特殊召唤。
	Duel.NegateSummon(eg)
	-- 将那些没有成功特殊召唤的怪兽破坏。
	Duel.Destroy(eg,REASON_EFFECT)
end
-- 效果③的发动目标：以与这张卡战斗并导致这张卡被破坏的怪兽为对象，且该怪兽仍与战斗相关。
function c44822037.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsRelateToBattle() end
	-- 登记将那只战斗对象怪兽破坏的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果③处理：若那只与这张卡战斗的怪兽仍与战斗相关，则将其破坏。
function c44822037.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc and tc:IsRelateToBattle() then
		-- 将那只让这张卡战斗破坏的怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
