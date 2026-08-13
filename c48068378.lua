--リンク・ディヴォーティー
-- 效果：
-- 4星以下的电子界族怪兽1只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合发动。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
-- ②：互相连接状态的这张卡被解放的场合才能发动。在自己场上把2只「连接衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
function c48068378.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续，素材必须为1只4星以下的电子界族怪兽（对应效果文本“4星以下的电子界族怪兽1只”）。
	aux.AddLinkProcedure(c,c48068378.matfilter,1,1)
	-- ①：这张卡特殊召唤成功的场合发动。这个回合，自己不能把连接3以上的连接怪兽连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48068378,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(c48068378.limop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：互相连接状态的这张卡被解放的场合才能发动。在自己场上把2只「连接衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48068378,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,48068378)
	e2:SetCondition(c48068378.spcon)
	e2:SetTarget(c48068378.sptg)
	e2:SetOperation(c48068378.spop)
	c:RegisterEffect(e2)
	-- 对应②效果中的“互相连接状态的这张卡”，用于在离场前记录互相连接状态。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetLabelObject(e2)
	e3:SetOperation(c48068378.chk)
	c:RegisterEffect(e3)
end
-- 在离场前的时点，将这张卡当前互相连接的数量记录到e2的标签中，供②的发动条件判定使用。
function c48068378.chk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetMutualLinkedGroupCount())
end
-- 判定连接素材是否为4星以下（连接怪兽等级视为0）且为电子界族怪兽（对应效果文本“4星以下的电子界族怪兽1只”）。
function c48068378.matfilter(c)
	return c:IsLevelBelow(4) and c:IsLinkRace(RACE_CYBERSE)
end
-- 特殊召唤成功时，给控制者附加“本回合不能把连接3以上的连接怪兽连接召唤”的永续限制效果。
function c48068378.limop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ①：这张卡特殊召唤成功的场合发动。这个回合，自己不能把连接3以上的连接怪兽连接召唤。②：互相连接状态的这张卡被解放的场合才能发动。在自己场上把2只「连接衍生物」（电子界族·光·1星·攻/守0）特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c48068378.splimit)
	-- 将限制效果e1注册给玩家tp，使tp在这一回合受到相应特殊召唤限制。
	Duel.RegisterEffect(e1,tp)
end
-- 限制判定函数：如果尝试特殊召唤的怪兽是连接3以上的连接怪兽，且该特殊召唤为连接召唤，则禁止该特殊召唤。
function c48068378.splimit(e,c,tp,sumtp,sumpos)
	return c:IsType(TYPE_LINK) and c:IsLinkAbove(3) and bit.band(sumtp,SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK
end
-- ②的发动条件：e2的标签值大于0，表示这张卡在离场前处于互相连接状态。
function c48068378.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()>0
end
-- ②的发动时判定：检查是否满足发动条件（没有青眼精灵龙限制、有足够区域、可特殊召唤衍生物），并设置操作信息。
function c48068378.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己主要怪兽区域至少存在2个空格，用于放置2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己是否可以特殊召唤1只“连接衍生物”（电子界族·光·1星·攻/守0）的衍生物。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,48068379,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) end
	-- 设置操作信息：本效果预计生成2只衍生物（CATEGORY_TOKEN）。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,tp,0)
	-- 设置操作信息：本效果预计特殊召唤2只怪兽（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
-- ②的效果处理：若青眼精灵龙效果生效、或没有足够区域、或无法特殊召唤衍生物，则不处理；否则依次特殊召唤2只“连接衍生物”。
function c48068378.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		-- 如果玩家不能特殊召唤衍生物，则直接结束处理（不生成衍生物）。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,48068379,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_CYBERSE,ATTRIBUTE_LIGHT) then return end
	for i=1,2 do
		-- 在玩家tp场上生成1只“连接衍生物”（卡号48068379）的衍生物。
		local token=Duel.CreateToken(tp,48068379)
		-- 将衍生物以表侧表示特殊召唤到自己场上（作为多只特殊召唤的中间步骤，等待SpecialSummonComplete统一处理）。
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 完成这次特殊召唤处理，实际将2只衍生物同时特殊召唤到场上。
	Duel.SpecialSummonComplete()
end
