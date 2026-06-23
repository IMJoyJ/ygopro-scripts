--フェニキシアン・クラスター・アマリリス
-- 效果：
-- 这张卡不用「凤凰花种」或者这张卡的效果不能特殊召唤。这张卡攻击的场合，伤害计算后破坏。自己场上存在的这张卡被破坏送去墓地时，给与对方基本分800分伤害。自己的结束阶段时这张卡在墓地存在的场合，可以把自己墓地存在的1只植物族怪兽从游戏中除外，这张卡从墓地守备表示特殊召唤。
function c23558733.initial_effect(c)
	-- 这张卡不用「凤凰花种」或者这张卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡不能被特殊召唤
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
-- 当此卡为攻击怪兽且未因战斗破坏时，将其破坏
function c23558733.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否为攻击怪兽且未因战斗破坏
	if c==Duel.GetAttacker() and not c:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 将此卡以效果原因破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 判断此卡是否由自己控制且因破坏而送入墓地且原本在场上
function c23558733.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and bit.band(r,REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置伤害效果的目标玩家和伤害值
function c23558733.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为800
	Duel.SetTargetParam(800)
	-- 设置伤害效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果，对目标玩家造成800点伤害
function c23558733.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 筛选墓地中的植物族怪兽作为除外对象
function c23558733.cfilter(c)
	return c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 判断是否为自己的结束阶段
function c23558733.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 设置特殊召唤时的费用，需要除外一只植物族怪兽
function c23558733.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外植物族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c23558733.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的植物族怪兽除外
	local g=Duel.SelectMatchingCard(tp,c23558733.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置特殊召唤的条件，检查是否有足够的召唤区域
function c23558733.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡从墓地特殊召唤
function c23558733.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以守备表示特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,true,false,POS_FACEUP_DEFENSE)
	end
end
