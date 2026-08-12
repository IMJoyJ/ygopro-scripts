--BK ビッグバンテージ
-- 效果：
-- 这张卡1回合只有1次不会被战斗破坏。此外，1回合1次，选择自己墓地1只名字带有「燃烧拳击手」的怪兽或者除外的1只自己的名字带有「燃烧拳击手」的怪兽才能发动。自己场上的全部名字带有「燃烧拳击手」的怪兽变成和选择的怪兽相同等级。
function c86325573.initial_effect(c)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c86325573.valcon)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，选择自己墓地1只名字带有「燃烧拳击手」的怪兽或者除外的1只自己的名字带有「燃烧拳击手」的怪兽才能发动。自己场上的全部名字带有「燃烧拳击手」的怪兽变成和选择的怪兽相同等级。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86325573,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c86325573.lvtg)
	e2:SetOperation(c86325573.lvop)
	c:RegisterEffect(e2)
end
-- 判断破坏原因是否为战斗破坏
function c86325573.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 过滤自己墓地或除外区中等级大于0的名字带有「燃烧拳击手」的怪兽
function c86325573.filter(c)
	return c:GetLevel()>0 and c:IsSetCard(0x1084) and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 过滤自己场上表侧表示且等级大于0的名字带有「燃烧拳击手」的怪兽
function c86325573.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1084) and c:GetLevel()>0
end
-- 等级变化效果的发动准备与目标选择，检查是否存在可选择的对象以及场上是否有可改变等级的怪兽
function c86325573.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c86325573.filter(chkc) end
	-- 在效果发动时，检查自己墓地或除外区是否存在至少1只满足条件的「燃烧拳击手」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c86325573.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 在效果发动时，检查自己场上是否存在至少1只表侧表示的「燃烧拳击手」怪兽
		and Duel.IsExistingMatchingCard(c86325573.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择效果对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地或除外区1只名字带有「燃烧拳击手」的怪兽作为效果对象
	Duel.SelectTarget(tp,c86325573.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
end
-- 等级变化效果的处理，将自己场上所有名字带有「燃烧拳击手」的怪兽等级变成与选择的对象怪兽相同
function c86325573.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local lv=tc:GetLevel()
	-- 获取自己场上所有表侧表示的名字带有「燃烧拳击手」的怪兽
	local g=Duel.GetMatchingGroup(c86325573.lvfilter,tp,LOCATION_MZONE,0,nil)
	local lc=g:GetFirst()
	while lc do
		-- 自己场上的全部名字带有「燃烧拳击手」的怪兽变成和选择的怪兽相同等级。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		lc:RegisterEffect(e1)
		lc=g:GetNext()
	end
end
