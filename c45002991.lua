--アークロード・パラディオン
-- 效果：
-- 包含连接怪兽的效果怪兽2只以上
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
-- ②：这张卡所连接区的怪兽不能攻击。
-- ③：1回合1次，把这张卡所连接区的自己1只「圣像骑士」怪兽或者「星遗物」怪兽解放，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c45002991.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2~99只效果怪兽为素材，且素材中必须至少有1只连接怪兽（由lcheck判定）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,99,c45002991.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽的原本攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c45002991.atkval)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c45002991.antg)
	c:RegisterEffect(e2)
	-- ③：1回合1次，把这张卡所连接区的自己1只「圣像骑士」怪兽或者「星遗物」怪兽解放，以对方场上1张表侧表示的卡为对象才能发动。那张卡的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45002991,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e3:SetCountLimit(1)
	e3:SetCost(c45002991.discost)
	e3:SetTarget(c45002991.distg)
	e3:SetOperation(c45002991.disop)
	c:RegisterEffect(e3)
end
-- 连接素材的追加条件：素材组中至少存在1只连接怪兽。
function c45002991.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- 计算这张卡所连接区内表侧表示怪兽的原本攻击力数值之和，作为攻击力上升的数值。
function c45002991.atkval(e,c)
	local g=e:GetHandler():GetLinkedGroup():Filter(Card.IsFaceup,nil)
	return g:GetSum(Card.GetBaseAttack)
end
-- 用于②效果的判定：若某只怪兽位于这张卡的连接区，则该怪兽不能攻击。
function c45002991.antg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
-- 用于解放代价的过滤器：选择位于这张卡连接区且属于「圣像骑士」或「星遗物」系列的怪兽。
function c45002991.cfilter(c,g)
	return c:IsSetCard(0xfe,0x116) and g:IsContains(c)
end
-- ③效果的发动代价：从自己场上解放1只位于这张卡连接区的「圣像骑士」或「星遗物」怪兽。
function c45002991.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 代价检查：确认自己场上存在至少1只满足解放条件的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c45002991.cfilter,1,nil,lg) end
	-- 选择1只满足条件的自己场上的「圣像骑士」或「星遗物」怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c45002991.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放，作为发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 取对象目标选择：选择对方场上1张表侧表示且能被无效化的卡作为对象，并登记无效化操作信息。
function c45002991.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理时验证目标：对象必须是对方场上的表侧表示卡且能被无效化。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 发动条件检查：确认对方场上存在至少1张表侧表示且能被无效化的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示，让玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从对方场上选择1张表侧表示且能被无效化的卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，声明本次处理将进行无效化（CATEGORY_DISABLE）。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：若对象仍表侧表示且与效果关联，则将对象卡效果无效化直到回合结束；若为陷阱怪兽，则追加使其怪兽效果无效的处理。
function c45002991.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取取对象效果所选定的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与对象卡关联的连锁无效化，重置时点为该卡变成里侧表示时。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
