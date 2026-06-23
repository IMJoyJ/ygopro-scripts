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
	-- 添加连接召唤手续，要求使用1到1张满足过滤条件的怪兽作为连接素材
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
-- 特殊召唤成功时注册效果，使自己在该回合内受到的效果伤害变为0，并设置标记防止重复触发
function c2220237.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置一个影响全场的永续效果，使自己受到的战斗或效果伤害变为0（仅在未触发过时生效）
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c2220237.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 连接素材过滤器，筛选电子界族且为连接怪兽的卡片
function c2220237.matfilter(c)
	return c:IsLinkRace(RACE_CYBERSE) and c:IsLinkType(TYPE_LINK)
end
-- 伤害值计算函数，若伤害来源为效果则伤害变为0
function c2220237.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end
-- 伤害值计算函数，若伤害来源为战斗或效果且未触发过则伤害变为0，并设置标记防止重复触发
function c2220237.damval2(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 and c:GetFlagEffect(2220237)==0 then
		c:RegisterFlagEffect(2220237,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
-- 伤害减免条件函数，判断是否已触发过伤害减免效果
function c2220237.damcon(e)
	return e:GetHandler():GetFlagEffect(2220237)==0
end
