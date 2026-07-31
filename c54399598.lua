--魔術師の空華
-- 效果：
-- 以对方场上1张表侧表示的魔法·陷阱卡，或者自己场上1张魔法·陷阱卡为对象；那张卡破坏，以自己场上的卡为对象来发动的场合，可以再从以下效果选1个适用。
-- ●从自己墓地把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ●从自己墓地把1张装备·永续魔法卡加入手卡。
-- 「魔术师之瞬绽花」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡片效果
function s.initial_effect(c)
	-- 以对方场上1张表侧表示的魔法·陷阱卡，或者自己场上1张魔法·陷阱卡为对象；那张卡破坏，以自己场上的卡为对象来发动的场合，可以再从以下效果选1个适用。●从自己墓地把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。●从自己墓地把1张装备·永续魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_EQUIP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤可以作为破坏对象的魔法·陷阱卡
function s.desfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsControler(tp) or c:IsFaceup())
end
-- 破坏及后续处理效果的对象选择与操作
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.desfilter(chkc,tp) and chkc~=c end
	-- 检查场上是否存在可以作为对象的表侧表示魔陷或自己魔陷
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1张符合条件的魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,tp)
	if g:IsExists(Card.IsControler,1,nil,tp) then
		e:SetCategory(CATEGORY_DESTROY|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
	-- 设置连锁操作信息：破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤墓地中可当作永续魔法放置的怪兽
function s.stfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤墓地中可回收的装备·永续魔法卡
function s.thfilter(c)
	return (c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL) or c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL)) and c:IsAbleToHand()
end
-- 破坏及后续效果的处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否成功破坏且发动时以自己场上的卡为对象
	if tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetLabel()==1 then
		-- 检查墓地是否有可放置为永续魔法的怪兽
		local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,0,1,nil,tp)
			-- 检查自己魔陷区是否有空格
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查墓地是否有可回收的装备·永续魔法卡
		local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		if not b1 and not b2 then return end
		-- 让玩家选择要适用的后续效果
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"放置怪兽"
			{b2,aux.Stringid(id,2),2},  --"回收魔法"
			{true,aux.Stringid(id,3),3})  --"什么都不做"
		-- 若选择适用效果，中断当前处理（视为不同时处理）
		if op~=3 then Duel.BreakEffect() end
		if op==1 then
			-- 提示选择要放置到场上的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 从墓地选择1只符合条件的怪兽
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
			local pc=g:GetFirst()
			if pc then
				-- 将选择的怪兽在魔陷区表侧表示放置
				Duel.MoveToField(pc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				-- 当作永续魔法卡使用
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				pc:RegisterEffect(e1)
			end
		elseif op==2 then
			-- 提示选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从墓地选择1张装备·永续魔法卡
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选择的魔法卡加入手牌
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方确认加入手牌的卡
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
