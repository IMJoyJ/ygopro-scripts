--流麗の騎士ガイアストリーム
-- 效果：
-- 6星怪兽×2只以上
-- 「流丽之骑士 盖亚激流」1回合1次也能在自己场上的5·7阶的超量怪兽上面重叠来超量召唤。这张卡在超量召唤的回合不能作为超量召唤的素材。
-- ①：这张卡不能直接攻击。
-- ②：这张卡的攻击力上升这张卡作为超量素材中的怪兽的等级·阶级的合计×200。
-- ③：这张卡进行战斗的伤害步骤结束时发动。这张卡1个超量素材取除。
local s,id,o=GetID()
-- 注册该卡的所有效果：超量召唤手续（6星怪兽×2只以上，或1回合1次叠放在自己场上5·7阶超量怪兽上）、苏生限制、超量召唤回合不能作为超量素材、不能直接攻击、攻击力上升、伤害步骤结束时取除1个超量素材。
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
	-- ③：这张卡进行战斗的伤害步骤结束时发动。这张卡1个超量素材取除。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"取除超量素材"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(s.xyzcon2)
	e4:SetOperation(s.xyzop2)
	c:RegisterEffect(e4)
end
-- 用于特殊超量召唤手续的过滤函数：选择自己场上表侧表示且阶级为5或7的超量怪兽作为叠放对象。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(5,7) and c:IsType(TYPE_XYZ)
end
-- 作为额外叠放召唤（叠放在5/7阶超量怪兽上）的追加操作：检查并登记此召唤方式1回合1次的限制。
function s.xyzop(e,tp,chk)
	-- 检查阶段：确认当前玩家还没有对应的‘1回合1次’使用标志，以此判断是否允许进行这种叠放超量召唤。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 实际执行时给当前玩家注册‘流丽之骑士 盖亚激流’本回合已使用过特殊叠放召唤的誓约标志，回合结束时重置。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 限制不能作为超量素材的效果条件：此卡处于本回合通过超量召唤上场状态时返回真，使其不能作为超量召唤素材。
function s.xyzcon(e)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- 攻击力上升值的计算：取这张卡的全部超量素材，将每个素材的等级或阶级累加后乘以200，作为攻击力上升数值。
function s.atkval(e,c)
	return c:GetOverlayGroup():GetSum(s.lv_or_rk)*200
end
-- 辅助计算函数：若素材为超量怪兽则取其阶级，否则取其等级，以对应效果原文中的“等级·阶级”合计。
function s.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- ③效果的发动条件：该卡与所进行的战斗相关（即作为攻击或被攻击的怪兽参加了战斗），在伤害步骤结束时满足。
function s.xyzcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle()
end
-- ③效果处理：确认此卡仍与连锁相关且拥有超量素材时，由效果发动者取除1个超量素材（原因：效果）。
function s.xyzop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:GetOverlayCount()>0 then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
