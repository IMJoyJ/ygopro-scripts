--EMインコーラス
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，另一边的自己的灵摆区域有「娱乐伙伴 合唱鹦鹉」以外的「娱乐伙伴」卡、「魔术师」卡、「异色眼」卡之内任意种存在的场合才能发动。这张卡的灵摆刻度直到回合结束时变成7。
-- 【怪兽效果】
-- ①：这张卡被战斗破坏时才能发动。从卡组把灵摆怪兽以外的1只「娱乐伙伴」怪兽特殊召唤。
function c56675280.initial_effect(c)
	-- 初始化灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有「娱乐伙伴 合唱鹦鹉」以外的「娱乐伙伴」卡、「魔术师」卡、「异色眼」卡之内任意种存在的场合才能发动。这张卡的灵摆刻度直到回合结束时变成7。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56675280,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c56675280.sccon)
	e1:SetTarget(c56675280.sctg)
	e1:SetOperation(c56675280.scop)
	c:RegisterEffect(e1)
	-- ①：这张卡被战斗破坏时才能发动。从卡组把灵摆怪兽以外的1只「娱乐伙伴」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56675280,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetTarget(c56675280.sptg)
	e2:SetOperation(c56675280.spop)
	c:RegisterEffect(e2)
end
-- 过滤另一边灵摆区域中「娱乐伙伴 合唱鹦鹉」以外的「娱乐伙伴」、「魔术师」、「异色眼」卡片
function c56675280.scfilter(c)
	return c:IsSetCard(0x98,0x99,0x9f) and not c:IsCode(56675280)
end
-- 灵摆效果的发动条件：另一边的灵摆区域存在满足条件的卡
function c56675280.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的灵摆区域是否存在除自身以外满足条件的卡片
	return Duel.IsExistingMatchingCard(c56675280.scfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 灵摆效果的发动判定：检查自身当前的左刻度是否不等于7
function c56675280.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetLeftScale()~=7 end
end
-- 灵摆效果的处理：将这张卡的左右灵摆刻度直到回合结束时变成7
function c56675280.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:GetLeftScale()==7 then return end
	-- 这张卡的灵摆刻度直到回合结束时变成7。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LSCALE)
	e1:SetValue(7)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e2)
end
-- 过滤卡组中灵摆怪兽以外的「娱乐伙伴」怪兽且能被特殊召唤
function c56675280.spfilter(c,e,tp)
	return c:IsSetCard(0x9f) and not c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 怪兽效果的发动判定：检查怪兽区域是否有空位且卡组中存在可特殊召唤的怪兽
function c56675280.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c56675280.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果的处理：从卡组选择1只满足条件的怪兽特殊召唤
function c56675280.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c56675280.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
