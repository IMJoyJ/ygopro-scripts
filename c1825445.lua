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
	-- 为“不能成为效果对象”效果设置判定函数 aux.tgoval，使对方发动的效果无法将符合条件的「超级量子」卡选为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只「超级量子」超量怪兽为对象才能发动。选作为对象的怪兽以外的自己场上1只表侧表示怪兽在作为对象的怪兽下面重叠作为超量素材。
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
-- 定义①效果的适用条件：当前为主要阶段1且当前回合玩家为这张卡的控制者，即满足“自己主要阶段1内”。
function c1825445.tgcon(e)
	-- 判断当前是否为自己（控制者）的主要阶段1：当前阶段为PHASE_MAIN1，且当前回合玩家等于该卡控制者。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
-- 作为①效果的过滤函数，判定场上的卡是否为「超级量子」卡，只保护含有「超级量子」字段的卡。
function c1825445.tglimit(e,c)
	return c:IsSetCard(0xdc)
end
-- 定义②效果的对象筛选条件：选择自己场上1只表侧表示、超量怪兽且带有「超级量子」字段的怪兽，并且自己场上还存在另一只可作为超量素材的表侧表示怪兽。
function c1825445.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xdc)
		-- 追加检查自己怪兽区存在至少1只除对象怪兽以外、满足filter2条件的表侧表示怪兽，确保能够选取重叠素材。
		and Duel.IsExistingMatchingCard(c1825445.filter2,tp,LOCATION_MZONE,0,1,c)
end
-- 定义可作为超量素材的怪兽条件：必须是表侧表示的怪兽卡、可以作为超量素材，并且不免疫此效果。
function c1825445.filter2(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 定义②效果发动时的目标选择逻辑：检查是否存在合法对象，若存在则让玩家选择1只符合条件的「超级量子」超量怪兽为对象。
function c1825445.mttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c1825445.filter1(chkc,e,tp) end
	-- 在发动合法性检查阶段，确认自己场上存在1只符合条件的「超级量子」超量怪兽且能成为此效果对象，才能发动。
	if chk==0 then return Duel.IsExistingTarget(c1825445.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送“请选择效果的对象”的提示信息，用于选择目标时的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足filter1的「超级量子」超量怪兽，并将其设定为当前连锁的效果对象。
	Duel.SelectTarget(tp,c1825445.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
-- 定义②效果的处理操作：取得对象超量怪兽；若对象仍相关且不免疫此效果，则选择1只自己场上表侧表示怪兽作为超量素材；若该素材原本叠放有超量素材则先将原有素材送去墓地，然后将选中的怪兽叠放在对象怪兽下方。
function c1825445.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时所选择的超量怪兽对象。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送“请选择要作为超量素材的卡”的提示信息，用于选择素材时的显示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从自己场上选择1只满足filter2且不是对象怪兽的表侧表示怪兽，作为要叠放的超量素材。
	local g=Duel.SelectMatchingCard(tp,c1825445.filter2,tp,LOCATION_MZONE,0,1,1,tc,e)
	if g:GetCount()>0 then
		local og=g:GetFirst():GetOverlayGroup()
		if og:GetCount()>0 then
			-- 若选中的素材怪兽原本叠放有超量素材，则将这些原有超量素材以规则原因送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将选择的怪兽g作为超量素材叠放在对象超量怪兽tc的下方。
		Duel.Overlay(tc,g)
	end
end
