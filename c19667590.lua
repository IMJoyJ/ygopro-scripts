--ゴゴゴギガース
-- 效果：
-- 这张卡在墓地存在，自己对名字带有「隆隆隆」的怪兽的特殊召唤成功的场合，这张卡可以从墓地表侧守备表示特殊召唤。「隆隆隆巨灵」的效果1回合只能使用1次，这个效果发动的回合，自己不能进行战斗阶段。
function c19667590.initial_effect(c)
	-- 创建一个触发效果，当自己对名字带有「隆隆隆」的怪兽特殊召唤成功时发动，将此卡从墓地表侧守备表示特殊召唤
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
-- 检查场上是否存在自己召唤过的、名字带有「隆隆隆」的怪兽
function c19667590.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsSetCard(0x59)
end
-- 判断是否满足特殊召唤成功的条件，即存在自己召唤过的「隆隆隆」怪兽
function c19667590.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c19667590.cfilter,1,nil,tp)
end
-- 设置发动cost，确保发动回合内不能进行战斗阶段
function c19667590.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己在该回合是否已经进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 创建一个使自己不能进入战斗阶段的效果并注册
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能进入战斗阶段的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 设置特殊召唤的条件，确保有足够怪兽区域且此卡可以特殊召唤
function c19667590.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息，确定特殊召唤的卡为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，将此卡以表侧守备表示特殊召唤到场上
function c19667590.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤，将此卡以表侧守备表示特殊召唤到玩家场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
