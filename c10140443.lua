--転生炎獣バースト・グリフォン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只7星以下的炎属性怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的等级下降那只怪兽的原本等级数值。这个回合，自己不是炎属性怪兽不能特殊召唤。
-- ②：这张卡用「转生炎兽 爆裂狮鹫」为素材作同调召唤的场合才能发动。下次的准备阶段从自己墓地把1只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化「转生炎兽 爆裂狮鹫」的效果，注册同调召唤手续、素材检测效果及两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- 检测是否使用「转生炎兽 爆裂狮鹫」为同调素材的效果
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
-- 同调召唤成功时，检测素材中是否存在「转生炎兽 爆裂狮鹫」
function s.check(e,c)
	if c:GetMaterial():IsExists(Card.IsCode,1,nil,id) then e:SetLabel(1) else e:SetLabel(0) end
end
-- 判断此卡是否是通过同调召唤方式特殊召唤，且所用素材包含「转生炎兽 爆裂狮鹫」
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabelObject():GetLabel()==1
end
-- 注册一个在下次准备阶段使墓地怪兽特殊召唤的效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rs=1
	-- 下次的准备阶段从自己墓地把1只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	-- 判断当前阶段是否已经是准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 若当前阶段已经是准备阶段，则将当前回合数作为效果标签记录
		e1:SetLabel(Duel.GetTurnCount())
		rs=2
	else e1:SetLabel(0) end
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	e1:SetReset(RESET_PHASE+PHASE_STANDBY,rs)
	-- 在全局环境中注册下次准备阶段特殊召唤墓地怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：可以特殊召唤的怪兽
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断在下次准备阶段是否能触发从墓地特殊召唤怪兽的效果
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合是否非登记效果的回合，且自己场上有可用的主要怪兽区域
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在能够特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
end
-- 准备阶段从墓地特殊召唤1只怪兽的具体效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示此卡的卡片发动提示
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只可以特殊召唤的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选择的怪兽特殊召唤
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：7星以下、且原本等级小于此卡等级、炎属性可以特殊召唤的怪兽
function s.sfilter(c,e,tp,lv)
	return c:IsLevelBelow(7) and c:IsLevelBelow(lv-1) and c:IsAttribute(ATTRIBUTE_FIRE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 以自己墓地1只7星以下的炎属性怪兽为对象发动的检测与效果靶向设置
function s.dlvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.sfilter(chkc,e,tp,lv) end
	-- 判断此卡的当前等级是否大于1，且自己场上有可用的主要怪兽区域
	if chk==0 then return lv>1 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在满足过滤条件的炎属性怪兽
		and Duel.IsExistingTarget(s.sfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,lv) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只满足过滤条件的炎属性怪兽为对象
	local g=Duel.SelectTarget(tp,s.sfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv)
	-- 设置当前处理的连锁信息：包含特殊召唤目标怪兽的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤墓地怪兽并降低自身等级的效果处理
function s.dlvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己不是炎属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	-- 设置不能特殊召唤非炎属性怪兽的限制
	e1:SetTarget(aux.TargetBoolFunction(aux.NOT(Card.IsAttribute),ATTRIBUTE_FIRE))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家特殊召唤非炎属性怪兽的效果
	Duel.RegisterEffect(e1,tp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍是此连锁的对象，将其特殊召唤成功，且此卡在场上表侧表示存在
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsRelateToEffect(e)
		and c:IsFaceup() then
		-- 这张卡的等级下降那只怪兽的原本等级数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(-tc:GetOriginalLevel())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e2)
	end
end
