--H・C ナックル・ナイフ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有1星怪兽以外的「英豪」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，以自己场上1只战士族怪兽为对象才能发动。那只怪兽和这张卡的等级变成和那之内的1只的等级相同。这个效果的发动后，直到回合结束时自己不用超量怪兽不能攻击宣言。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特召效果，②召唤·特殊召唤成功时改变等级的效果（包含通常召唤和特殊召唤两个时点）
function c71549257.initial_effect(c)
	-- ①：自己场上有1星怪兽以外的「英豪」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71549257,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71549257)
	e1:SetCondition(c71549257.spcon)
	e1:SetTarget(c71549257.sptg)
	e1:SetOperation(c71549257.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以自己场上1只战士族怪兽为对象才能发动。那只怪兽和这张卡的等级变成和那之内的1只的等级相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71549257,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,71549257+o)
	e2:SetTarget(c71549257.lvtg)
	e2:SetOperation(c71549257.lvop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的1星以外的「英豪」怪兽
function c71549257.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f) and not c:IsLevel(1)
end
-- ①效果的发动条件：自己场上存在1星以外的「英豪」怪兽
function c71549257.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c71549257.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动准备：检查怪兽区域是否有空位，以及这张卡是否能特殊召唤
function c71549257.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息（将自身特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若这张卡仍在手卡，则将其特殊召唤
function c71549257.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示、等级在1以上且等级与这张卡不同的战士族怪兽
function c71549257.lvfilter(c,lv)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- ②效果的对象选择：选择自己场上1只与这张卡等级不同的战士族怪兽为对象
function c71549257.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c71549257.lvfilter(chkc,lv) end
	-- 检查这张卡是否有等级，且场上是否存在可作为对象的战士族怪兽
	if chk==0 then return lv>0 and Duel.IsExistingTarget(c71549257.lvfilter,tp,LOCATION_MZONE,0,1,c,lv) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的战士族怪兽作为效果的对象
	Duel.SelectTarget(tp,c71549257.lvfilter,tp,LOCATION_MZONE,0,1,1,c,lv)
end
-- ②效果的处理：让对象怪兽和这张卡的等级变成和其中1只的等级相同，并适用攻击限制
function c71549257.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsLevel(c:GetLevel()) then
		local g=Group.FromCards(c,tc)
		-- 提示玩家选择要变成的等级所对应的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(71549257,2))  --"请选择拥有要变成的等级的卡"
		local sg=g:Select(tp,1,1,nil)
		local tc=sg:GetFirst()
		g:RemoveCard(tc)
		-- 那只怪兽和这张卡的等级变成和那之内的1只的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetLevel())
		g:GetFirst():RegisterEffect(e1)
	end
	-- 这个效果的发动后，直到回合结束时自己不用超量怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c71549257.atktg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，限制玩家在回合结束前不能用超量怪兽以外的怪兽进行攻击宣言
	Duel.RegisterEffect(e2,tp)
end
-- 攻击限制的过滤条件：非超量怪兽
function c71549257.atktg(e,c)
	return not c:IsType(TYPE_XYZ)
end
