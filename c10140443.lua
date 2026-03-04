--転生炎獣バースト・グリフォン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只7星以下的炎属性怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值。这个回合，自己不是炎属性怪兽不能特殊召唤。
-- ②：这张卡用「转生炎兽 爆裂狮鹫」为素材作同调召唤的场合才能发动。下次的准备阶段从自己墓地把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果的主函数
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加同调召唤手续，需要1只调整和任意数量的调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- EFFECT_MATERIAL_CHECK：检查这张卡是否被用于同调召唤（用于判断是否满足②的发动条件）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.check)
	c:RegisterEffect(e1)
	-- ②效果：这张卡用「转生炎兽 爆裂狮鹫」为素材作同调召唤的场合才能发动。下次的准备阶段从自己墓地把1只怪兽特殊召唤
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
	-- ①效果：以自己墓地1只7星以下的炎属性怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值。这个回合，自己不是炎属性怪兽不能特殊召唤
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
-- 检查素材的函数，判断用于同调召唤的素材中是否包含这张卡本身
function s.check(e,c)
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,id) then e:SetLabel(1) else e:SetLabel(0) end
end
-- ②效果的发动条件检查函数：确认这张卡是通过同调召唤成功出场且素材中包含自己
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabelObject():GetLabel()==1
end
-- ②效果的后续处理函数：在满足条件时注册一个在准备阶段触发的效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rs=1
	-- ②效果的具体处理：注册在下次准备阶段从墓地特殊召唤怪兽的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 检查当前是否处于准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数，用于后续判断是否经过了下一个回合
		e1:SetLabel(Duel.GetTurnCount())
		rs=2
	else e1:SetLabel(0) end
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,rs)
	-- 将准备阶段触发的效果注册给玩家tp
	Duel.RegisterEffect(e1,tp)
end
-- 定义过滤器：检查怪兽是否可以被特殊召唤
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 准备阶段触发效果的条件检查函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件：当前回合数与记录的回合数不同（表示经过了下一个回合）且有可用的怪兽区域
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件：自己墓地存在可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
-- 准备阶段触发的效果处理函数：从墓地特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示卡片编号的提示信息
	Duel.Hint(HINT_CARD,0,id)
	-- 显示选择要特殊召唤的怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从墓地中选择1只可以特殊召唤的怪兽（不受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 特殊召唤选择的怪兽
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义①效果的过滤器：检查怪兽是否为7星以下、等级低于指定值、炎属性且可以特殊召唤
function s.sfilter(c,e,tp,lv)
	return c:IsLevelBelow(7) and c:IsLevelBelow(lv-1) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标选择函数
function s.dlvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp,lv) end
	-- ①效果的发动条件检查：这张卡等级大于1且有可用的怪兽区域
	if chk==0 then return lv>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件：自己墓地存在符合条件的7星以下炎属性怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
	-- 显示选择目标怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家选择要特殊召唤的怪兽
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置操作信息，表明要进行的特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理函数
function s.dlvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①效果：这个回合，自己不是炎属性怪兽不能特殊召唤。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置限制：这个回合自己不能特殊召唤非炎属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsAttribute),ATTRIBUTE_FIRE))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制效果注册给玩家tp
	Duel.RegisterEffect(e1,tp)
	-- 获取效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 如果目标卡与效果关联且特殊召唤成功，且这张卡也与效果关联，则执行后续处理
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e)
		and c:IsFaceup() then
		-- 那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(-tc:GetOriginalLevel())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
