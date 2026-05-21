--マジシャンズ・プロテクション
-- 效果：
-- ①：只要自己场上有魔法师族怪兽存在，自己受到的全部伤害变成一半。
-- ②：这张卡从场上送去墓地的场合，以自己墓地1只魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
function c89448140.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要自己场上有魔法师族怪兽存在，自己受到的全部伤害变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(c89448140.condition)
	e2:SetValue(c89448140.val)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合，以自己墓地1只魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCondition(c89448140.spcon)
	e3:SetTarget(c89448140.sptg)
	e3:SetOperation(c89448140.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c89448140.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 伤害减半效果的适用条件：自己场上存在表侧表示的魔法师族怪兽
function c89448140.condition(e)
	-- 检查自己场上是否存在至少1只表侧表示的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c89448140.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 伤害减半的数值计算（向下取整）
function c89448140.val(e,re,dam,r,rp,rc)
	return math.floor(dam/2)
end
-- 特殊召唤效果的发动条件：这张卡从场上送去墓地
function c89448140.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：墓地中可以特殊召唤的魔法师族怪兽
function c89448140.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的靶向与发动合法性检测
function c89448140.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89448140.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在可以作为效果对象的魔法师族怪兽
		and Duel.IsExistingTarget(c89448140.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的魔法师族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89448140.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理逻辑
function c89448140.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
