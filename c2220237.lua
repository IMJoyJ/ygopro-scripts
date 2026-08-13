--セキュア・ガードナー
-- 效果：
-- 电子界族连接怪兽1只
-- 这张卡不能作为连接素材。
-- ①：「安全守卫者」在自己场上只能有1只表侧表示存在。
-- ②：这张卡特殊召唤成功的回合，自己受到的效果伤害变成0。
-- ③：自己因战斗·效果受到伤害的场合，1回合只有1次让那次伤害变成0。
function c2220237.initial_effect(c)
	c:SetUniqueOnField(1,0,2220237)
	c:EnableReviveLimit()
	-- 为这张卡设定连接召唤手续：使用1只满足c2220237.matfilter的怪兽（电子界族连接怪兽）作为连接素材。
	aux.AddLinkProcedure(c,c2220237.matfilter,1,1)
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的回合，自己受到的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c2220237.regop)
	c:RegisterEffect(e2)
	-- ③：自己因战斗·效果受到伤害的场合，1回合只有1次让那次伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetValue(c2220237.damval2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetCondition(c2220237.damcon)
	c:RegisterEffect(e4)
end
-- 特殊召唤成功时触发的处理（②）：给控制者注册持续到结束阶段的伤害变更效果，使本回合内自己受到的效果伤害变为0，并附加效果伤害变成0的标记。
function c2220237.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 电子界族连接怪兽1只。②：这张卡特殊召唤成功的回合，自己受到的效果伤害变成0。③：自己因战斗·效果受到伤害的场合，1回合只有1次让那次伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c2220237.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把e1（EFFECT_CHANGE_DAMAGE，效果伤害改为0）注册给玩家tp，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 把e2（EFFECT_NO_EFFECT_DAMAGE，效果伤害变成0的标记）注册给玩家tp，持续到结束阶段。
	Duel.RegisterEffect(e2,tp)
end
-- 连接素材过滤函数：筛选电子界族且为连接怪兽的卡，用于连接召唤素材的判定。
function c2220237.matfilter(c)
	return c:IsLinkRace(RACE_CYBERSE) and c:IsLinkType(TYPE_LINK)
end
-- 伤害变更函数：当伤害原因包含效果伤害时返回0（将效果伤害变为0），否则保留原伤害值，用于②的效果。
function c2220237.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
-- 伤害变更函数：当自己受到战斗/效果伤害且这张卡本回合未使用过③（flag为0）时，将那次伤害变为0并注册flag标记（表示已发动过③），否则保留原伤害，用于③的1回合1次效果。
function c2220237.damval2(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and c:GetFlagEffect(2220237)==0 then
		c:RegisterFlagEffect(2220237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 条件函数：返回这张卡是否尚未使用过③（flag为0），作为EFFECT_NO_EFFECT_DAMAGE的适用条件。
function c2220237.damcon(e)
	return e:GetHandler():GetFlagEffect(2220237)==0
end
