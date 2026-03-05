--流麗の騎士ガイアストリーム
-- 效果：
-- 6星怪兽×2只以上
-- 「流丽之骑士 盖亚激流」1回合1次也能在自己场上的5·7阶的超量怪兽上面重叠来超量召唤。这张卡在超量召唤的回合不能作为超量召唤的素材。
-- ①：这张卡不能直接攻击。
-- ②：这张卡的攻击力上升这张卡作为超量素材中的怪兽的等级·阶级的合计×200。
-- ③：这张卡进行战斗的伤害步骤结束时发动。这张卡1个超量素材取除。
local s,id,o=GetID()
-- 初始化卡片效果，设置超量召唤手续、苏生限制，并注册不能做素材、不能直接攻击、攻击力上升及伤害步骤结束取除素材的效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,6,2,s.ovfilter,aux.Stringid(id,0),99,s.xyzop)  --"是否在5·7阶的超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 这张卡在超量召唤的回合不能作为超量召唤的素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetCondition(s.xyzcon)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡作为超量素材中的怪兽的等级·阶级的合计×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的伤害步骤结束时发动。这张卡 1 个超量素材取除。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"取除超量素材"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.xyzcon2)
	e4:SetOperation(s.xyzop2)
	c:RegisterEffect(e4)
end
-- 过滤用于重叠超量召唤的怪兽，需为表侧表示且阶级为 5 或 7 的超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(5,7) and c:IsType(TYPE_XYZ)
end
-- 定义超量召唤手续的操作函数，用于检查并注册一回合一次的限制标识。
function s.xyzop(e,tp,chk)
	-- 检查当前玩家是否已在本回合注册过该标识，以限制特殊召唤次数。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家注册本回合有效的标识效果，实现一回合一次的特殊召唤限制。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 设置不能成为超量素材的条件，判断卡片是否为本回合超量召唤的状态。
function s.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 计算攻击力上升值，获取超量素材组的等级或阶级总和并乘以 200。
function s.atkval(e,c)
	return c:GetOverlayGroup():GetSum(s.lv_or_rk)*200
end
-- 辅助函数，判断怪兽是否为超量怪兽以决定返回阶级还是等级。
function s.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 设置触发效果的条件，判断该卡是否参与了战斗并与此战斗相关。
function s.xyzcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle()
end
-- 执行效果操作，若卡片与连锁相关且有素材，则取除 1 个超量素材。
function s.xyzop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
