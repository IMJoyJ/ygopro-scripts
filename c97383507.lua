--ダークナイト＠イグニスター
-- 效果：
-- 卡名不同的怪兽3只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡所连接区有怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。从自己墓地把4星以下的「@火灵天星」怪兽尽可能在作为这张卡所连接区的自己场上效果无效特殊召唤。
-- ②：这张卡战斗破坏对方怪兽时才能发动。从自己墓地选1只电子界族怪兽特殊召唤。
function c97383507.initial_effect(c)
	-- 设置连接召唤手续，需要3只怪兽作为素材，且素材需满足lcheck过滤条件。
	aux.AddLinkProcedure(c,nil,3,3,c97383507.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡所连接区有怪兽特殊召唤的场合才能发动（伤害步骤也能发动）。从自己墓地把4星以下的「@火灵天星」怪兽尽可能在作为这张卡所连接区的自己场上效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97383507,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,97383507)
	e1:SetCondition(c97383507.spcon1)
	e1:SetTarget(c97383507.sptg1)
	e1:SetOperation(c97383507.spop1)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。从自己墓地选1只电子界族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97383507,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCountLimit(1,97383508)
	-- 设置发动条件为这张卡战斗破坏对方怪兽。
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c97383507.sptg2)
	e2:SetOperation(c97383507.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查连接素材的卡名是否互不相同。
function c97383507.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 过滤函数：检查特殊召唤的怪兽是否在这张卡的所连接区。
function c97383507.cfilter(c,lg)
	return lg:IsContains(c)
end
-- 效果①的发动条件：检查本次特殊召唤的怪兽中是否存在于这张卡所连接区的怪兽。
function c97383507.spcon1(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c97383507.cfilter,1,nil,lg)
end
-- 过滤函数：检索自己墓地4星以下且能特殊召唤到指定所连接区的「@火灵天星」怪兽。
function c97383507.spfilter1(c,e,tp,zone)
	return c:IsLevelBelow(4) and c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动准备与可行性检查。
function c97383507.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的「@火灵天星」怪兽。
		and Duel.IsExistingMatchingCard(c97383507.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 注册连锁处理中的操作信息：从墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的效果处理：将墓地满足条件的怪兽尽可能在所连接区效果无效特殊召唤。
function c97383507.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 获取自己场上指定所连接区内可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if zone==0 or ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取自己墓地中满足过滤条件且不受「王家之谷」影响的「@火灵天星」怪兽组。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c97383507.spfilter1),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
	local g=nil
	if tg:GetCount()>ft then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将怪兽以表侧表示特殊召唤到指定的所连接区（分步处理）。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
		-- 完成分步特殊召唤的处理。
		Duel.SpecialSummonComplete()
	end
end
-- 过滤函数：检索自己墓地的电子界族怪兽。
function c97383507.spfilter2(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与可行性检查。
function c97383507.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件的电子界族怪兽。
		and Duel.IsExistingMatchingCard(c97383507.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 注册连锁处理中的操作信息：从墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：从自己墓地选择1只电子界族怪兽特殊召唤。
function c97383507.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只不受「王家之谷」影响的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c97383507.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
