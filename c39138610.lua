--アコード・トーカー＠イグニスター
-- 效果：
-- 效果怪兽3只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己墓地把攻击力2300的电子界族怪兽尽可能在作为这张卡所连接区的自己场上特殊召唤，这张卡的攻击力上升那个数量×500。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：对方把卡的效果发动时，把这张卡所连接区1只自己的连接怪兽解放才能发动。那个发动无效并除外。
local s,id,o=GetID()
-- 初始化卡片效果：先添加连接召唤手续（效果怪兽3只以上），再注册①诱发效果（连接召唤成功时从墓地特殊召唤攻击力2300电子界族怪兽并提升攻击力、附带自肃）和②诱发即时效果（对方发动卡的效果时解放连接区的连接怪兽来无效并除外）。
function s.initial_effect(c)
	-- 添加连接召唤手续：这张卡需用3只以上的效果怪兽作为连接素材（对应效果原文‘效果怪兽3只以上’）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。从自己墓地把攻击力2300的电子界族怪兽尽可能在作为这张卡所连接区的自己场上特殊召唤，这张卡的攻击力上升那个数量×500。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：对方把卡的效果发动时，把这张卡所连接区1只自己的连接怪兽解放才能发动。那个发动无效并除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	-- 设置②效果的Target函数为通用无效并除外函数aux.nbtg：负责检查对方效果发动是否满足无效条件，并设置无效/除外的操作信息（若对方效果在墓地发动还会追加墓地操作分类）。
	e2:SetTarget(aux.nbtg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡以连接召唤方式特殊召唤成功时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 定义可特殊召唤的墓地怪兽条件：攻击力2300、电子界族、且能被当前效果由己方玩家特殊召唤到指定连接区（表侧表示）。
function s.spfilter(c,e,tp,zone)
	return c:IsAttack(2300) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的Target函数：先计算这张卡的连接区在主怪兽区域的可用区域zone，并在发动条件检查时确认己方有可用主怪兽区空格且墓地存在符合条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 发动合法性检查（chk==0）：自己的主要怪兽区域存在可用空格，才能特殊召唤到连接区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且墓地存在至少1只满足s.spfilter（攻击力2300、电子界族、可特殊召唤到连接区）的怪兽时，发动条件成立。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 设置操作信息：标明本效果将进行特殊召唤，预计从墓地特殊召唤1只怪兽到己方场上，供连锁中其他卡片的发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ①效果处理：计算连接区可用空格数ft；若青眼精灵龙效果适用中则ft变为1；从墓地筛选满足条件的怪兽组tg，若tg数量超过ft则选择ft张，否则全部选择；依次特殊召唤到连接区，完成后这张卡攻击力上升召唤数量×500；最后无论是否特召成功，都给自己附加直到回合结束不能特殊召唤怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 计算这张卡所连接区中己方主要怪兽区域的可用空格数量ft，作为本次最多可特殊召唤的怪兽数（后续可能受青眼精灵龙等效果限制）。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if zone~=0 and ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 从墓地取得满足s.spfilter（攻击力2300、电子界族、可特殊召唤）的怪兽组，并用NecroValleyFilter排除受王家长眠之谷影响而不能特殊召唤的卡。
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
		local g=nil
		if tg:GetCount()>ft then
			-- 当可选怪兽数量超过可召唤空格数时，弹出“请选择要特殊召唤的卡”的提示，由玩家选择其中ft张进行特殊召唤。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=tg:Select(tp,ft,ft,nil)
		else
			g=tg
		end
		if g:GetCount()>0 then
			-- 使用迭代器遍历选中的怪兽组g中的每一张怪兽，准备逐张进行特殊召唤。
			for tc in aux.Next(g) do
				-- 将当前怪兽作为特殊召唤的一步，以表侧表示特殊召唤到这张卡的连接区（zone），不检查召唤条件也不检查苏生限制。
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
			end
			-- 完成本次连锁中的所有特殊召唤步骤，统一处理这些怪兽特殊召唤成功时的时点与诱发效果。
			Duel.SpecialSummonComplete()
			-- 这张卡的攻击力上升那个数量×500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(g:GetCount()*500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。②：对方把卡的效果发动时，把这张卡所连接区1只自己的连接怪兽解放才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将自肃效果注册到场上：己方玩家直到回合结束不能进行任何怪兽的特殊召唤。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的发动条件：这张卡未被战斗破坏，且对方发动了卡的效果，并且该效果发动可以被无效。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 确认当前连锁的发动者是对手玩家（rp==1-tp）且该连锁可以被无效（Duel.IsChainNegatable）。
	return rp==1-tp and Duel.IsChainNegatable(ev)
end
-- 定义可解放怪兽的过滤条件：是连接怪兽、位于这张卡的连接区（g）中、且未被战斗破坏。
function s.cfilter(c,g)
	return c:IsType(TYPE_LINK)
		and g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的发动代价：从这张卡所连接区中选择1只自己的连接怪兽解放；需要先检查是否存在满足条件的可解放怪兽。
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 代价合法性检查（chk==0）：自己场上是否存在至少1只满足s.cfilter的连接怪兽可以解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg) end
	-- 从自己场上选择1只满足s.cfilter的连接怪兽作为发动代价。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg)
	-- 将选择的连接怪兽以COST形式解放，完成代价支付。
	Duel.Release(g,REASON_COST)
end
-- ②效果处理：无效对方发动的效果，若无效成功且发动效果的那张卡仍与效果关联，则将其除外。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断无效是否成功，且对方效果发动的卡仍与效果保持关联（IsRelateToEffect为真）时，才继续执行除外。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的卡以表侧表示除外。
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
