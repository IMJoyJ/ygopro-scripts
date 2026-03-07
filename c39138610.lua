--アコード・トーカー＠イグニスター
-- 效果：
-- 效果怪兽3只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从自己墓地把攻击力2300的电子界族怪兽尽可能在作为这张卡所连接区的自己场上特殊召唤，这张卡的攻击力上升那个数量×500。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
-- ②：对方把卡的效果发动时，把这张卡所连接区1只自己的连接怪兽解放才能发动。那个发动无效并除外。
local s,id,o=GetID()
-- 初始化卡片效果，设置连接召唤条件、启用复活限制，并注册两个效果：①特殊召唤效果和②无效化效果
function s.initial_effect(c)
	-- 设置该卡必须用至少3只效果怪兽进行连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- 效果①：这张卡连接召唤的场合才能发动。从自己墓地把攻击力2300的电子界族怪兽尽可能在作为这张卡所连接区的自己场上特殊召唤，这张卡的攻击力上升那个数量×500。这个效果的发动后，直到回合结束时自己不能把怪兽特殊召唤。
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
	-- 效果②：对方把卡的效果发动时，把这张卡所连接区1只自己的连接怪兽解放才能发动。那个发动无效并除外。
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
	-- 设置效果②的目标处理函数为aux.nbtg，用于处理连锁无效化和除外操作
	e2:SetTarget(aux.nbtg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：该卡必须是通过连接召唤方式特殊召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的墓地怪兽：攻击力为2300、种族为电子界族、可以特殊召唤
function s.spfilter(c,e,tp,zone)
	return c:IsAttack(2300) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动时的处理：检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	-- 检查场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,zone) end
	-- 设置效果①发动时的操作信息：准备特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①的发动处理：从墓地特殊召唤满足条件的怪兽，并提升自身攻击力
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 获取该卡所连接区的可用位置数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)
	if zone~=0 and ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取满足条件的墓地怪兽组（排除受王家长眠之谷影响的怪兽）
		local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,zone)
		local g=nil
		if tg:GetCount()>ft then
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			g=tg:Select(tp,ft,ft,nil)
		else
			g=tg
		end
		if g:GetCount()>0 then
			-- 遍历选择的怪兽组，依次进行特殊召唤
			for tc in aux.Next(g) do
				-- 特殊召唤单张怪兽，指定位置和召唤方式
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone)
			end
			-- 完成所有特殊召唤步骤
			Duel.SpecialSummonComplete()
			-- 提升自身攻击力，数值为特殊召唤怪兽数量×500
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(g:GetCount()*500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
	-- 设置效果①发动后，直到回合结束时自己不能特殊召唤怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 注册不能特殊召唤的效果
	Duel.RegisterEffect(e1,tp)
end
-- 效果②的发动条件：对方发动卡的效果时，且该卡未被战斗破坏
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	-- 对方发动的连锁可被无效化
	return rp==1-tp and Duel.IsChainNegatable(ev)
end
-- 过滤满足条件的连接怪兽：必须是该卡所连接的怪兽，且未被战斗破坏
function s.cfilter(c,g)
	return c:IsType(TYPE_LINK)
		and g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 效果②的发动成本：选择并解放一张连接怪兽
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否有满足条件的连接怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,lg) end
	-- 选择一张满足条件的连接怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,lg)
	-- 将选中的连接怪兽解放作为发动成本
	Duel.Release(g,REASON_COST)
end
-- 效果②的发动处理：无效对方发动的效果并除外
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效对方发动的效果且该卡仍在场上
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将无效化的卡从场上除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
