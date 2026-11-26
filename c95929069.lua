--アイス・ハンド
-- 效果：
-- ①：这张卡被对方破坏送去墓地时，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。那之后，可以从卡组把1只「火焰手」特殊召唤。
function c95929069.initial_effect(c)
	-- ①：这张卡被对方破坏送去墓地时，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。那之后，可以从卡组把1只「火焰手」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95929069,0))  --"破坏并特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	-- 设置发动条件为通用函数aux.dogcon：确认这张卡是从己方场上被对方破坏并送去墓地
	e1:SetCondition(aux.dogcon)
	e1:SetTarget(c95929069.target)
	e1:SetOperation(c95929069.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：检查卡片是否为魔法卡或陷阱卡
function c95929069.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 发动检测、取对象及连锁信息设置：确认对方场上存在魔法·陷阱卡，选择1张作为对象并登记破坏操作信息
function c95929069.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c95929069.dfilter(chkc) end
	-- 发动条件检查：确认对方场上存在至少1张可成为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c95929069.dfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向己方提示选择要破坏的对方魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从对方场上选择1张魔法·陷阱卡作为连锁对象
	local g=Duel.SelectTarget(tp,c95929069.dfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记连锁的破坏操作信息，预计破坏所选对方魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 筛选条件：检查卡片是否为可特殊召唤的「火焰手」
function c95929069.spfilter(c,e,tp)
	return c:IsCode(68535320) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理流程：破坏作为对象的对方魔法·陷阱卡；若破坏成功且己方怪兽区有空位，则可选从卡组把1只「火焰手」特殊召唤
function c95929069.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的对方魔法·陷阱卡对象
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍在连锁中并以效果将其破坏，判断是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 检查己方主要怪兽区是否有空位，若无空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 获取己方卡组中全部可特殊召唤的「火焰手」卡片组
		local g=Duel.GetMatchingGroup(c95929069.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 若卡组存在可特召的「火焰手」，询问己方是否要特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(95929069,1)) then  --"是否要特殊召唤"
			-- 中断效果处理，使后续的特殊召唤与前面的破坏视为不同时处理
			Duel.BreakEffect()
			-- 向己方提示选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将所选「火焰手」以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
