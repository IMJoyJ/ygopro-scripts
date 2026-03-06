--雷帝家臣ミスラ
-- 效果：
-- 「雷帝家臣 密特拉」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤，在对方场上把1只「家臣衍生物」（雷族·光·1星·攻800/守1000）守备表示特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
function c22404675.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤，在对方场上把1只「家臣衍生物」（雷族·光·1星·攻800/守1000）守备表示特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,22404675)
	e1:SetTarget(c22404675.sptg)
	e1:SetOperation(c22404675.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡为上级召唤而被解放的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetCountLimit(1,22404676)
	e2:SetCondition(c22404675.sumcon)
	e2:SetTarget(c22404675.sumtg)
	e2:SetOperation(c22404675.sumop)
	c:RegisterEffect(e2)
end
-- 检测是否满足①效果的发动条件，包括：自己未被【青眼精灵龙】影响、自己和对方场上都有空位、自身可特殊召唤、可特殊召唤衍生物。
function c22404675.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测自己场上是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测对方场上是否有空位。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检测是否可以特殊召唤衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22404676,0,TYPES_TOKEN_MONSTER,800,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：将要特殊召唤1只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤2张卡（自身+衍生物）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果的处理函数，执行特殊召唤自身和衍生物的操作。
function c22404675.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 特殊召唤自身到自己场上。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 检测对方场上是否有空位。
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and Duel.IsPlayerCanSpecialSummonMonster(tp,22404676,0,TYPES_TOKEN_MONSTER,800,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
				-- 创建1只家臣衍生物。
				local token=Duel.CreateToken(tp,22404676)
				-- 特殊召唤衍生物到对方场上。
				Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
	end
	-- ①效果的处理函数：设置自己本回合不能从额外卡组特殊召唤的限制。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c22404675.splimit)
	-- 注册不能特殊召唤的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的处理函数：禁止从额外卡组特殊召唤。
function c22404675.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件函数：判断是否为上级召唤而被解放且为自己的回合。
function c22404675.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为上级召唤而被解放且为自己的回合。
	return e:GetHandler():IsReason(REASON_SUMMON) and Duel.GetTurnPlayer()==tp
end
-- ②效果的目标函数：检测是否可以进行通常召唤和上级召唤。
function c22404675.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否可以进行通常召唤和上级召唤。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- ②效果的处理函数：设置本回合可以上级召唤一次。
function c22404675.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否已使用过②效果。
	if Duel.GetFlagEffect(tp,22404675)~=0 then return end
	-- ②效果的处理函数：设置本回合可以上级召唤一次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(22404675,0))  --"使用「雷帝家臣 密特拉」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册上级召唤次数增加的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 注册设置次数增加的效果。
	Duel.RegisterEffect(e2,tp)
	-- 注册标识效果，防止②效果重复使用。
	Duel.RegisterFlagEffect(tp,22404675,RESET_PHASE+PHASE_END,0,1)
end
