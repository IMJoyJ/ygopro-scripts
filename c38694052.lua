--黒熔龍騎ヴォルニゲシュ
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡2个超量素材取除，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，可以选自己场上1只表侧表示怪兽，那个攻击力直到下个回合的结束时上升破坏的怪兽的原本的等级·阶级的数值×300。这个效果发动的回合，这张卡不能攻击。这张卡有龙族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
function c38694052.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只7星怪兽叠放来超量召唤。
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，可以选自己场上1只表侧表示怪兽，那个攻击力直到下个回合的结束时上升破坏的怪兽的原本的等级·阶级的数值×300。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38694052,0))  --"破坏场上1张表侧表示的卡"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e1:SetCondition(c38694052.nomatcon)
	e1:SetCost(c38694052.descost)
	e1:SetTarget(c38694052.destg)
	e1:SetOperation(c38694052.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c38694052.matcon)
	c:RegisterEffect(e2)
end
-- 无龙族超量素材时的发动条件：检查这张卡的超量素材中没有龙族怪兽，用于限制e1（起动效果）只能在无龙族素材时发动。
function c38694052.nomatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
-- 有龙族超量素材时的发动条件：检查这张卡的超量素材中有龙族怪兽，用于e2（诱发即时效果）能在对方回合发动。
function c38694052.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
-- 发动代价：取除这张卡2个超量素材，且本回合未进行过攻击宣言；同时给自己注册“这个效果发动的回合不能攻击”的誓约效果。
function c38694052.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) and c:GetAttackAnnouncedCount()==0 end
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 选择对象阶段：以场上1张表侧表示的卡为对象，检索并选择1张，登记破坏的操作信息。
function c38694052.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 发动时可行性检查：场上是否存在至少1张表侧表示的卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张表侧表示的卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁处理的操作信息：将破坏1张卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤函数：判断被破坏的这张卡在场上时是否为怪兽（使用离场前的种类信息）。
function c38694052.checkfilter(c)
	return c:GetPreviousTypeOnField()&TYPE_MONSTER~=0
end
-- 效果处理：破坏对象；若因此把怪兽破坏且自己场上有表侧表示怪兽，则询问是否选1只怪兽，根据被破坏怪兽的原本等级/阶级上升攻击力直到下个回合结束。
function c38694052.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
		-- 获取刚才破坏操作实际处理的卡片组（即被破坏的卡片）。
		local og=Duel.GetOperatedGroup()
		-- 获取自己场上表侧表示怪兽的集合，用于选择攻击力上升的目标。
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		if og:IsExists(c38694052.checkfilter,1,nil) and #g>0
			-- 询问玩家是否选择自己场上的怪兽上升攻击力。
			and Duel.SelectYesNo(tp,aux.Stringid(38694052,1)) then  --"是否选怪兽上升攻击力？"
			local star=0
			if tc:IsType(TYPE_XYZ) then star=tc:GetOriginalRank() else star=tc:GetOriginalLevel() end
			-- 向玩家显示“请选择要上升攻击力的怪兽”的提示消息。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38694052,2))  --"请选择要上升攻击力的怪兽"
			local sg=g:Select(tp,1,1,nil)
			-- 为选中的怪兽显示被选择动画，并记录其被选择为对象。
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			if tc then
				-- 那个攻击力直到下个回合的结束时上升破坏的怪兽的原本的等级·阶级的数值×300。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(star*300)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
				tc:RegisterEffect(e1)
			end
		end
	end
end
