--麗神－不知火
-- 效果：
-- 不死族怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的同调怪兽不会被效果破坏。
-- ②：只要这张卡在怪兽区域存在，自己的炎属性怪兽不会被战斗破坏。
-- ③：对方回合，以除外的1只自己的不死族同调怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c86926989.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：不死族怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_ZOMBIE),2)
	-- ①：只要这张卡在怪兽区域存在，自己场上的同调怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出自己场上的同调怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_SYNCHRO))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己的炎属性怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 过滤出自己场上的炎属性怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：对方回合，以除外的1只自己的不死族同调怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(86926989,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,86926989)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCondition(c86926989.condition)
	e3:SetTarget(c86926989.target)
	e3:SetOperation(c86926989.operation)
	c:RegisterEffect(e3)
end
-- 效果③的发动条件函数
function c86926989.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤除外区中可以特殊召唤到这张卡所连接区的表侧表示不死族同调怪兽
function c86926989.filter(c,e,tp,zone)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果③的发动准备（选择对象与合法性检测）函数
function c86926989.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c86926989.filter(chkc,e,tp,zone) end
	-- 在发动时，检测除外区是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c86926989.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp,zone) end
	-- 设置选择卡片时的提示信息为特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只自己的不死族同调怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c86926989.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp,zone)
	-- 设置效果处理信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果③的效果处理（特殊召唤）函数
function c86926989.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	local zone=c:GetLinkedZone(tp)
	if tc:IsRelateToEffect(e) and zone&0x1f~=0 then
		-- 将目标怪兽在作为这张卡所连接区的自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
