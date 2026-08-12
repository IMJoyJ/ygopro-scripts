--A BF－涙雨のチドリ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡的攻击力上升自己墓地的「黑羽」怪兽数量×300。
-- ③：这张卡被破坏送去墓地时，以「强袭黑羽-泪雨之千鸟刀鸟」以外的自己墓地1只鸟兽族同调怪兽为对象才能发动。那只怪兽特殊召唤。
function c23338098.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23338098.tncon)
	e1:SetOperation(c23338098.tnop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升自己墓地的「黑羽」怪兽数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c23338098.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ③：这张卡被破坏送去墓地时，以「强袭黑羽-泪雨之千鸟刀鸟」以外的自己墓地1只鸟兽族同调怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c23338098.value)
	c:RegisterEffect(e3)
	-- 为满足条件的同调召唤的这张卡添加当作调整使用的永续效果
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23338098,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCondition(c23338098.spcon)
	e4:SetTarget(c23338098.sptg)
	e4:SetOperation(c23338098.spop)
	c:RegisterEffect(e4)
end
c23338098.treat_itself_tuner=true
-- 检查同调召唤所用素材中是否包含「黑羽」怪兽，若有则标记为1，否则为0
function c23338098.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为同调召唤且标记为1（即包含黑羽怪兽作为素材）
function c23338098.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 若满足条件，则为该卡添加调整类型
function c23338098.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 为该卡添加调整类型
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 用于筛选墓地中的黑羽怪兽
function c23338098.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x33)
end
-- 计算墓地中黑羽怪兽数量并乘以300作为攻击力加成
function c23338098.value(e,c)
	-- 计算墓地中黑羽怪兽数量并乘以300作为攻击力加成
	return Duel.GetMatchingGroupCount(c23338098.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
-- 判断该卡是否在墓地
function c23338098.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 用于筛选墓地中的鸟兽族同调怪兽
function c23338098.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(23338098)
end
-- 设置特殊召唤效果的发动条件和目标选择
function c23338098.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23338098.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的鸟兽族同调怪兽
		and Duel.IsExistingTarget(c23338098.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的鸟兽族同调怪兽
	local g=Duel.SelectTarget(tp,c23338098.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，确定特殊召唤的目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c23338098.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
