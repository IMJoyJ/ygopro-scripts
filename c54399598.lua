--Fleeting Flower of the Magician
-- 效果：
-- 以对方场上1张表侧表示的魔法·陷阱卡，或者自己场上1张魔法·陷阱卡为对象；那张卡破坏，以自己场上的卡为对象来发动的场合，可以再从以下效果选1个适用。
-- ●从自己墓地把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ●从自己墓地把1张装备·永续魔法卡加入手卡。
-- 「魔术师之瞬绽花」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，定义「魔术师之瞬绽花」的发动效果。
function s.initial_effect(c)
	-- 「魔术师之瞬绽花」在1回合只能发动1张。以对方场上1张表侧表示的魔法·陷阱卡，或者自己场上1张魔法·陷阱卡为对象；那张卡破坏，以自己场上的卡为对象来发动的场合，可以再从以下效果选1个适用。
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
-- 过滤条件：自己场上的魔法·陷阱卡，或者对方场上表侧表示的魔法·陷阱卡。
function s.desfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动的目标选择与合法性检测，若选择自己场上的卡则标记后续可适用追加效果，并设置破坏的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.desfilter(chkc,tp) and chkc~=c end
	-- 检查场上是否存在可以作为破坏对象的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择1张符合条件的魔法·陷阱卡作为对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,tp)
	if g:IsExists(Card.IsControler,1,nil,tp) then
		e:SetCategory(CATEGORY_DESTROY|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
	-- 设置效果处理信息为破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤条件：墓地中可以作为永续魔法卡放置到魔法与陷阱区域的怪兽。
function s.stfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 过滤条件：墓地中可以加入手牌的装备魔法卡或永续魔法卡。
function s.thfilter(c)
	return (c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL) or c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL)) and c:IsAbleToHand()
end
-- 效果处理的核心逻辑：破坏对象卡，若对象是自己场上的卡，则可选择适用后续的追加效果之一。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍存在于场上并成功将其破坏，且发动时选择的是自己场上的卡。
	if tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetLabel()==1 then
		-- 检查自己墓地是否存在可以放置的怪兽（受王家长眠之谷影响）。
		local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,0,1,nil,tp)
			-- 且自己的魔法与陷阱区域有空位。
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在可以加入手牌的装备·永续魔法卡（受王家长眠之谷影响）。
		local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		if not b1 and not b2 then return end
		-- 让玩家选择要适用的追加效果或不适用。
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"放置怪兽"
			{b2,aux.Stringid(id,2),2},  --"回收魔法"
			{true,aux.Stringid(id,3),3})  --"什么都不做"
		-- 如果玩家选择了适用追加效果，则中断当前效果处理，使后续处理不与破坏同时进行。
		if op~=3 then Duel.BreakEffect() end
		if op==1 then
			-- 提示玩家选择要放置到场上的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 从自己墓地选择1只满足条件的怪兽（受王家长眠之谷影响）。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
			local pc=g:GetFirst()
			if pc then
				-- 将选中的怪兽表侧表示放置到自己的魔法与陷阱区域。
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
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 从自己墓地选择1张装备·永续魔法卡（受王家长眠之谷影响）。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选中的卡加入手牌。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手牌的卡。
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
