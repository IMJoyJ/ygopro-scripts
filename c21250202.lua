--オッドアイズ・ペルソナ・ドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：只以自己场上的「异色眼」灵摆怪兽1只为对象的对方的效果发动的场合，那个回合的结束阶段发动。灵摆区域的这张卡特殊召唤，从自己的额外卡组选「异色眼假面龙」以外的1只表侧表示的「异色眼」灵摆怪兽在自己的灵摆区域放置。
-- 【怪兽效果】
-- ①：1回合1次，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c21250202.initial_effect(c)
	-- 为该卡添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：只以自己场上的「异色眼」灵摆怪兽1只为对象的对方的效果发动的场合，那个回合的结束阶段发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_BECOME_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(c21250202.regop1)
	c:RegisterEffect(e1)
	-- ①：只以自己场上的「异色眼」灵摆怪兽1只为对象的对方的效果发动的场合，那个回合的结束阶段发动
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c21250202.regop2)
	c:RegisterEffect(e2)
	-- ①：只以自己场上的「异色眼」灵摆怪兽1只为对象的对方的效果发动的场合，那个回合的结束阶段发动
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
	-- ①：1回合1次，以从额外卡组特殊召唤的1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动
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
-- 过滤函数，用于筛选满足条件的灵摆怪兽（在主要怪兽区、控制者为tp、是灵摆怪兽、表侧表示、是异色眼卡组）
function c21250202.regfilter(c,tp)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsType(TYPE_PENDULUM) and c:IsFaceup() and c:IsSetCard(0x99)
end
-- 当对方的效果以自己场上的异色眼灵摆怪兽为对象时，记录该连锁编号到flag 21250202中
function c21250202.regop1(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and eg:GetCount()==1 and eg:IsExists(c21250202.regfilter,1,nil,tp) then
		e:GetHandler():RegisterFlagEffect(21250202,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,ev)
	end
end
-- 当连锁处理结束时，检查该连锁是否为之前记录的编号，如果是则设置flag 21250203
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
-- 过滤函数，用于筛选满足条件的异色眼灵摆怪兽（表侧表示、异色眼卡组、不是本卡、未被禁止）
function c21250202.penfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99) and c:IsType(TYPE_PENDULUM) and not c:IsCode(21250202) and not c:IsForbidden()
end
-- 判断是否满足灵摆召唤条件（flag 21250203是否被设置）
function c21250202.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(21250203)~=0
end
-- 设置灵摆召唤效果的操作信息，表示将特殊召唤该卡
function c21250202.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置灵摆召唤效果的操作信息，表示将特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行灵摆召唤效果，将该卡特殊召唤到场上，并从额外卡组选择一张异色眼灵摆怪兽放置到灵摆区
function c21250202.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 判断是否成功特殊召唤该卡
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 提示玩家选择要放置到灵摆区的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从额外卡组选择一张满足条件的异色眼灵摆怪兽
		local g=Duel.SelectMatchingCard(tp,c21250202.penfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的异色眼灵摆怪兽移动到灵摆区
			Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		end
	end
end
-- 过滤函数，用于筛选满足条件的怪兽（符合无效化条件且是从额外卡组召唤的）
function c21250202.disfilter(c)
	-- 符合无效化条件且是从额外卡组召唤的怪兽
	return aux.NegateMonsterFilter(c) and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 设置无效化效果的目标选择函数，选择一个满足条件的怪兽作为目标
function c21250202.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c21250202.disfilter(chkc) end
	-- 判断是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c21250202.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择一个满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c21250202.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置无效化效果的操作信息，表示将使目标怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行无效化效果，使目标怪兽效果无效并设置其效果重置条件
function c21250202.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
