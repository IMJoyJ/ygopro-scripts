--燦幻昇龍バイデント・ドラギオン
-- 效果：
-- 龙族调整＋调整以外的龙族怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次，②的效果在决斗中只能使用1次。
-- ①：这张卡同调召唤的场合，以自己墓地1只龙族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。
-- ②：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张魔法·陷阱卡破坏。
function c82570174.initial_effect(c)
	-- 添加同调召唤手续：龙族调整+调整以外的龙族怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合，以自己墓地1只龙族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82570174,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,82570174)
	e1:SetCondition(c82570174.spcon)
	e1:SetTarget(c82570174.sptg)
	e1:SetOperation(c82570174.spop)
	c:RegisterEffect(e1)
	-- ②：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82570174,1))  --"这张卡从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_ATTACK+TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,82570175+EFFECT_COUNT_CODE_DUEL)
	e2:SetCondition(c82570174.spcon2)
	e2:SetCost(c82570174.spcost2)
	e2:SetTarget(c82570174.sptg2)
	e2:SetOperation(c82570174.spop2)
	c:RegisterEffect(e2)
	if not c82570174.global_check then
		c82570174.global_check=true
		-- ①：这张卡同调召唤的场合，以自己墓地1只龙族·炎属性怪兽为对象才能发动。那只怪兽特殊召唤。这个回合，自己不是龙族怪兽不能特殊召唤。 / ②：3次以上攻击宣言过的自己·对方回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c82570174.checkop)
		-- 在全局注册用于记录攻击宣言次数的全局效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时的操作：为双方玩家注册表示攻击宣言次数的Flag效果
function c82570174.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 为回合玩家注册一个持续到回合结束的Flag效果，用于记录攻击宣言次数
	Duel.RegisterFlagEffect(tp,82570174,RESET_PHASE+PHASE_END,0,1)
	-- 为非回合玩家注册一个持续到回合结束的Flag效果，用于记录攻击宣言次数
	Duel.RegisterFlagEffect(1-tp,82570174,RESET_PHASE+PHASE_END,0,1)
end
-- 效果①的发动条件：这张卡同调召唤成功
function c82570174.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：自己墓地的龙族·炎属性且可以特殊召唤的怪兽
function c82570174.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查怪兽区域空位及墓地是否存在合法的龙族·炎属性怪兽，并选择其作为对象
function c82570174.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c82570174.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的龙族·炎属性怪兽
		and Duel.IsExistingTarget(c82570174.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只龙族·炎属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c82570174.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，目标为选择的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：特殊召唤作为对象的怪兽，并适用“这个回合，自己不是龙族怪兽不能特殊召唤”的限制
function c82570174.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是龙族怪兽不能特殊召唤。 / ②：3次以上攻击宣言过的自己·对方回合才能发动。 / 这个卡名的②的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置不能特殊召唤的怪兽过滤条件：非龙族怪兽
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsRace),RACE_DRAGON))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的发动条件：本回合攻击宣言次数达到3次以上
function c82570174.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合记录的攻击宣言Flag数量是否大于等于3
	return Duel.GetFlagEffect(tp,82570174)>=3
end
-- 效果②的发动代价：注册决斗中只能使用1次的客户端提示
function c82570174.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	-- 这个卡名的②的效果在决斗中只能使用1次。 / ②：3次以上攻击宣言过的自己·对方回合才能发动。这张卡从墓地特殊召唤。那之后，可以把场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82570174,3))  --"已经使用过「灿幻升龙 双叉戟龙军王」的②的效果"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	-- 注册决斗中只能使用1次的客户端提示效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的发动准备：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c82570174.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位，且墓地的这张卡是否能特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，目标为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将这张卡特殊召唤，之后可以选场上1张魔法·陷阱卡破坏
function c82570174.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍存在于墓地，若成功特殊召唤且场上有魔法·陷阱卡存在，则询问玩家是否进行破坏
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) and Duel.SelectYesNo(tp,aux.Stringid(82570174,2)) then  --"是否选场上1张魔法·陷阱卡破坏？"
		-- 玩家选择场上1张魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
		if #g>0 then
			-- 中断当前效果处理，使后续的破坏处理不与特殊召唤同时进行
			Duel.BreakEffect()
			-- 手动显示被选择卡片的选中动画
			Duel.HintSelection(g)
			-- 破坏选择的魔法·陷阱卡
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
