--水晶機巧－ハリファイバーP
-- 效果：
-- 包含调整的怪兽2只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。把持有那些作为连接素材的怪兽的原本等级合计以下的等级的1只调整从额外卡组守备表示特殊召唤。
-- ②：对方的主要阶段以及战斗阶段，把场上的这张卡除外才能发动。在自己场上把3只「水晶机巧衍生物」（机械族·水·1星·攻/守0）特殊召唤。这衍生物不能解放。
local s,id,o=GetID()
-- 初始化卡片效果，注册连接召唤手续、连接召唤成功时特招调整的效果、对方回合除外特招衍生物的效果，以及素材检查效果。
function s.initial_effect(c)
	-- 添加连接召唤手续：怪兽2只以上，且需满足s.lcheck过滤条件（包含调整）。
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤的场合才能发动。把持有那些作为连接素材的怪兽的原本等级合计以下的等级的1只调整从额外卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤调整"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- ②：对方的主要阶段以及战斗阶段，把场上的这张卡除外才能发动。在自己场上把3只「水晶机巧衍生物」（机械族·水·1星·攻/守0）特殊召唤。这衍生物不能解放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤衍生物"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	-- 设置发动代价为将场上的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 持有那些作为连接素材的怪兽的原本等级合计以下的等级
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_MATERIAL_CHECK)
	e3:SetValue(s.valcheck)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
end
-- 连接素材过滤条件：素材中必须包含至少1只调整怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_TUNER)
end
-- 过滤用于计算等级的素材怪兽：必须是原本就存在等级的怪兽卡。
function s.lvcalfilter(c)
	if c:GetOriginalType()&TYPE_MONSTER~=0 then return true end
	local se=c:GetSpecialSummonInfo(SUMMON_INFO_REASON_EFFECT)
	return se and se:GetHandler()==c
end
-- 检查连接素材，计算所有符合条件的素材怪兽的原本等级合计值，并将其作为Label保存在效果e1中。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	local val=g:Filter(s.lvcalfilter,nil):GetSum(Card.GetOriginalLevel)
	e:GetLabelObject():SetLabel(val)
end
-- 效果①的发动条件：这张卡连接召唤成功。
function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤额外卡组中可以特殊召唤的调整怪兽：等级在指定数值以下，且能以守备表示特殊召唤到额外怪兽区或连接端。
function s.hspfilter(c,e,tp,lv)
	return c:IsType(TYPE_TUNER) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 检查是否有足够的额外怪兽区域或连接端指向的区域来特殊召唤该怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果①的发动准备：检查素材等级合计是否大于0，且额外卡组是否存在可特招的调整，并设置特殊召唤的操作信息。
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetLabel()
	-- 检查可行性：素材等级合计大于0，且额外卡组存在至少1只满足条件的调整怪兽。
	if chk==0 then return lv>0 and Duel.IsExistingMatchingCard(s.hspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,lv) end
	-- 设置特殊召唤的操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：从额外卡组选择1只满足等级条件的调整怪兽，以守备表示特殊召唤。
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足等级条件的调整怪兽。
	local g=Duel.SelectMatchingCard(tp,s.hspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv)
	if g:GetCount()>0 then
		-- 将选中的怪兽在自己场上以表侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动条件：对方回合的主要阶段或战斗阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且处于主要阶段或战斗阶段。
	return Duel.GetTurnPlayer()~=tp and (Duel.IsMainPhase() or Duel.IsBattlePhase())
end
-- 效果②的发动准备：检查是否受青眼精灵龙限制、怪兽区域是否有3个以上空位，以及是否能特殊召唤衍生物。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查在将这张卡移出场后，自己场上是否有3个以上的怪兽区域空位。
		and Duel.GetMZoneCount(tp,e:GetHandler())>=3
		-- 检查玩家是否可以特殊召唤指定的衍生物怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0xea,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_WATER) end
	-- 设置衍生物产生的操作信息：产生3只衍生物。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	-- 设置特殊召唤的操作信息：特殊召唤3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,0,0)
end
-- 效果②的效果处理：在自己场上特殊召唤3只「水晶机巧衍生物」，并为这些衍生物添加不能解放的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上的主要怪兽区域是否有3个以上的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>=3
		-- 检查玩家是否仍能特殊召唤指定的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0xea,TYPES_TOKEN_MONSTER,0,0,1,RACE_MACHINE,ATTRIBUTE_WATER) then
		for i=1,3 do
			-- 在卡片数据库中创建「水晶机巧衍生物」的卡片数据。
			local token=Duel.CreateToken(tp,id+o)
			-- 逐步特殊召唤衍生物（表侧表示），用于多张卡片的同时特殊召唤处理。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			-- 这衍生物不能解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
			token:RegisterEffect(e2,true)
		end
		-- 完成所有逐步特殊召唤的怪兽的特殊召唤处理。
		Duel.SpecialSummonComplete()
	end
end
