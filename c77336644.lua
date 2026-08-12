--レッド・デーモンズ・ドラゴン／バスター
-- 效果：
-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
-- ①：这张卡攻击的伤害计算后发动。场上的其他怪兽全部破坏。
-- ②：场上的这张卡被破坏时，以自己墓地1只「红莲魔龙」为对象才能发动。那只怪兽特殊召唤。
function c77336644.initial_effect(c)
	-- 注册该卡片记有「爆裂模式」和「红莲魔龙」的卡名。
	aux.AddCodeList(c,80280737,70902743)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过「爆裂模式」的效果进行特殊召唤。
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡攻击的伤害计算后发动。场上的其他怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77336644,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c77336644.descon)
	e2:SetTarget(c77336644.destg)
	e2:SetOperation(c77336644.desop)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被破坏时，以自己墓地1只「红莲魔龙」为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(77336644,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c77336644.spcon)
	e3:SetTarget(c77336644.sptg)
	e3:SetOperation(c77336644.spop)
	c:RegisterEffect(e3)
end
c77336644.assault_name=70902743
-- 效果①（伤害计算后破坏其他怪兽）的发动条件函数。
function c77336644.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前进行攻击的怪兽是否是这张卡自身。
	return Duel.GetAttacker()==e:GetHandler()
end
-- 效果①（伤害计算后破坏其他怪兽）的发动准备与目标确认函数。
function c77336644.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上除这张卡以外的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁处理的操作信息，表明此效果将破坏上述获取的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①（伤害计算后破坏其他怪兽）的实际处理函数。
function c77336644.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上除这张卡（若仍在场）以外的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 因效果破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end
-- 效果②（被破坏时特殊召唤红莲魔龙）的发动条件函数，检查这张卡是否之前存在于场上。
function c77336644.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，筛选出卡名为「红莲魔龙」且可以被特殊召唤的怪兽。
function c77336644.spfilter(c,e,tp)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②（被破坏时特殊召唤红莲魔龙）的发动准备与取对象函数。
function c77336644.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77336644.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足条件的「红莲魔龙」。
		and Duel.IsExistingTarget(c77336644.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足条件的「红莲魔龙」作为效果的对象。
	local g=Duel.SelectTarget(tp,c77336644.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息，表明此效果将特殊召唤所选择的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②（被破坏时特殊召唤红莲魔龙）的实际处理函数。
function c77336644.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
