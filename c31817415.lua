--アームド・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「武装龙」怪兽
-- 这张卡不用融合召唤不能特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。选自己墓地1只龙族怪兽，持有那个等级以下的等级的对方场上的怪兽全部破坏。
-- ②：这张卡战斗破坏怪兽时才能发动。这张卡得到以下效果。
-- ●双方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。
function c31817415.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：素材为「元素英雄 新宇侠」（卡号89943723）与1只「武装龙」怪兽（IsFusionSetCard 0x111），sub/insf参数均启用。
	aux.AddFusionProcCodeFun(c,89943723,aux.FilterBoolFunction(Card.IsFusionSetCard,0x111),1,true,true)
	-- 这张卡不用融合召唤不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 将该特殊召唤条件效果的判定函数设为aux.fuslimit：只有以融合召唤（SUMMON_TYPE_FUSION）方式才能特殊召唤这张卡。
	e0:SetValue(aux.fuslimit)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合才能发动。选自己墓地1只龙族怪兽，持有那个等级以下的等级的对方场上的怪兽全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31817415,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c31817415.destg)
	e1:SetOperation(c31817415.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽时才能发动。这张卡得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c31817415.regcon)
	e2:SetOperation(c31817415.regop)
	c:RegisterEffect(e2)
	-- ●双方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「元素英雄」融合怪兽无视召唤条件特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31817415,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(c31817415.spcon)
	e3:SetCost(c31817415.spcost)
	e3:SetTarget(c31817415.sptg)
	e3:SetOperation(c31817415.spop)
	c:RegisterEffect(e3)
end
c31817415.material_setcode=0x8
-- 定义墓地龙族怪兽的筛选条件：该怪兽是龙族且等级≥1，且对方场上有表侧表示、等级≤该龙族怪兽等级的怪兽，以保证①效果可以选择并破坏目标。
function c31817415.filter(c,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevelAbove(1)
		-- 进一步要求对方场上存在至少1只等级不大于候选龙族怪兽等级的表侧表示怪兽，满足①效果可破坏的条件。
		and Duel.IsExistingMatchingCard(c31817415.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
-- 定义①效果破坏对象的筛选条件：对方场上的表侧表示怪兽，且等级不超过选定龙族怪兽的等级。
function c31817415.desfilter(c,lv)
	return c:IsFaceup() and c:IsLevelBelow(lv)
end
-- ①效果发动时：从自己墓地选出所有符合条件的龙族怪兽并取其中最高等级；再把对方场上所有表侧表示且等级≤该最高等级的怪兽登记为破坏对象（实际选择的墓地龙族怪兽在处理时进行）。
function c31817415.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有满足c31817415.filter条件的龙族怪兽组，用于判断是否可发动①效果。
	local g=Duel.GetMatchingGroup(c31817415.filter,tp,LOCATION_GRAVE,0,nil,tp)
	if chk==0 then return #g>0 end
	local _,lv=g:GetMaxGroup(Card.GetLevel)
	-- 根据候选墓地龙族怪兽的最高等级lv，获取对方场上所有表侧表示且等级≤lv的怪兽组，作为预计破坏的范围。
	local dg=Duel.GetMatchingGroup(c31817415.desfilter,tp,0,LOCATION_MZONE,nil,lv)
	-- 将本次连锁的破坏操作信息登记为dg、数量1，供后续效果检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,0,0)
end
-- ①效果处理时：从符合条件的墓地龙族怪兽中选择1只，并破坏对方场上所有表侧表示且等级≤该龙族怪兽等级的怪兽。
function c31817415.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时重新获取自己墓地中所有符合条件的龙族怪兽组，供实际选择1只。
	local g=Duel.GetMatchingGroup(c31817415.filter,tp,LOCATION_GRAVE,0,nil,tp)
	if #g==0 then return end
	-- 向发动玩家显示“请选择要操作的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local tg=g:Select(tp,1,1,nil)
	-- 为被选中的墓地龙族怪兽播放“被选择为对象”的动画，并将该卡记录为对象。
	Duel.HintSelection(tg)
	-- 根据实际选择的墓地龙族怪兽的等级，获取对方场上所有表侧表示且等级≤该等级的怪兽组。
	local dg=Duel.GetMatchingGroup(c31817415.desfilter,tp,0,LOCATION_MZONE,nil,tg:GetFirst():GetLevel())
	-- 以效果原因破坏上一步得到的全部对象怪兽。
	Duel.Destroy(dg,REASON_EFFECT)
end
-- ②效果发动条件：这张卡仍在战斗关联中、且尚未获得过后续效果标记（flag 31817416），避免重复获得。
function c31817415.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetFlagEffect(31817416)==0
end
-- ②效果处理：若此卡仍表侧表示且与当前连锁有关，则给它设置flag 31817416，并附带“「武装新宇侠」效果适用中”的客户端提示；flag持续到离场/回手/回卡组等标准重置。
function c31817415.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		c:RegisterFlagEffect(31817416,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31817415,2))  --"「武装新宇侠」效果适用中"
	end
end
-- 后续效果（●）的发动条件：此卡已通过②获得flag 31817416，并且当前是我方或对方的主要阶段。
function c31817415.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回此卡是否已有31817416标记且当前阶段为主要阶段1或主要阶段2。
	return c:GetFlagEffect(31817416)>0 and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- ③效果发动代价：解放此卡，同时额外卡组存在至少1只可被选择并特殊召唤的「元素英雄」融合怪兽。
function c31817415.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable()
		-- 代价追加检查：额外卡组存在至少1只满足spfilter条件的「元素英雄」融合怪兽，确保可以特殊召唤。
		and Duel.IsExistingMatchingCard(c31817415.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 解放此卡作为发动③效果的cost（作为cost不检查是否免疫效果）。
	Duel.Release(c,REASON_COST)
end
-- 定义可被③效果特殊召唤的怪兽条件：属于「元素英雄」字段的融合怪兽，解除此卡后额外怪兽区有空格，且能够被无视召唤条件特殊召唤。
function c31817415.spfilter(c,e,tp,rc)
	-- 限定为「元素英雄」字段（0x3008）的融合怪兽，且解除此卡后拥有可供额外卡组怪兽上场的空格。
	return c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION) and Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- ③效果发动目标：由于cost已确认存在可特殊召唤对象，这里直接允许发动，并在连锁中登记“从额外卡组特殊召唤1只怪兽”的操作信息。
function c31817415.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将特殊召唤的操作信息登记为从额外卡组特召1只怪兽（因为对象在效果处理时才确定，所以targets为nil），供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ③效果处理：从额外卡组选择1只符合条件的「元素英雄」融合怪兽，无视召唤条件以表侧攻击表示特殊召唤。
function c31817415.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时获取额外卡组中所有满足spfilter的「元素英雄」融合怪兽组。
	local g=Duel.GetMatchingGroup(c31817415.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,nil)
	if #g==0 then return end
	-- 向发动玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选中的融合怪兽以表侧攻击表示特殊召唤到玩家场上，nocheck=true表示不检查召唤条件，nolimit=false表示仍受苏生限制约束。
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
end
