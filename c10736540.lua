--湖の乙女ヴィヴィアン
-- 效果：
-- 把这张卡作为同调素材的场合，不是战士族怪兽的同调召唤不能使用，被同调召唤使用的这张卡除外。
-- ①：这张卡召唤成功时，以自己墓地1只「圣骑士」通常怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只5星「圣骑士」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤。
function c10736540.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是战士族怪兽的同调召唤不能使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c10736540.synlimit)
	c:RegisterEffect(e1)
	-- 被同调召唤使用的这张卡除外
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetCondition(c10736540.rmcon)
	c:RegisterEffect(e2)
	-- ①：这张卡召唤成功时，以自己墓地1只「圣骑士」通常怪兽为对象才能发动。那只怪兽特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10736540,0))  --"墓地苏生"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c10736540.target)
	e3:SetOperation(c10736540.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在的场合，以自己场上1只5星「圣骑士」怪兽为对象才能发动。那只怪兽的等级下降1星，这张卡从墓地特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(10736540,1))  --"这张卡特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetTarget(c10736540.sptg)
	e4:SetOperation(c10736540.spop)
	c:RegisterEffect(e4)
end
-- 判断是否能作为同调素材，非战士族不能作为同调素材
function c10736540.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_WARRIOR)
end
-- 判断是否因同调召唤而除外
function c10736540.rmcon(e)
	return bit.band(e:GetHandler():GetReason(),REASON_MATERIAL+REASON_SYNCHRO)==REASON_MATERIAL+REASON_SYNCHRO
end
-- 过滤墓地中的「圣骑士」通常怪兽
function c10736540.filter(c,e,tp)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为墓地中的「圣骑士」通常怪兽
function c10736540.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10736540.filter(chkc,e,tp) end
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c10736540.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c10736540.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 设置效果处理函数
function c10736540.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上的5星「圣骑士」怪兽
function c10736540.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsLevel(5)
end
-- 设置效果目标为场上的5星「圣骑士」怪兽
function c10736540.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c10736540.spfilter(chkc) end
	-- 判断是否满足特殊召唤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断场上是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c10736540.spfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c10736540.spfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 设置效果处理函数
function c10736540.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:IsLevel(1) then return end
	local c=e:GetHandler()
	-- 使目标怪兽的等级下降1星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-1)
	tc:RegisterEffect(e1)
	if c:IsRelateToEffect(e) then
		-- 将这张卡从墓地特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
