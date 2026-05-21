--エピュアリィ・ビューティ
-- 效果：
-- 2星怪兽×2
-- ①：1回合1次，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这张卡有「纯爱妖精可爱回忆」在作为超量素材的场合，这个效果在对方回合也能发动。
-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在这张卡下面重叠作为超量素材。那之后，可以选对方场上1只怪兽把表示形式变更。这个效果1回合可以使用最多3次。
local s,id,o=GetID()
-- 定义初始化效果函数，注册XYZ召唤手续、①效果（无效对方怪兽效果，根据是否有特定素材决定是起动效果还是即时效果）以及②效果（速攻魔法发动时将其叠放为素材并变更对方怪兽表示形式）
function s.initial_effect(c)
	-- 将「纯爱妖精可爱回忆」的卡片密码加入到这张卡记载的卡片列表中
	aux.AddCodeList(c,29599813)
	-- 为这张卡添加XYZ召唤手续：2星怪兽×2
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这张卡有「纯爱妖精可爱回忆」在作为超量素材的场合，这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方怪兽效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCondition(s.discon2)
	c:RegisterEffect(e2)
	-- ②：自己把「纯爱妖精」速攻魔法卡发动时才能发动。场上的那张卡在这张卡下面重叠作为超量素材。那之后，可以选对方场上1只怪兽把表示形式变更。这个效果1回合可以使用最多3次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动的速攻魔法卡在这张卡下面重叠"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(3)
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
-- 检查这张卡的超量素材中是否存在「纯爱妖精可爱回忆」，作为在对方回合也能发动（即时效果）的条件
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,29599813)
end
-- 检查这张卡的超量素材中是否不存在「纯爱妖精可爱回忆」，作为只能在自己回合发动（起动效果）的条件
function s.discon2(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,29599813)
end
-- 效果①的对象合法性检查：如果已选择对象，判定该对象是否在对方场上的怪兽区，且是未被无效的效果怪兽
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		-- 并且该对象必须是表侧表示、未被无效的效果怪兽
		and aux.NegateEffectMonsterFilter(chkc) end
	-- 效果①发动时的可行性检查：判定对方场上是否存在至少1只可以被无效的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示当前发动的效果（无效对方怪兽效果）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示当前操作玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让当前操作玩家选择对方场上1只可以被无效的效果怪兽作为效果对象
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 定义效果①的处理函数：使作为对象的怪兽的效果直到回合结束时无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 使与该对象怪兽相关的连锁都无效化，若该怪兽变成里侧表示则重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 效果②的发动条件：自己把「纯爱妖精」速攻魔法卡发动时，且该卡可以作为超量素材
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp
		and re:IsActiveType(TYPE_QUICKPLAY) and re:GetHandler():IsSetCard(0x18c) and re:GetHandler():IsCanOverlay()
end
-- 效果②的靶向与可行性检查：确认发动的速攻魔法卡可以作为超量素材，并建立效果联系
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanOverlay() end
	-- 向对方玩家提示当前发动的效果（将发动的速攻魔法卡重叠作为超量素材）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	re:GetHandler():CreateEffectRelation(e)
end
-- 定义效果②的处理函数：将发动的速攻魔法卡在这张卡下面重叠作为超量素材，那之后可以选对方场上1只怪兽变更表示形式
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=re:GetHandler()
	if c:IsRelateToChain() and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) and tc:IsCanOverlay() then
		tc:CancelToGrave()
		-- 将该速攻魔法卡重叠在这张卡下面作为超量素材
		Duel.Overlay(c,tc)
		-- 检查对方场上是否存在可以变更表示形式的怪兽
		if Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否选择发动后续的“变更对方场上1只怪兽的表示形式”效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选对方怪兽变更表示形式？"
			-- 中断当前效果处理，使前后的叠放素材与变更表示形式不视为同时处理
			Duel.BreakEffect()
			-- 提示当前操作玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 让当前操作玩家选择对方场上1只可以变更表示形式的怪兽
			local tg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
			-- 变更所选怪兽的表示形式（表侧守备、里侧守备、表侧攻击）
			Duel.ChangePosition(tg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
