--螺旋のストライクバースト
-- 效果：
-- ①：可以从以下效果选择1个发动。
-- ●自己场上有「异色眼」卡存在的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ●从卡组的怪兽以及自己的额外卡组的表侧表示的灵摆怪兽之中选1只7星「异色眼」怪兽加入手卡。
function c82768499.initial_effect(c)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c82768499.target)
	e1:SetOperation(c82768499.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「异色眼」卡
function c82768499.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99)
end
-- 过滤条件：卡组的怪兽或自己额外卡组表侧表示的7星「异色眼」怪兽
function c82768499.thfilter(c)
	return c:IsSetCard(0x99) and c:IsLevel(7) and (c:IsFaceup() or not c:IsLocation(LOCATION_EXTRA)) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与分支判定
function c82768499.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查自己场上是否存在「异色眼」卡
	local b1=Duel.IsExistingMatchingCard(c82768499.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查场上是否存在除这张卡以外可以作为破坏对象的卡
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	-- 检查卡组或额外卡组是否存在可加入手卡的7星「异色眼」怪兽
	local b2=Duel.IsExistingMatchingCard(c82768499.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个效果均满足时，让玩家选择发动其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(82768499,0),aux.Stringid(82768499,1))  --"卡片破坏/加入手卡"
	elseif b1 then
		-- 仅满足破坏效果时，强制选择第一个效果
		op=Duel.SelectOption(tp,aux.Stringid(82768499,0))  --"卡片破坏"
	else
		-- 仅满足检索效果时，强制选择第二个效果
		op=Duel.SelectOption(tp,aux.Stringid(82768499,1))+1  --"加入手卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择场上1张卡作为破坏的对象
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		-- 设置效果处理信息为破坏选中的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		-- 设置效果处理信息为从卡组或额外卡组将1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
	end
end
-- 效果处理的分支执行函数
function c82768499.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==0 then
		c82768499.desop(e,tp,eg,ep,ev,re,r,rp)
	elseif op==1 then
		c82768499.thop(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 破坏效果的具体处理函数
function c82768499.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的破坏对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在效果处理时仍存在于场上，则将其破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 检索效果的具体处理函数
function c82768499.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或额外卡组选择1只满足条件的7星「异色眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c82768499.thfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
