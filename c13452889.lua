--ベクター・スケア・デーモン
-- 效果：
-- 电子界族怪兽2只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地时，把这张卡所连接区1只自己怪兽解放才能发动。破坏的那只怪兽在作为这张卡所连接区的自己·对方场上特殊召唤。这个效果在对方场上把怪兽特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
function c13452889.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用至少2个电子界族连接素材进行连接召唤
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时，把这张卡所连接区1只自己怪兽解放才能发动。破坏的那只怪兽在作为这张卡所连接区的自己·对方场上特殊召唤。这个效果在对方场上把怪兽特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13452889,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为：本次战斗中己方怪兽破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetCost(c13452889.spcost)
	e1:SetTarget(c13452889.sptg)
	e1:SetOperation(c13452889.spop)
	c:RegisterEffect(e1)
end
-- 定义用于筛选可解放怪兽的过滤函数，检查怪兽是否在连接区且有可用怪兽区
function c13452889.cfilter(c,tp,g,zone)
	-- 检查指定玩家在指定区域是否有可用怪兽区
	return g:IsContains(c) and (Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone[tp])>0
		-- 检查对方玩家在指定区域是否有可用怪兽区
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1-tp])>0)
end
-- 定义效果的解放费用处理函数
function c13452889.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone={}
	zone[0]=c:GetLinkedZone(0)
	zone[1]=c:GetLinkedZone(1)
	-- 判断是否满足解放费用的条件，检查是否有满足条件的怪兽可解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13452889.cfilter,1,nil,tp,lg,zone) end
	-- 选择满足条件的1只怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c13452889.cfilter,1,1,nil,tp,lg,zone)
	-- 将选中的怪兽从场上解放，作为效果的发动代价
	Duel.Release(g,REASON_COST)
end
-- 定义效果的目标选择处理函数
function c13452889.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local zone=c:GetLinkedZone(1-tp)
	if chk==0 then return bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone) end
	-- 设置当前效果的目标为被战斗破坏的对方怪兽
	Duel.SetTargetCard(bc)
	-- 设置连锁操作信息，表明本次效果将特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 定义效果的处理函数
function c13452889.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local zone1=c:GetLinkedZone(tp)
		local zone2=c:GetLinkedZone(1-tp)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone1)
			-- 判断是否在己方场上特殊召唤，若否则询问玩家选择
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone2) or Duel.SelectYesNo(tp,aux.Stringid(13452889,1))) then  --"是否在自己场上特殊召唤？"
			-- 将目标怪兽在己方场上特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone1)
		else
			-- 将目标怪兽在对方场上特殊召唤，若成功则获得额外攻击机会
			if Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP,zone2)~=0
				and c:IsRelateToBattle() then
				-- 为己方怪兽添加一次额外攻击次数的效果
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EXTRA_ATTACK)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
