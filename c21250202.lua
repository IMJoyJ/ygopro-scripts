--オッドアイズ・ペルソナ・ドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：只以自己场上的「异色眼」灵摆怪兽1只为对象的对方的效果发动的场合，那个回合的结束阶段发动。灵摆区域的这张卡特殊召唤，从自己的额外卡组选「异色眼假面龙」以外的1只表侧表示的「异色眼」灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- ①：1回合1次，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c21250202.initial_effect(c)
	-- 给这张卡赋予灵摆怪兽属性（灵摆召唤、灵摆卡发动相关功能）。
	aux.EnablePendulumAttribute(c)
	-- ①：只以自己场上的「异色眼」灵摆怪兽1只为对象的对方的效果发动的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(c21250202.regop1)
	c:RegisterEffect(e1)
	-- 那个回合的结束阶段发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c21250202.regop2)
	c:RegisterEffect(e2)
	-- 灵摆区域的这张卡特殊召唤，从自己的额外卡组选「异色眼假面龙」以外的1只表侧表示的「异色眼」灵摆怪兽在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21250202,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c21250202.spcon)
	e3:SetTarget(c21250202.sptg)
	e3:SetOperation(c21250202.spop)
	c:RegisterEffect(e3)
	-- ①：1回合1次，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21250202,1))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(c21250202.distg)
	e4:SetOperation(c21250202.disop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「异色眼」灵摆怪兽，用于判断对方效果的对象是否符合条件。
function c21250202.regfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsSetCard(0x99)
end
-- 当对方效果以自己场上1只表侧表示「异色眼」灵摆怪兽为对象时，为本卡记录该次连锁的编号，以便后续确认。
function c21250202.regop1(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and eg:GetCount()==1 and eg:IsExists(c21250202.regfilter,1,nil,tp) then
		e:GetHandler():RegisterFlagEffect(21250202,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,ev)
	end
end
-- 当连锁处理结束时，若之前记录的目标连锁编号正是本次处理完的连锁，则为本卡设置结束阶段可发动效果的标记。
function c21250202.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chain_ct={c:GetFlagEffectLabel(21250202)}
	for i=1,#chain_ct do
		if chain_ct[i]==ev then
			c:RegisterFlagEffect(21250203,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			return
		end
	end
end
-- 过滤额外卡组中表侧表示的「异色眼」灵摆怪兽，且不能是这张卡本身，也不能是被禁止的卡。
function c21250202.penfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM) and not c:IsCode(21250202) and not c:IsForbidden()
end
-- 发动条件：本卡拥有已满足触发条件的标记（21250203）。
function c21250202.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21250203)~=0
end
-- 效果发动时的目标处理：允许发动，并声明本效果包含特殊召唤这张卡。
function c21250202.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统登记操作信息：本效果将特殊召唤这张卡1只，用于连锁检测和时点判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：这张卡特殊召唤，成功后再从自己的额外卡组选择1张符合条件的「异色眼」灵摆怪兽放置到自己的灵摆区。
function c21250202.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将灵摆区的这张卡以表侧表示特殊召唤到自己场上，若特殊召唤成功则继续后续选卡放置处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 弹出选择提示，让玩家选择要放置到场上的卡（灵摆区的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从自己额外卡组选择1张满足penfilter的「异色眼」灵摆怪兽（表侧表示、非本卡、非禁止）。
		local g=Duel.SelectMatchingCard(tp,c21250202.penfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的灵摆怪兽以表侧表示移动到自己的灵摆区（即放置到灵摆刻度）。
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 定义无效对象筛选：选择表侧表示、效果未被无效且是从额外卡组特殊召唤的怪兽。
function c21250202.disfilter(c)
	-- 判断条件：该怪兽满足可无效的怪兽条件，且其特殊召唤的场所为额外卡组。
	return aux.NegateMonsterFilter(c) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 发动时的取对象处理：提示选择，并选择双方场上1只符合条件的怪兽作为对象。
function c21250202.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c21250202.disfilter(chkc) end
	-- 效果发动合法性检查：场上是否存在至少1只符合条件的对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(c21250202.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，让玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 从双方主要怪兽区选择1只符合条件的怪兽作为效果对象，并设为连锁对象。
	local g=Duel.SelectTarget(tp,c21250202.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 向系统登记操作信息：本效果将无效所选择的对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：获取对象怪兽，若其仍在场上表侧表示且与效果关联，则使其效果直到回合结束阶段无效。
function c21250202.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与对象怪兽相关联的连锁效果一并无效化，并在变里侧表示时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
