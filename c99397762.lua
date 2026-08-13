--光波防輪
-- 效果：
-- ①：以自己场上1只「银河眼」超量怪兽或者「光波」超量怪兽为对象才能发动。把这张卡在那只怪兽下面重叠作为超量素材，那只怪兽在这个回合只有1次不会被战斗·效果破坏。
function c99397762.initial_effect(c)
	-- ①：以自己场上1只「银河眼」超量怪兽或者「光波」超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99397762.target)
	e1:SetOperation(c99397762.activate)
	c:RegisterEffect(e1)
end
-- 筛选效果对象：必须是表侧表示的超量怪兽，且属于「银河眼」或「光波」系列。
function c99397762.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x107b,0xe5)
end
-- 对象指定与发动合法性判定：确认指定对象为符合条件的己方表侧超量怪兽；发动时需满足此卡为魔法卡、可作为超量素材，且场上存在合法对象。
function c99397762.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c99397762.filter(chkc) end
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and e:GetHandler():IsCanOverlay()
		-- 检查自己场上是否存在至少1只满足筛选条件的表侧超量怪兽可以作为对象。
		and Duel.IsExistingTarget(c99397762.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择对象的提示信息，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上的表侧超量怪兽中选择1只满足条件的怪兽作为效果对象，并设置为当前连锁的对象。
	Duel.SelectTarget(tp,c99397762.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：若这张卡和对象怪兽都仍合法，则把这张卡从墓地重叠到对象怪兽下方作为超量素材，并给对象怪兽赋予本回合1次不会被战斗·效果破坏的效果。
function c99397762.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and c:IsRelateToEffect(e) and c:IsCanOverlay() then
		c:CancelToGrave()
		-- 将这张卡作为超量素材叠放在对象怪兽下方。
		Duel.Overlay(tc,Group.FromCards(c))
		-- 那只怪兽在这个回合只有1次不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(c99397762.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 抗性判定函数：当破坏原因为战斗破坏或效果破坏时返回真，使“不会被破坏”效果适用。
function c99397762.indval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
