--フェニキシアン・クラスター・アマリリス
-- 效果：
-- 这张卡不用「凤凰花种」或者这张卡的效果不能特殊召唤。这张卡攻击的场合，伤害计算后破坏。自己场上存在的这张卡被破坏送去墓地时，给与对方基本分800分伤害。自己的结束阶段时这张卡在墓地存在的场合，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡从墓地守备表示特殊召唤。
function c23558733.initial_effect(c)
	-- 这张卡不用「凤凰花种」或者这张卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将特殊召唤条件判定设为恒为假，使这张卡不能通过其他方式特殊召唤，只能由「凤凰花种」或自身效果特殊召唤。
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，伤害计算后破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c23558733.desop)
	c:RegisterEffect(e2)
	-- 自己场上存在的这张卡被破坏送去墓地时，给与对方基本分800分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23558733,0))  --"对于对方800伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c23558733.damcon)
	e3:SetTarget(c23558733.damtg)
	e3:SetOperation(c23558733.damop)
	c:RegisterEffect(e3)
	-- 自己的结束阶段时这张卡在墓地存在的场合，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡从墓地守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23558733,1))  --"特殊召唤"
	e4:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(c23558733.spcon)
	e4:SetCost(c23558733.spcost)
	e4:SetTarget(c23558733.sptg)
	e4:SetOperation(c23558733.spop)
	c:RegisterEffect(e4)
end
-- 攻击伤害计算后破坏的效果处理：若伤害计算后这张卡是攻击怪兽且未被战破预定，则以效果将其破坏。
function c23558733.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否为进行攻击的怪兽，且尚未被战斗破坏确定，避免与战斗破坏重复处理。
	if c==Duel.GetAttacker() and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 以效果原因将这张卡破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 伤害效果的发动的条件判定：这张卡在被破坏送去墓地之前由自己控制、位于场上，且送去墓地的原因为破坏。
function c23558733.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 伤害效果的目标设定：该伤害不取对象，直接设定对方玩家为伤害对象并登记800点伤害信息。
function c23558733.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害数值）设为800。
	Duel.SetTargetParam(800)
	-- 登记操作为给对方玩家造成800点效果伤害，供伤害相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果的实际处理：从连锁信息中取得对象玩家和伤害值，对其造成效果伤害。
function c23558733.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对p玩家造成d点效果伤害，伤害原因为效果。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 墓地植物族怪兽作为除外代价的过滤条件：该卡是植物族且可作为发动代价从游戏中除外。
function c23558733.cfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的发动的条件判定：仅在当前回合为自己的结束阶段（回合玩家是自己）时满足。
function c23558733.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，确保是“自己的结束阶段”。
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤效果的代价处理：从自己墓地选择1只除自身以外的植物族怪兽表侧除外作为代价。
function c23558733.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己墓地存在至少1只除自身以外、满足条件的植物族怪兽可被除外。
	if chk==0 then return Duel.IsExistingMatchingCard(c23558733.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地的植物族怪兽中选择1张（不能选择自身）作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c23558733.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的卡表侧表示除外，作为特殊召唤效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的目标设定：检查自己怪兽区有空位且这张卡能够特殊召唤，然后登记特殊召唤信息。
function c23558733.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己怪兽区域存在可用的空格，保证有特殊召唤的位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 将这张卡作为特殊召唤对象登记到操作信息中，数量为1，供特殊召唤相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若这张卡仍在墓地且与效果关联，则将其以表侧守备表示特殊召唤到自己场上。
function c23558733.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 不检查召唤条件、但检查苏生限制地将这张卡以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
