--銀河の召喚師
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「银河召唤师」以外的自己墓地1只「光子」怪兽或「银河」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：以自己场上1只其他的光属性怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成4星。
function c863795.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以「银河召唤师」以外的自己墓地1只「光子」怪兽或「银河」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(863795,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,863795)
	e1:SetTarget(c863795.sptg)
	e1:SetOperation(c863795.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以自己场上1只其他的光属性怪兽为对象才能发动。那只怪兽的等级直到回合结束时变成4星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(863795,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,863796)
	e3:SetTarget(c863795.lvtg)
	e3:SetOperation(c863795.lvop)
	c:RegisterEffect(e3)
end
-- 过滤「银河召唤师」以外的自己墓地中可以守备表示特殊召唤的「光子」或「银河」怪兽
function c863795.filter(c,e,tp)
	return c:IsSetCard(0x55,0x7b) and not c:IsCode(863795) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①号效果的发动准备与对象选择
function c863795.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c863795.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的、可作为效果对象的怪兽
		and Duel.IsExistingTarget(c863795.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c863795.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（包含对象怪兽和数量1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果的实际处理（特殊召唤对象怪兽）
function c863795.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤自己场上表侧表示、等级不是4且等级在1以上的光属性怪兽
function c863795.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and not c:IsLevel(4) and c:IsLevelAbove(1)
end
-- ②号效果的发动准备与对象选择
function c863795.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and c863795.lvfilter(chkc) end
	-- 检查自己场上是否存在除自身以外的、符合条件的光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c863795.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只其他的光属性怪兽作为效果对象
	Duel.SelectTarget(tp,c863795.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- ②号效果的实际处理（改变对象怪兽的等级）
function c863795.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级直到回合结束时变成4星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
