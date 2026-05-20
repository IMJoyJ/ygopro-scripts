--剛鬼死闘
-- 效果：
-- ①：作为这张卡的发动时的效果处理，给这张卡放置3个指示物。
-- ②：自己的「刚鬼」怪兽战斗破坏对方怪兽的场合发动。这张卡1个指示物取除。
-- ③：这张卡的效果给这张卡放置的指示物全部被取除的战斗阶段结束时才能由自己把这个效果发动。从手卡·卡组把「刚鬼」怪兽尽可能特殊召唤（同名卡最多1张）。那之后，给这张卡放置3个指示物。
function c85638822.initial_effect(c)
	c:EnableCounterPermit(0x46)
	-- ①：作为这张卡的发动时的效果处理，给这张卡放置3个指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85638822.target)
	e1:SetOperation(c85638822.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「刚鬼」怪兽战斗破坏对方怪兽的场合发动。这张卡1个指示物取除。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85638822,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c85638822.rccon)
	e2:SetOperation(c85638822.rcop)
	c:RegisterEffect(e2)
	-- ③：这张卡的效果给这张卡放置的指示物全部被取除的战斗阶段结束时才能由自己把这个效果发动。从手卡·卡组把「刚鬼」怪兽尽可能特殊召唤（同名卡最多1张）。那之后，给这张卡放置3个指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85638822,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c85638822.spcon)
	e3:SetTarget(c85638822.sptg)
	e3:SetOperation(c85638822.spop)
	c:RegisterEffect(e3)
end
-- 卡片发动时的效果处理（放置指示物）的发动准备函数，检查能否放置指示物并设置操作信息
function c85638822.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查当前能否向这张卡放置3个刚鬼指示物
	if chk==0 then return Duel.IsCanAddCounter(tp,0x46,3,e:GetHandler()) end
	-- 设置连锁的操作信息，表示该效果的处理包含放置3个刚鬼指示物
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,0,0x46)
end
-- 卡片发动时的效果处理（放置指示物）的执行函数，若此卡仍在场上则为其放置3个刚鬼指示物
function c85638822.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:AddCounter(0x46,3)
	end
end
-- 效果②的发动条件：战斗破坏对方怪兽的怪兽必须是自己场上表侧表示的「刚鬼」怪兽
function c85638822.rccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=eg:GetFirst()
	return rc:IsRelateToBattle() and rc:IsStatus(STATUS_OPPO_BATTLE)
		and rc:IsFaceup() and rc:IsSetCard(0xfc) and rc:IsControler(tp)
end
-- 效果②的效果处理：取除这张卡的1个刚鬼指示物，并为这张卡注册一个在当前战斗阶段内有效的标记，用于记录本阶段内曾有指示物被取除
function c85638822.rcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RemoveCounter(tp,0x46,1,REASON_EFFECT)
		c:RegisterFlagEffect(85638822,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,0)
	end
end
-- 效果③的发动条件：这张卡上的刚鬼指示物数量为0，且在当前战斗阶段内曾有指示物被取除
function c85638822.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetCounter(0x46)==0 and c:GetFlagEffect(85638822)>0
end
-- 过滤函数，用于筛选手卡或卡组中可以特殊召唤的「刚鬼」怪兽
function c85638822.spfilter(c,e,sp)
	return c:IsSetCard(0xfc) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 效果③的发动准备：检查自己场上是否有可用的怪兽区域，以及手卡或卡组中是否存在可特殊召唤的「刚鬼」怪兽
function c85638822.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有至少1个空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己的手卡或卡组中是否存在至少1只满足特殊召唤条件的「刚鬼」怪兽
		and Duel.IsExistingMatchingCard(c85638822.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表示该效果的处理包含从手卡或卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND+LOCATION_DECK)
end
-- 效果③的效果处理：从手卡或卡组中选择尽可能多且卡名各不相同的「刚鬼」怪兽特殊召唤，若成功特殊召唤，则给这张卡放置3个刚鬼指示物
function c85638822.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上当前可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取手卡和卡组中所有满足特殊召唤条件的「刚鬼」怪兽集合
	local tg=Duel.GetMatchingGroup(c85638822.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil,e,tp)
	if tg:GetCount()==0 or ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=math.min(tg:GetClassCount(Card.GetCode),ft)
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从满足条件的怪兽中，选择数量等于可召唤上限且卡名互不相同的怪兽组合
	local g=tg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选中的怪兽以表侧表示特殊召唤，若成功特殊召唤了至少1只，则执行后续处理
	if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		c:AddCounter(0x46,3)
	end
end
