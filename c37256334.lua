--EMカード・ガードナー
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，以自己场上1只表侧守备表示怪兽为对象才能发动。那只怪兽的守备力变成自己场上的全部表侧守备表示怪兽的原本守备力合计数值。
-- 【怪兽效果】
-- ①：这张卡的守备力上升这张卡以外的自己场上的「娱乐伙伴」怪兽的原本守备力的合计数值。
function c37256334.initial_effect(c)
	-- 为这张卡赋予灵摆怪兽属性（灵摆召唤、灵摆卡的发动等），使其作为灵摆怪兽也能在灵摆区发动灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只表侧守备表示怪兽为对象才能发动。那只怪兽的守备力变成自己场上的全部表侧守备表示怪兽的原本守备力合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37256334,0))
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37256334.deftg)
	e1:SetOperation(c37256334.defop)
	c:RegisterEffect(e1)
	-- ①：这张卡的守备力上升这张卡以外的自己场上的「娱乐伙伴」怪兽的原本守备力的合计数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c37256334.defval)
	c:RegisterEffect(e2)
end
-- 判定对象候选：表侧守备表示且当前守备力不等于将要变成的合计数值的怪兽（即守备力会被改变的怪兽）。
function c37256334.deffilter1(c,def)
	return c:IsPosition(POS_FACEUP_DEFENSE) and not c:IsDefense(def)
end
-- 发动时的目标选择处理：计算自己场上全部表侧守备表示怪兽的原本守备力合计；在合法性检查时确认存在满足条件的对象；之后提示玩家选择1只表侧守备表示且当前守备力不等于该合计值的怪兽作为效果对象。
function c37256334.deftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上全部表侧守备表示怪兽的集合。
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
	local def=g:GetSum(Card.GetBaseDefense)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37256334.deffilter1(chkc,def) end
	-- 在效果发动合法性检查（chk==0）时，确认自己场上是否存在至少1只满足deffilter1条件（表侧守备表示且守备力不等于目标合计值）的怪兽，以决定能否发动。
	if chk==0 then return Duel.IsExistingTarget(c37256334.deffilter1,tp,LOCATION_MZONE,0,1,nil,def) end
	-- 向玩家显示选择提示，提示内容为“请选择表侧表示的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上选择1只满足deffilter1条件的表侧守备表示怪兽，并将其设定为该效果的对象。
	Duel.SelectTarget(tp,c37256334.deffilter1,tp,LOCATION_MZONE,0,1,1,nil,def)
end
-- 效果处理：确认发动者与对象仍与效果相关后，重新计算自己场上全部表侧守备表示怪兽的原本守备力合计，并将对象怪兽的守备力暂时变成该合计数值（效果结束后恢复）。
function c37256334.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得当前连锁中记录的效果对象卡，即灵摆效果选定的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 重新获取自己场上全部表侧守备表示怪兽的集合，用于在效果处理时计算最新的原本守备力合计。
		local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,0,nil,POS_FACEUP_DEFENSE)
		local def=g:GetSum(Card.GetBaseDefense)
		-- 那只怪兽的守备力变成自己场上的全部表侧守备表示怪兽的原本守备力合计数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(def)
		tc:RegisterEffect(e1)
	end
end
-- 判定怪兽为表侧表示且属于「娱乐伙伴」系列，用于计算这张卡以外的娱乐伙伴怪兽。
function c37256334.deffilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 计算这张卡以外的自己场上的表侧「娱乐伙伴」怪兽的原本守备力合计值，作为这张卡守备力的上升数值。
function c37256334.defval(e,c)
	-- 获取这张卡控制者场上除这张卡以外的全部表侧「娱乐伙伴」怪兽的集合。
	local g=Duel.GetMatchingGroup(c37256334.deffilter2,c:GetControler(),LOCATION_MZONE,0,c)
	return g:GetSum(Card.GetBaseDefense)
end
