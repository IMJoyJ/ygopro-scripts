--終焉の焔
-- 效果：
-- 这张卡发动的回合，自己不能用这张卡的效果以外把怪兽召唤·反转召唤·特殊召唤。
-- ①：在自己场上把2只「黑焰衍生物」（恶魔族·暗·1星·攻/守0）守备表示特殊召唤。这衍生物不能为暗属性以外的怪兽的上级召唤而解放。
function c46173679.initial_effect(c)
	-- 卡片效果初始化，设置为发动时点的自由连锁效果
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
-- 检查是否在该回合内没有进行过召唤、反转召唤和特殊召唤
function c46173679.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在该回合内没有进行过通常召唤
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_SUMMON)==0
		-- 检查是否在该回合内没有进行过反转召唤和特殊召唤
		and Duel.GetActivityCount(tp,ACTIVITY_FLIPSUMMON)==0 and Duel.GetActivityCount(tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册一个场上的效果，使玩家不能特殊召唤怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetLabelObject(e)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c46173679.sumlimit)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 注册一个场上的效果，使玩家不能通常召唤怪兽
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	-- 克隆效果e2并修改为禁止反转召唤，然后注册给玩家tp
	Duel.RegisterEffect(e3,tp)
end
-- 限制特殊召唤的函数，用于判断是否是当前效果的召唤
function c46173679.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return e:GetLabelObject()~=se
end
-- 设置发动时的处理目标，检测是否满足特殊召唤衍生物的条件
function c46173679.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上是否有足够的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46173680,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	-- 设置操作信息为将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	-- 设置操作信息为将要特殊召唤2只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,0,0)
end
-- 发动效果时的处理函数，检测是否满足召唤衍生物的条件并执行召唤
function c46173679.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查玩家场上是否有足够的空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查玩家是否可以特殊召唤指定的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,46173680,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_FIEND,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then
		for i=1,2 do
			-- 创建一张指定编号的衍生物卡片
			local token=Duel.CreateToken(tp,46173679+i)
			-- 将衍生物以守备表示特殊召唤到场上
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 为召唤出的衍生物添加效果，使其不能被用于非暗属性怪兽的上级召唤
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UNRELEASABLE_SUM)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(c46173679.recon)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
-- 判断目标怪兽是否不是暗属性
function c46173679.recon(e,c)
	return c:IsNonAttribute(ATTRIBUTE_DARK)
end
