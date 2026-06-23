--黒熔龍騎ヴォルニゲシュ
-- 效果：
-- 7星怪兽×2
-- ①：1回合1次，把这张卡2个超量素材取除，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，可以选自己场上1只表侧表示怪兽，那个攻击力直到下个回合的结束时上升破坏的怪兽的原本的等级·阶级的数值×300。这个效果发动的回合，这张卡不能攻击。这张卡有龙族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
function c38694052.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为7的怪兽进行2次叠放
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡2个超量素材取除，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，可以选自己场上1只表侧表示怪兽，那个攻击力直到下个回合的结束时上升破坏的怪兽的原本的等级·阶级的数值×300。这个效果发动的回合，这张卡不能攻击。这张卡有龙族怪兽在作为超量素材的场合，这个效果在对方回合也能发动。
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
-- 判断该怪兽的超量素材中是否没有龙族怪兽
function c38694052.nomatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
-- 判断该怪兽的超量素材中是否有龙族怪兽
function c38694052.matcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(Card.IsRace,1,nil,RACE_DRAGON)
end
-- 支付效果代价，移除2个超量素材并设置此回合不能攻击
function c38694052.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) and c:GetAttackAnnouncedCount()==0 end
	-- 设置此卡在本回合不能攻击
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 选择场上1张表侧表示的卡作为破坏对象
function c38694052.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 判断是否存在场上1张表侧表示的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张表侧表示的卡作为破坏对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 判断被破坏的卡是否为怪兽类型
function c38694052.checkfilter(c)
	return c:GetPreviousTypeOnField()&TYPE_MONSTER~=0
end
-- 执行效果处理，破坏目标卡并可能提升怪兽攻击力
function c38694052.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
		-- 获取实际被破坏的卡组
		local og=Duel.GetOperatedGroup()
		-- 获取己方场上所有表侧表示的怪兽
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		if og:IsExists(c38694052.checkfilter,1,nil) and #g>0
			-- 询问玩家是否选择怪兽提升攻击力
			and Duel.SelectYesNo(tp,aux.Stringid(38694052,1)) then  --"是否选怪兽上升攻击力？"
			local star=0
			if tc:IsType(TYPE_XYZ) then star=tc:GetOriginalRank() else star=tc:GetOriginalLevel() end
			-- 提示玩家选择要提升攻击力的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(38694052,2))  --"请选择要上升攻击力的怪兽"
			local sg=g:Select(tp,1,1,nil)
			-- 显示所选怪兽被选为对象的动画效果
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			if tc then
				-- 设置攻击力提升效果，提升值为破坏怪兽的等级或阶级×300
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
