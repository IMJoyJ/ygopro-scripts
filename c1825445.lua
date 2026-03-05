--超量合神－マグナフォーメーション
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己主要阶段1内，对方不能把场上的「超级量子」卡作为效果的对象。
-- ②：以自己场上1只「超级量子」超量怪兽为对象才能发动。选作为对象的怪兽以外的自己场上1只表侧表示怪兽在作为对象的怪兽下面重叠作为超量素材。
function c1825445.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己主要阶段1内，对方不能把场上的「超级量子」卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetCondition(c1825445.tgcon)
	e2:SetTarget(c1825445.tglimit)
	-- 设置效果值为aux.tgoval函数，用于判断目标是否不能成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：以自己场上1只「超级量子」超量怪兽为对象才能发动。选作为对象的怪兽以外的自己场上1只表侧表示怪兽在作为对象的怪兽下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1825445,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,1825445)
	e3:SetTarget(c1825445.mttg)
	e3:SetOperation(c1825445.mtop)
	c:RegisterEffect(e3)
end
-- 判断当前是否为自己的主要阶段1且为当前回合玩家
function c1825445.tgcon(e)
	-- 当前阶段为主要阶段1且当前回合玩家为自己
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 限制对方效果不能选择「超级量子」卡作为对象
function c1825445.tglimit(e,c)
	return c:IsSetCard(0xdc)
end
-- 筛选自己场上的超量「超级量子」怪兽作为效果对象
function c1825445.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xdc)
		-- 确保场上存在可作为超量素材的怪兽
		and Duel.IsExistingMatchingCard(c1825445.filter2,tp,LOCATION_MZONE,0,1,c)
end
-- 筛选自己场上的可叠放怪兽作为超量素材
function c1825445.filter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 设置效果的发动条件和对象选择逻辑
function c1825445.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c1825445.filter1(chkc,e,tp) end
	-- 检查是否存在满足条件的超量怪兽作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c1825445.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c1825445.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
-- 处理效果发动后的操作
function c1825445.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择作为超量素材的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择满足条件的怪兽作为超量素材
	local g=Duel.SelectMatchingCard(tp,c1825445.filter2,tp,LOCATION_MZONE,0,1,1,tc,e)
	if g:GetCount()>0 then
		local og=g:GetFirst():GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将目标怪兽身上的原有超量素材送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将选中的怪兽叠放至目标怪兽上作为超量素材
		Duel.Overlay(tc,g)
	end
end
