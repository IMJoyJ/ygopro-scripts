--サイバース・インテグレーター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己的手卡·墓地选1只电子界族调整守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
function c25200959.initial_effect(c)
	-- 为这张卡添加同调召唤手续：1只调整（任意）＋1只以上调整以外的怪兽。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从自己的手卡·墓地选1只电子界族调整守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25200959,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,25200959)
	e1:SetCondition(c25200959.spcon)
	e1:SetTarget(c25200959.sptg)
	e1:SetOperation(c25200959.spop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(25200959,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,25200960)
	e2:SetCondition(c25200959.drcon)
	e2:SetTarget(c25200959.drtg)
	e2:SetOperation(c25200959.drop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡以同调召唤方式成功召唤。
function c25200959.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选条件：电子界族调整怪兽，且可以被效果以表侧守备表示特殊召唤。
function c25200959.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动目标检查：确认自己主要怪兽区有空位，且手卡·墓地存在符合条件的电子界族调整怪兽。
function c25200959.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时判定自己主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动时判定手卡·墓地是否至少存在1只满足spfilter条件的电子界族调整怪兽。
		and Duel.IsExistingMatchingCard(c25200959.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁将从手卡·墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行①效果：从手卡·墓地选1只电子界族调整守备表示特殊召唤；随后给自己附加直到结束阶段不能特殊召唤非电子界族怪兽的自肃效果。
function c25200959.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区是否有可用空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示：请选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只符合条件的电子界族调整怪兽（并过滤王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25200959.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。②：同调召唤的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25200959.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上，对玩家tp（自己）生效，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃判定：不允许特殊召唤非电子界族怪兽。
function c25200959.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- ②效果的发动条件：这张卡从主要怪兽区被送去墓地，且此前是以同调召唤方式召唤的。
function c25200959.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ②效果的目标处理：检查自己能否抽1张卡，并设定抽卡玩家为自己、抽卡数量为1。
function c25200959.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②效果发动时判定：自己是否可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁对象玩家为自己（抽卡玩家）。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为1（抽卡数量）。
	Duel.SetTargetParam(1)
	-- 设置操作信息：本连锁将进行抽1张卡的处理。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行②效果：从当前连锁信息中取出目标玩家和数量，实际进行抽卡。
function c25200959.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 读取当前连锁中之前设置的目标玩家和参数（抽卡玩家与抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p因效果抽取d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
