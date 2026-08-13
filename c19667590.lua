--ゴゴゴギガース
-- 效果：
-- 这张卡在墓地存在，自己对名字带有「隆隆隆」的怪兽的特殊召唤成功的场合，这张卡可以从墓地表侧守备表示特殊召唤。「隆隆隆巨灵」的效果1回合只能使用1次，这个效果发动的回合，自己不能进行战斗阶段。
function c19667590.initial_effect(c)
	-- 这张卡在墓地存在，自己对名字带有「隆隆隆」的怪兽的特殊召唤成功的场合，这张卡可以从墓地表侧守备表示特殊召唤。「隆隆隆巨灵」的效果1回合只能使用1次，这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19667590,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,19667590)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c19667590.spcon)
	e1:SetCost(c19667590.spcost)
	e1:SetTarget(c19667590.sptg)
	e1:SetOperation(c19667590.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：用于筛选特殊召唤成功的怪兽中是否存在表侧表示、由效果持有者特殊召唤、且卡名带有「隆隆隆」的怪兽。
function c19667590.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x59)
end
-- 效果发动条件：当特殊召唤成功的怪兽组中存在满足条件的「隆隆隆」怪兽时，本卡在墓地可以发动。
function c19667590.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19667590.cfilter,1,nil,tp)
end
-- 发动代价（含誓约）：只有本回合尚未进入过战斗阶段才能发动；发动后为本回合自己附加“不能进行战斗阶段”的限制，该限制持续到回合结束。
function c19667590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：本回合自己尚未进入过战斗阶段（否则不能发动）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 这张卡可以从墓地表侧守备表示特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己不能进行战斗阶段”的誓约效果注册给玩家tp，从此刻起本回合内生效。
	Duel.RegisterEffect(e1,tp)
end
-- 效果发动时的合法性检查：要求自己场上有可用的主要怪兽区空位，且墓地的这张卡可以被特殊召唤为表侧守备表示；满足时登记特殊召唤本卡的操作信息。
function c19667590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件之一：自己场上存在可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 登记本次连锁将特殊召唤本卡的操作信息，数量为1，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡仍与发动时的效果保持关联，则将其以表侧守备表示特殊召唤到自己场上。
function c19667590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 实际执行特殊召唤：将这张卡以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
