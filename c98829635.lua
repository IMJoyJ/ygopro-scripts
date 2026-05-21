--禁じられた聖冠
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让怪兽的效果发动。
-- ①：选场上1只表侧表示怪兽，直到回合结束时以下效果适用。
-- ●效果无效化。
-- ●不能攻击。
-- ●不会被战斗·效果破坏。
-- ●不受自身以外的卡发动的效果影响。
-- ●不能解放。
-- ●不能作为融合·同调·超量·连接召唤的素材。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔法卡的发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，不能对应这张卡的发动让怪兽的效果发动。①：选场上1只表侧表示怪兽，直到回合结束时以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且未适用过本卡效果的怪兽
function s.effilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)==0
end
-- 效果发动的目标确认与连锁限制处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上双方怪兽区域所有满足条件的表侧表示怪兽
	local g=Duel.GetMatchingGroup(s.effilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息，表示该效果包含使怪兽效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 设置连锁限制，限制对方对应这张卡的发动能发动的效果
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制判定函数，规定不能对应发动怪兽的效果
function s.chainlm(e,rp,tp)
	return not e:GetHandler():IsType(TYPE_MONSTER)
end
-- 效果处理的执行函数，选择1只怪兽并对其适用各项限制和保护效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择场上1只表侧表示的怪兽
	local g=Duel.SelectMatchingCard(tp,s.effilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	if tc and not tc:IsImmuneToEffect(e) then
		-- 在场上对选中的怪兽显示选中特效
		Duel.HintSelection(g)
		-- 使与目标怪兽相关的连锁中已发动的效果无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- ●效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- ●效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- ●不能攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- ●不会被战斗·效果破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetValue(1)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e5)
		-- ●不受自身以外的卡发动的效果影响。
		local e6=Effect.CreateEffect(c)
		e6:SetType(EFFECT_TYPE_SINGLE)
		e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e6:SetRange(LOCATION_MZONE)
		e6:SetCode(EFFECT_IMMUNE_EFFECT)
		e6:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e6:SetValue(s.efilter)
		tc:RegisterEffect(e6)
		-- ●不能解放。
		local e7=Effect.CreateEffect(c)
		e7:SetType(EFFECT_TYPE_SINGLE)
		e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e7:SetRange(LOCATION_MZONE)
		e7:SetCode(EFFECT_UNRELEASABLE_SUM)
		e7:SetValue(1)
		e7:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e7)
		local e8=e7:Clone()
		e8:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e8)
		local e9=e7:Clone()
		e9:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e9:SetValue(s.fuslimit)
		tc:RegisterEffect(e9)
		local e10=e7:Clone()
		e10:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e10)
		local e11=e7:Clone()
		e11:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
		tc:RegisterEffect(e11)
		local e12=e7:Clone()
		e12:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		tc:RegisterEffect(e12)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"「禁忌的圣冠」效果适用中"
	end
end
-- 免疫效果的过滤器，判定是否为自身以外发动的卡的效果
function s.efilter(e,te)
	return te:GetOwner()~=e:GetHandler() and te:IsActivated()
end
-- 融合素材限制判定函数，限制不能作为融合召唤的素材
function s.fuslimit(e,c,sumtype)
	return sumtype==SUMMON_TYPE_FUSION
end
