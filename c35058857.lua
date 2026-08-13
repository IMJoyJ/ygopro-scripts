--奇術王 ムーン・スター
-- 效果：
-- 把这张卡作为同调素材的场合，不是暗属性怪兽的同调召唤不能使用。
-- ①：自己场上有调整存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以自己的场上（表侧表示）·墓地1只怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。这个效果的发动后，直到回合结束时自己不能作同调召唤以外的特殊召唤。
function c35058857.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是暗属性怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c35058857.synlimit)
	c:RegisterEffect(e1)
	-- ①：自己场上有调整存在的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c35058857.spcon)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤的场合，以自己的场上（表侧表示）·墓地1只怪兽为对象才能发动。这张卡的等级直到回合结束时变成和那只怪兽相同。这个效果的发动后，直到回合结束时自己不能作同调召唤以外的特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35058857,0))  --"等级变更"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c35058857.lvtg)
	e3:SetOperation(c35058857.lvop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
end
-- 用于判定同调召唤的怪兽是否为暗属性：若怪兽不是暗属性则返回 true，表示不能使用此卡作为素材；即此卡只能用于暗属性怪兽的同调召唤。
function c35058857.synlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤条件：判断怪兽是否为场上表侧表示的调整怪兽，用于①的特殊召唤条件。
function c35058857.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
-- ①的特殊召唤手续条件：当 c 为空时供系统查询手续返回 true；实际召唤时需满足自己的主要怪兽区有空位，且自己场上有表侧表示调整怪兽。
function c35058857.spcon(e,c)
	if c==nil then return true end
	-- 检查此卡控制者场上是否存在至少 1 个可用的主要怪兽区空格。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查此卡控制者场上是否存在至少 1 只表侧表示的调整怪兽。
		and Duel.IsExistingMatchingCard(c35058857.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②对象怪兽的筛选：从自己场上（表侧表示）或墓地选择等级为 1 以上且与这张卡当前等级不同的怪兽。
function c35058857.lvfilter(c,lv)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- ②的发动条件与取对象处理：检测是否存在满足条件的对象，并从自己场上（表侧表示）·墓地选择 1 只怪兽作为对象。
function c35058857.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lv=e:GetHandler():GetLevel()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and c35058857.lvfilter(chkc,lv) end
	-- 发动合法性判定：若不存在满足条件的可选对象，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c35058857.lvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,lv) end
	-- 向玩家显示选择目标提示，提示文字为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上（表侧表示）·墓地选择 1 只满足条件的怪兽，并设为该效果的对象。
	Duel.SelectTarget(tp,c35058857.lvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,lv)
end
-- ②的效果处理：若对象怪兽与效果仍关联且这张卡表侧表示在场，则将这张卡的等级变为对象怪兽的等级直到结束阶段；随后给自己附加“不能作同调召唤以外的特殊召唤”的自肃。
function c35058857.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动②时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的等级直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	-- 这个效果的发动后，直到回合结束时自己不能作同调召唤以外的特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c35058857.splimit)
	-- 将“不能作同调召唤以外的特殊召唤”的自肃效果注册给发动玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃判定：如果正要进行的特殊召唤不是同调召唤，则返回 true 禁止该特殊召唤。
function c35058857.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return bit.band(sumtype,SUMMON_TYPE_SYNCHRO)~=SUMMON_TYPE_SYNCHRO
end
