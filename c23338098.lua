--A BF－涙雨のチドリ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡的攻击力上升自己墓地的「黑羽」怪兽数量×300。
-- ③：这张卡被破坏送去墓地时，以「强袭黑羽-泪雨之千鸟刀鸟」以外的自己墓地1只鸟兽族同调怪兽为对象才能发动。那只怪兽特殊召唤。
function c23338098.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
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
	-- 「黑羽」怪兽为素材作同调召唤的这张卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c23338098.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡的攻击力上升自己墓地的「黑羽」怪兽数量×300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c23338098.value)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏送去墓地时，以「强袭黑羽-泪雨之千鸟刀鸟」以外的自己墓地1只鸟兽族同调怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 检查这张卡的同调召唤素材中是否存在「黑羽」怪兽，并将结果记录在e1的Label中（有则1，无则0），供①效果判断是否当作调整使用。
function c23338098.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- ①效果的发动条件：这张卡以同调召唤方式成功出场，且素材中含有「黑羽」怪兽（e1的Label为1）时才适用。
function c23338098.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- ①效果的处理：为这张卡添加调整（TYPE_TUNER）类型，使其当作调整使用，该效果不会被无效，并会在离场等标准时机重置。
function c23338098.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 当作调整使用
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 墓地「黑羽」怪兽的过滤条件：是怪兽卡且卡名含有「黑羽」字段。
function c23338098.atkfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x33)
end
-- ②效果攻击力上升值的计算：统计这张卡的控制者墓地中满足atkfilter的「黑羽」怪兽数量，并乘以300作为上升数值。
function c23338098.value(e,c)
	-- 统计自己墓地的「黑羽」怪兽数量，乘以300作为这张卡的攻击力上升数值。
	return Duel.GetMatchingGroupCount(c23338098.atkfilter,c:GetControler(),LOCATION_GRAVE,0,nil)*300
end
-- ③效果的发动条件：这张卡被破坏后确实被送去了墓地（当前位于墓地）时可发动。
function c23338098.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ③效果选择对象的过滤条件：是鸟兽族同调怪兽，不是「强袭黑羽-泪雨之千鸟刀鸟」自身，并且满足特殊召唤条件。
function c23338098.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_WINDBEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsCode(23338098)
end
-- ③效果的发动目标和条件检查：对象卡必须位于自己墓地且符合spfilter；发动时需确认自己场上存在可用怪兽区域且墓地存在至少1只符合条件的怪兽。
function c23338098.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23338098.spfilter(chkc,e,tp) end
	-- ③效果的发动条件之一：自己场上存在可用的主要怪兽区域（有空格才能特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- ③效果的发动条件之一：自己墓地存在至少1只满足spfilter（鸟兽族同调怪兽且不是本卡）的对象。
		and Duel.IsExistingTarget(c23338098.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求其选择要特殊召唤的墓地怪兽（请选择要特殊召唤的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 由玩家从自己墓地的符合条件怪兽中选择1只，并将其设置为③效果的对象。
	local g=Duel.SelectTarget(tp,c23338098.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记特殊召唤的操作信息：本次效果将把对象怪兽特殊召唤，用于连锁处理时的信息记录。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：取得效果对象中的目标卡，若目标仍与效果关联，则将其特殊召唤到自己场上。
function c23338098.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果处理时需要特殊召唤的对象卡（发动时选择的那张墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
