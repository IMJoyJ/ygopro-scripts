--ギミック・パペット－ギア・チェンジャー
-- 效果：
-- 这张卡不能从卡组特殊召唤。1回合1次，选择这张卡以外的自己场上1只名字带有「机关傀儡」的怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。
function c56427559.initial_effect(c)
	-- 1回合1次，选择这张卡以外的自己场上1只名字带有「机关傀儡」的怪兽才能发动。这张卡的等级变成和选择的怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56427559,0))  --"等级变化"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c56427559.lvtg)
	e1:SetOperation(c56427559.lvop)
	c:RegisterEffect(e1)
	-- 这张卡不能从卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_DECK)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示、名字带有「机关傀儡」、等级与自身当前等级不同且等级在1以上的怪兽
function c56427559.lvfilter(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x1083) and not c:IsLevel(lv) and c:IsLevelAbove(1)
end
-- 效果发动的目标选择与合法性检测
function c56427559.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c56427559.lvfilter(chkc,e:GetHandler():GetLevel()) end
	-- 在发动阶段，检查自己场上是否存在至少1只符合条件的「机关傀儡」怪兽
	if chk==0 then return Duel.IsExistingTarget(c56427559.lvfilter,tp,LOCATION_MZONE,0,1,nil,e:GetHandler():GetLevel()) end
	-- 向玩家发送提示信息，要求选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的「机关傀儡」怪兽作为效果的对象
	Duel.SelectTarget(tp,c56427559.lvfilter,tp,LOCATION_MZONE,0,1,1,nil,e:GetHandler():GetLevel())
end
-- 效果处理：将自身等级修改为与目标怪兽相同的等级
function c56427559.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这张卡的等级变成和选择的怪兽的等级相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
