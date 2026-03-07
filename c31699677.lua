--マジクリボー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：战斗或者对方的效果让自己受到伤害的回合的主要阶段以及战斗阶段，把这张卡从手卡送去墓地才能发动。从自己的卡组·墓地选1只「黑魔术师」或者「黑魔术少女」特殊召唤。这个效果在对方回合也能发动。
-- ②：自己场上的表侧表示的魔法师族怪兽被战斗或者对方的效果破坏的场合才能发动。墓地的这张卡加入手卡。
function c31699677.initial_effect(c)
	-- 记录该卡牌具有「黑魔术师」和「黑魔术少女」的卡名信息
	aux.AddCodeList(c,46986414,38033121)
	-- ①：战斗或者对方的效果让自己受到伤害的回合的主要阶段以及战斗阶段，把这张卡从手卡送去墓地才能发动。从自己的卡组·墓地选1只「黑魔术师」或者「黑魔术少女」特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31699677,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31699677)
	e1:SetCost(c31699677.spcost)
	e1:SetCondition(c31699677.spcon)
	e1:SetTarget(c31699677.sptg)
	e1:SetOperation(c31699677.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的魔法师族怪兽被战斗或者对方的效果破坏的场合才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31699677,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,31699676)
	e2:SetCondition(c31699677.thcon)
	e2:SetTarget(c31699677.thtg)
	e2:SetOperation(c31699677.thop)
	c:RegisterEffect(e2)
	if not c31699677.global_check then
		c31699677.global_check=true
		-- 创建一个全局持续效果，用于检测是否受到过伤害
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c31699677.checkop)
		-- 将效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断是否因战斗或对方效果受到伤害
function c31699677.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (bit.band(r,REASON_EFFECT)~=0 and rp==1-ep) or bit.band(r,REASON_BATTLE)~=0 then
		-- 为玩家注册一个标识效果，表示该玩家在本回合受到过伤害
		Duel.RegisterFlagEffect(ep,31699677,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 支付效果的费用，将自身送去墓地
function c31699677.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身从手牌送去墓地作为发动效果的费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 判断是否满足①效果的发动条件
function c31699677.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2)
		-- 检查是否已记录受到伤害的标识
		and Duel.GetFlagEffect(tp,31699677)~=0
end
-- 定义过滤函数，用于筛选「黑魔术师」或「黑魔术少女」
function c31699677.spfilter(c,e,tp)
	return c:IsCode(46986414,38033121) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置①效果的目标
function c31699677.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组或墓地是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c31699677.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 执行①效果的处理
function c31699677.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c31699677.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义过滤函数，用于筛选被破坏的魔法师族怪兽
function c31699677.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:GetPreviousRaceOnField()&RACE_SPELLCASTER~=0 and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断②效果是否满足发动条件
function c31699677.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c31699677.cfilter,1,nil,tp)
end
-- 设置②效果的目标
function c31699677.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息，表示将要回手
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行②效果的处理
function c31699677.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
