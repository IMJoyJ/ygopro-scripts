--雷帝家臣ミスラ
-- 效果：
-- 「雷帝家臣 密特拉」的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡特殊召唤，在对方场上把1只「家臣衍生物」（雷族·光·1星·攻800/守1000）守备表示特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡为上级召唤而被解放的场合才能发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
function c22404675.initial_effect(c)
	-- 「雷帝家臣 密特拉」的①②的效果1回合各能使用1次。①：自己主要阶段才能发动。这张卡从手卡特殊召唤，在对方场上把1只「家臣衍生物」（雷族·光·1星·攻800/守1000）守备表示特殊召唤。这个回合，自己不能从额外卡组把怪兽特殊召唤。
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
-- ①效果的发动条件判定：确认自己场上和对方场上均有可用的怪兽区域、此卡可被特殊召唤、且自己可特殊召唤「家臣衍生物」，同时没有「青眼精灵龙」的“不能将2只以上怪兽同时特殊召唤”效果适用。
function c22404675.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己的主要怪兽区域是否有空位，用于从手卡特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方的主要怪兽区域是否有空位，用于在对方场上特殊召唤「家臣衍生物」。
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己是否可以将「家臣衍生物」（卡号22404676）以表侧守备表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,22404676,0,TYPES_TOKEN_MONSTER,800,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) end
	-- 设置本次效果处理涉及衍生物（CATEGORY_TOKEN）的操作信息，数量为1，供连锁检测等使用。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本次效果处理涉及特殊召唤（CATEGORY_SPECIAL_SUMMON）的操作信息，数量为2（此卡与衍生物）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- ①效果处理：通过连续特殊召唤步骤，先特殊召唤这张卡；成功后若对方场上有空位且满足衍生物特殊召唤条件，则在对方场上特殊召唤1只「家臣衍生物」，最后统一完成特殊召唤结算。
function c22404675.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 作为连续特殊召唤的第一步，将这张卡以表侧表示特殊召唤；若成功则继续处理衍生物。
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 确认对方场上存在可用的主要怪兽区域空格（以tp视角计算对方区域），用于在对方场上特殊召唤衍生物。
			if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				and Duel.IsPlayerCanSpecialSummonMonster(tp,22404676,0,TYPES_TOKEN_MONSTER,800,1000,1,RACE_THUNDER,ATTRIBUTE_LIGHT,POS_FACEUP_DEFENSE) and not Duel.IsPlayerAffectedByEffect(tp,59822133) then
				-- 创建1只衍生物「家臣衍生物」（卡号22404676）。
				local token=Duel.CreateToken(tp,22404676)
				-- 将衍生物以表侧守备表示特殊召唤到对方（1-tp）的场上，作为连续特殊召唤的一步。
				Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			end
		end
		-- 结束连续特殊召唤处理，统一结算本次特殊召唤。
		Duel.SpecialSummonComplete()
	end
	-- 这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c22404675.splimit)
	-- 将上述“不能从额外卡组把怪兽特殊召唤”的自肃效果注册到全场，对玩家tp生效，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定函数：只禁止从额外卡组（LOCATION_EXTRA）进行的特殊召唤。
function c22404675.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- ②效果发动条件：这张卡因上级召唤被解放，且当前回合玩家为自己。
function c22404675.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定被解放的理由为上级召唤（REASON_SUMMON），且当前回合玩家是自己，以此满足②的发动条件。
	return e:GetHandler():IsReason(REASON_SUMMON) and Duel.GetTurnPlayer()==tp
end
-- ②效果发动前确认：自己当前可以通常召唤，并且拥有额外的通常召唤次数可供追加。
function c22404675.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0），返回自己可以进行通常召唤且拥有追加通常召唤机会，以决定能否发动②效果。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp) end
end
-- ②效果处理：若本回合尚未使用过该效果，则给己方增加1次额外的通常召唤次数（可用于上级召唤）和1次额外的盖放（覆盖怪兽）次数，持续到回合结束；同时记录已使用标志。
function c22404675.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方已在本回合使用过②效果（存在对应flag），则不再重复追加次数。
	if Duel.GetFlagEffect(tp,22404675)~=0 then return end
	-- 这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以上级召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(22404675,0))  --"使用「雷帝家臣 密特拉」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将增加1次通常召唤次数的效果注册到己方，使己方本回合可以多进行1次通常召唤（包括上级召唤）。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 将对应的增加1次盖放（覆盖怪兽）次数的效果注册，使己方本回合也能多盖放1只怪兽。
	Duel.RegisterEffect(e2,tp)
	-- 为tp注册一个回合标识（22404675），表示本回合已使用过②效果，防止同一回合重复使用。
	Duel.RegisterFlagEffect(tp,22404675,RESET_PHASE+PHASE_END,0,1)
end
