--水舞台
-- 效果：
-- ①：自己场上的水属性怪兽不会被和水属性以外的怪兽的战斗破坏。
-- ②：自己场上的「水伶女」怪兽不受对方怪兽的效果影响。
-- ③：这张卡从场上送去墓地的场合，以自己墓地1只水族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是水族怪兽不能特殊召唤。
function c29047353.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的水属性怪兽不会被和水属性以外的怪兽的战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的保护对象为自己场上表侧表示的水属性怪兽。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e2:SetValue(c29047353.indval)
	c:RegisterEffect(e2)
	-- ②：自己场上的「水伶女」怪兽不受对方怪兽的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 设置该效果的适用对象为自己场上属于「水伶女」系列的怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xcd))
	e3:SetValue(c29047353.efilter)
	c:RegisterEffect(e3)
	-- ③：这张卡从场上送去墓地的场合，以自己墓地1只水族怪兽为对象才能发动。那只怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是水族怪兽不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCondition(c29047353.spcon)
	e4:SetTarget(c29047353.sptg)
	e4:SetOperation(c29047353.spop)
	c:RegisterEffect(e4)
end
-- 定义免疫战斗破坏的判定：当战斗的对方怪兽属性不是水属性时，己方水属性怪兽不会被那次战斗破坏。
function c29047353.indval(e,c)
	return c:GetAttribute()~=ATTRIBUTE_WATER
end
-- 判定效果免疫的来源：若效果来自对方玩家且是怪兽效果，则该效果对己方「水伶女」怪兽不适用。
function c29047353.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_MONSTER)
end
-- 效果发动条件：此卡从场上区域被送去墓地。
function c29047353.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤对象的筛选条件：必须是水族怪兽，且能够被当前效果特殊召唤。
function c29047353.spfilter(c,e,tp)
	return c:IsRace(RACE_AQUA) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标检查与选择：将自己墓地1只水族怪兽作为对象；发动前需确认自己场上有怪兽区域空位且墓地存在符合条件的对象。
function c29047353.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29047353.spfilter(chkc,e,tp) end
	-- 发动条件之一：自己场上必须有可用的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只符合条件的水族怪兽可以成为对象。
		and Duel.IsExistingTarget(c29047353.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只水族怪兽，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c29047353.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设定本次效果处理为特殊召唤，记录对象卡组和数量，以便相关效果进行检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，并对自己设置直到回合结束时不能特殊召唤水族以外怪兽的限制。
function c29047353.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时使用的对象卡（此前选择的水族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标水族怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是水族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c29047353.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该限制效果注册到当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制判定：若要特殊召唤的怪兽不是水族，则不允许特殊召唤。
function c29047353.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:GetRace()~=RACE_AQUA
end
