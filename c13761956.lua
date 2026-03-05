--フレムベル・ベビー
-- 效果：
-- 自己的主要阶段时，把这张卡从手卡送去墓地发动。自己场上表侧表示存在的1只炎属性怪兽的攻击力上升400。
function c13761956.initial_effect(c)
	-- 效果原文内容：自己的主要阶段时，把这张卡从手卡送去墓地发动。自己场上表侧表示存在的1只炎属性怪兽的攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13761956,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c13761956.atcost)
	e1:SetTarget(c13761956.attg)
	e1:SetOperation(c13761956.atop)
	c:RegisterEffect(e1)
end
-- 检查是否满足费用条件，即是否可以将此卡送入墓地作为费用
function c13761956.atcost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选表侧表示且为炎属性的怪兽
function c13761956.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 选择目标怪兽效果处理函数
function c13761956.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c13761956.filter(chkc) end
	-- 判断场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c13761956.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c13761956.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数
function c13761956.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的攻击力上升400
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
