--クリフォート・ディスク
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
-- ②：自己场上的「机壳」怪兽的攻击力上升300。
-- 【怪兽效果】
-- ①：这张卡可以不用解放作召唤。
-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时才能发动。从卡组把2只「机壳」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c64496451.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤与灵摆卡发动规则。
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「机壳」怪兽不能特殊召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c64496451.splimit)
	c:RegisterEffect(e2)
	-- ②：自己场上的「机壳」怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出场上所有字段为「机壳」的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xaa))
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- ①：这张卡可以不用解放作召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(64496451,0))  --"不用解放作召唤"
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SUMMON_PROC)
	e4:SetCondition(c64496451.ntcon)
	c:RegisterEffect(e4)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_SUMMON_COST)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetOperation(c64496451.lvop)
	c:RegisterEffect(e5)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星，原本攻击力变成1800。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_SPSUMMON_COST)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetOperation(c64496451.lvop2)
	c:RegisterEffect(e6)
	-- ③：通常召唤的这张卡不受原本的等级或者阶级比这张卡的等级低的怪兽发动的效果影响。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_IMMUNE_EFFECT)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCondition(c64496451.immcon)
	-- 设置不受原本等级或阶级低于自身等级的怪兽发动的效果影响的过滤条件。
	e7:SetValue(aux.qlifilter)
	c:RegisterEffect(e7)
	-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时才能发动。从卡组把2只「机壳」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(64496451,1))  --"特殊召唤"
	e8:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e8:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e8:SetCode(EVENT_SUMMON_SUCCESS)
	e8:SetCondition(c64496451.spcon)
	e8:SetTarget(c64496451.sptg)
	e8:SetOperation(c64496451.spop)
	c:RegisterEffect(e8)
	-- ④：把「机壳」怪兽解放对这张卡的上级召唤成功时才能发动。
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_SINGLE)
	e9:SetCode(EFFECT_MATERIAL_CHECK)
	e9:SetValue(c64496451.valcheck)
	e9:SetLabelObject(e8)
	c:RegisterEffect(e9)
end
-- 限制只能特殊召唤「机壳」怪兽。
function c64496451.splimit(e,c)
	return not c:IsSetCard(0xaa)
end
-- 妥协召唤（不用解放作召唤）的条件判断函数。
function c64496451.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判断是否满足不用解放、怪兽原本等级在5星以上且场上有可用怪兽区域的条件。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 判断这张卡是否没有使用解放的祭品（即妥协召唤）。
function c64496451.lvcon(e)
	return e:GetHandler():GetMaterialCount()==0
end
-- 妥协召唤成功时，注册使其等级变成4星、原本攻击力变成1800的效果。
function c64496451.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c64496451.lvcon)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的原本攻击力变成1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c64496451.lvcon)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e2)
end
-- 特殊召唤成功时，注册使其等级变成4星、原本攻击力变成1800的效果。
function c64496451.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ②：特殊召唤或者不用解放作召唤的这张卡的等级变成4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(4)
	e1:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e1)
	-- ②：特殊召唤或者不用解放作召唤的这张卡的原本攻击力变成1800
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1800)
	e2:SetReset(RESET_EVENT+0x7f0000)
	c:RegisterEffect(e2)
end
-- 限制抗性效果仅在通常召唤成功时适用。
function c64496451.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_NORMAL)
end
-- 限制特殊召唤效果仅在解放了「机壳」怪兽上级召唤成功时才能发动。
function c64496451.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 过滤卡组中可以特殊召唤的「机壳」怪兽。
function c64496451.spfilter(c,e,tp)
	return c:IsSetCard(0xaa) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备与合法性检测。
function c64496451.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域是否至少有2个空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查卡组中是否存在至少2只可以特殊召唤的「机壳」怪兽。
		and Duel.IsExistingMatchingCard(c64496451.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 特殊召唤效果的具体执行逻辑，包括召唤怪兽并注册结束阶段破坏的延迟效果。
function c64496451.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 效果处理时，若自己场上的空怪兽区域不足2个，则不处理效果。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 获取卡组中所有满足特殊召唤条件的「机壳」怪兽。
	local g=Duel.GetMatchingGroup(c64496451.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2只怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		sg:GetFirst():RegisterFlagEffect(64496451,RESET_EVENT+RESETS_STANDARD,0,0,fid)
		sg:GetNext():RegisterFlagEffect(64496451,RESET_EVENT+RESETS_STANDARD,0,0,fid)
		sg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c64496451.descon)
		e1:SetOperation(c64496451.desop)
		-- 注册在回合结束阶段触发的全局时点效果，用于破坏特殊召唤的怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有本次特殊召唤标记（fid）的怪兽。
function c64496451.desfilter(c,fid)
	return c:GetFlagEffectLabel(64496451)==fid
end
-- 检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该结束阶段破坏的效果。
function c64496451.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c64496451.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 在结束阶段执行破坏被特殊召唤怪兽的操作。
function c64496451.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c64496451.desfilter,nil,e:GetLabel())
	-- 因效果将目标怪兽破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end
-- 检查上级召唤时所使用的解放怪兽（祭品）中是否包含「机壳」怪兽，并记录结果。
function c64496451.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0xaa) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
