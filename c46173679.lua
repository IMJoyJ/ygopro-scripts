--終焉の焔
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
-- ①：在自己场上把2只「黑焰衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能为暗属性以外的怪兽的上级召唤而解放。
function c46173679.initial_effect(c)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。①：在自己场上把2只“黑焰衍生物”（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能为暗属性以外的怪兽的上级召唤而解放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c46173679.cost)
	e1:SetTarget(c46173679.target)
	e1:SetOperation(c46173679.activate)
	c:RegisterEffect(e1)
end
-- 发动代价的合法性检查：确认本回合自己尚未进行过召唤、反转召唤、特殊召唤中的任意一种，否则不能发动。
function c46173679.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合自己是否未进行过『召唤』（表侧表示通常召唤/上级召唤等）；未进行才满足发动条件之一。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 同时检查本回合自己是否未进行过反转召唤和特殊召唤；若均未进行，则发动条件全部成立，返回true。
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(e)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46173679.sumlimit)
	-- 将『不能特殊召唤』的誓约效果注册到场上，作用对象为我方玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 将『不能召唤』的誓约效果注册到场上，作用对象为我方玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 将『不能反转召唤』的誓约效果注册到场上，作用对象为我方玩家，持续到回合结束。
	Duel.RegisterEffect(e3,tp)
end
-- 例外判定函数：若当前发动特殊召唤的效果不是这张『终焉之焰』自身的效果（LabelObject），则返回true以禁止该特殊召唤；是自身效果则放行。
function c46173679.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 发动条件判定：确认青眼精灵龙的效果未生效（禁止同时特召2只以上）、自己主要怪兽区空位大于1、且可以特殊召唤黑焰衍生物，满足才可发动效果。
function c46173679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认自己主要怪兽区空位数量大于1，保证能放置2只衍生物。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认自己能够将黑焰衍生物（恶魔族·暗·1星·攻/守0）以表侧守备表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46173680,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 将操作信息登记为『生成2只衍生物』，供连锁处理时识别效果种类。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 将操作信息登记为『特殊召唤2只怪兽』，供连锁处理时识别效果种类。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 效果处理：若青眼精灵龙效果生效则直接终止；否则在场上有2个空位且仍可特召时，连续特殊召唤2只黑焰衍生物，分别附加『不能为暗属性以外怪兽的上级召唤解放』的限制，最后完成特殊召唤。
function c46173679.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理阶段再次确认主要怪兽区空位>1，防止发动后格子不足导致无法特召。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 效果处理阶段再次确认自己仍能特殊召唤黑焰衍生物token，满足条件才继续处理。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46173680,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then
		for i=1,2 do
			-- 生成一只黑焰衍生物token（循环两次，分别生成第1只和第2只）。
			local token=Duel.CreateToken(tp,46173679+i)
			-- 将token以表侧守备表示加入特殊召唤流程（分步处理，以便每只token单独附加限制效果）。
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这衍生物不能为暗属性以外的怪兽的上级召唤而解放。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(c46173679.recon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 完成分步特殊召唤流程，统一结束这次特殊召唤处理。
		Duel.SpecialSummonComplete()
	end
end
-- 判定用于上级召唤的素材怪兽c是否属于非暗属性；若为非暗属性则返回true，表示该衍生物不能被解放用于那次上级召唤。
function c46173679.recon(e,c)
	return c:IsNonAttribute(ATTRIBUTE_DARK)
end
