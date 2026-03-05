--転生炎獣バースト・グリフォン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只7星以下的炎属性怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值。这个回合，自己不是炎属性怪兽不能特殊召唤。
-- ②：这张卡用「转生炎兽 爆裂狮鹫」为素材作同调召唤的场合才能发动。下次的准备阶段从自己墓地把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，启用复活限制，添加同调召唤手续，注册效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：以自己墓地1只7星以下的炎属性怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值。这个回合，自己不是炎属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.check)
	c:RegisterEffect(e1)
	-- ②：这张卡用「转生炎兽 爆裂狮鹫」为素材作同调召唤的场合才能发动。下次的准备阶段从自己墓地把1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- ①：以自己墓地1只7星以下的炎属性怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值。这个回合，自己不是炎属性怪兽不能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(s.dlvtg)
	e3:SetOperation(s.dlvop)
	c:RegisterEffect(e3)
end
-- 检查是否使用了此卡作为同调素材
function s.check(e,c)
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,id) then e:SetLabel(1) else e:SetLabel(0) end
end
-- 判断是否为同调召唤且使用了此卡作为素材
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabelObject():GetLabel()==1
end
-- 设置下次准备阶段特殊召唤墓地怪兽的效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rs=1
	-- 设置下次准备阶段特殊召唤墓地怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 判断当前阶段是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数用于判断
		e1:SetLabel(Duel.GetTurnCount())
		rs=2
	else e1:SetLabel(0) end
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,rs)
	-- 注册准备阶段特殊召唤效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤可特殊召唤的卡片
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断准备阶段特殊召唤条件是否满足
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数与记录的回合数不同且场上存在空位
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在可特殊召唤的卡片
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
-- 执行准备阶段特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动卡片
	Duel.Hint(HINT_CARD,0,id)
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤满足条件的墓地怪兽
function s.sfilter(c,e,tp,lv)
	return c:IsLevelBelow(7) and c:IsLevelBelow(lv-1) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置①效果的目标选择
function s.dlvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp,lv) end
	-- 判断①效果是否可以发动
	if chk==0 then return lv>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行①效果操作
function s.dlvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置不能特殊召唤非炎属性怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置不能特殊召唤非炎属性怪兽的目标
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsAttribute),ATTRIBUTE_FIRE))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能特殊召唤非炎属性怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 获取效果目标
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽和自身是否有效
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e)
		and c:IsFaceup() then
		-- 降低自身等级的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(-tc:GetOriginalLevel())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
