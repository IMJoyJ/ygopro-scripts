--スターダスト・トレイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的怪兽被解放的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：用这张卡为同调素材把「战士」、「同调士」、「星尘」同调怪兽之内任意种同调召唤的场合才能发动。在自己场上把1只「星尘衍生物」（龙族·光·1星·攻/守0）特殊召唤。
function c63184227.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上的怪兽被解放的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63184227,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,63184227)
	e1:SetCondition(c63184227.spcon)
	e1:SetTarget(c63184227.sptg)
	e1:SetOperation(c63184227.spop)
	c:RegisterEffect(e1)
	-- ②：用这张卡为同调素材把「战士」、「同调士」、「星尘」同调怪兽之内任意种同调召唤的场合才能发动。在自己场上把1只「星尘衍生物」（龙族·光·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63184227,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,63184228)
	e2:SetCondition(c63184227.tkcon)
	e2:SetTarget(c63184227.tktg)
	e2:SetOperation(c63184227.tkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：被解放的怪兽原本在自己场上的怪兽区域存在
function c63184227.spcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 发动条件：自己场上的怪兽被解放，且如果这张卡在墓地，则被解放的怪兽中不能包含这张卡自身
function c63184227.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (not eg:IsContains(c) or c:IsLocation(LOCATION_HAND)) and eg:IsExists(c63184227.spcfilter,1,nil,tp)
end
-- 效果发动目标：检查自身是否可以特殊召唤，并注册特殊召唤的操作信息
function c63184227.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将自身特殊召唤，并添加离场时除外的限制
function c63184227.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 尝试将自身以表侧表示特殊召唤（分解步骤）
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
			e1:SetValue(LOCATION_REMOVED)
			c:RegisterEffect(e1)
		end
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
	end
end
-- 发动条件：作为同调素材，且同调召唤的怪兽是「战士」、「同调士」或「星尘」怪兽
function c63184227.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and e:GetHandler():GetReasonCard():IsSetCard(0x66,0x1017,0xa3)
end
-- 效果发动目标：检查是否能特殊召唤衍生物，并注册特殊召唤和衍生物的操作信息
function c63184227.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定的「星尘衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,63184228,0xa3,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_LIGHT) end
	-- 设置连锁信息，表明此效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息，表明此效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：在自己场上特殊召唤1只「星尘衍生物」
function c63184227.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 或者如果不能特殊召唤指定的「星尘衍生物」则不处理
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,63184228,0xa3,TYPES_TOKEN_MONSTER,0,0,1,RACE_DRAGON,ATTRIBUTE_LIGHT) then return end
	-- 创建「星尘衍生物」卡片数据
	local token=Duel.CreateToken(tp,63184228)
	-- 将创建的衍生物以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
