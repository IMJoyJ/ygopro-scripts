--サイバース・インテグレーター
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己的手卡·墓地选1只电子界族调整守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：同调召唤的这张卡被送去墓地的场合才能发动。自己从卡组抽1张。
function c25200959.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调
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
-- 判断此卡是否为同调召唤成功
function c25200959.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的电子界族调整怪兽，用于特殊召唤
function c25200959.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位和手牌/墓地是否存在符合条件的怪兽
function c25200959.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c25200959.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽，并设置后续不能特殊召唤非电子界族怪兽的效果
function c25200959.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的电子界族调整怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25200959.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 设置并注册不能特殊召唤非电子界族怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c25200959.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家环境中
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能特殊召唤非电子界族怪兽的限制条件
function c25200959.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 判断此卡是否为同调召唤且从场上送去墓地
function c25200959.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置抽卡操作信息
function c25200959.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量
	Duel.SetTargetParam(1)
	-- 设置抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 处理抽卡效果
function c25200959.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
