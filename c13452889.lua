--ベクター・スケア・デーモン
-- 效果：
-- 电子界族怪兽2只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地时，把这张卡所连接区1只自己怪兽解放才能发动。破坏的那只怪兽在作为这张卡所连接区的自己·对方场上特殊召唤。这个效果在对方场上把怪兽特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
function c13452889.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：以电子界族怪兽2只以上为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时，把这张卡所连接区1只自己怪兽解放才能发动。破坏的那只怪兽在作为这张卡所连接区的自己·对方场上特殊召唤。这个效果在对方场上把怪兽特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13452889,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件：本卡与对方怪兽战斗并将其战斗破坏送去墓地。
	e1:SetCondition(aux.bdogcon)
	e1:SetCost(c13452889.spcost)
	e1:SetTarget(c13452889.sptg)
	e1:SetOperation(c13452889.spop)
	c:RegisterEffect(e1)
end
-- 定义解放候选怪兽的过滤函数：该怪兽必须位于本卡连接区，且解放后自己或对方场上仍有可用的连接区空位用于后续特殊召唤。
function c13452889.cfilter(c,tp,g,zone)
	-- 判断该怪兽属于本卡连接区，且解放后自己场上对应连接区仍有空位。
	return g:IsContains(c) and (Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_TOFIELD,zone[tp])>0
		-- 或者解放后对方场上对应连接区仍有空位。
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone[1-tp])>0)
end
-- 效果的代价处理函数：从本卡所连接区的自己怪兽中选择1只解放作为发动COST。
function c13452889.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	local zone={}
	zone[0]=c:GetLinkedZone(0)
	zone[1]=c:GetLinkedZone(1)
	-- 在发动时检查是否有至少1只满足条件的可解放怪兽（位于连接区且解放后有空位）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c13452889.cfilter,1,nil,tp,lg,zone) end
	-- 让玩家选择1只满足条件的自己怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c13452889.cfilter,1,1,nil,tp,lg,zone)
	-- 将选择的怪兽解放，作为发动效果的费用。
	Duel.Release(g,REASON_COST)
end
-- 效果发动时的目标判断：获取被战斗破坏的对方怪兽，确认其能够特殊召唤到自己或对方场上。
function c13452889.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local zone=c:GetLinkedZone(1-tp)
	if chk==0 then return bc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		or bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone) end
	-- 将被战斗破坏的对方怪兽登记为当前连锁的处理对象。
	Duel.SetTargetCard(bc)
	-- 设置操作信息：本效果包含1只怪兽的特殊召唤，以便其他卡进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 效果处理：若对象仍与效果关联，则根据能否特召及玩家选择，将其特殊召唤到自己或对方场上；若特召到对方场上且本卡仍在战斗相关，则赋予本卡1次追加攻击。
function c13452889.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时应特殊召唤的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local zone1=c:GetLinkedZone(tp)
		local zone2=c:GetLinkedZone(1-tp)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone1)
			-- 当对方场上也可以特召时，询问玩家是否选择在自己场上特召；若不能特召到对方场上则不再询问。
			and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp,zone2) or Duel.SelectYesNo(tp,aux.Stringid(13452889,1))) then  --"是否在自己场上特殊召唤？"
			-- 将对象怪兽正面表示特殊召唤到自己场上对应的连接区。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone1)
		else
			-- 尝试将对象怪兽特殊召唤到对方场上对应的连接区，并判断是否成功。
			if Duel.SpecialSummon(tc,0,tp,1-tp,false,false,POS_FACEUP,zone2)~=0
				and c:IsRelateToBattle() then
				-- 这个效果在对方场上把怪兽特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
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
