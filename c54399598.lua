--魔術師の空華
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1张表侧表示的魔法·陷阱卡或者自己场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。以自己场上的卡为对象发动的场合，可以再从以下效果选1个适用。
-- ●从自己墓地把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ●从自己墓地把1张装备·永续魔法卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册一个取对象的魔陷发动效果，类别为破坏，自由时点发动，1回合只能发动1次，并设定目标函数与处理函数。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1张表侧表示的魔法·陷阱卡或者自己场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
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
-- 破坏对象的过滤条件：魔法·陷阱卡，且是自己场上的卡（任意表示）或者是对方场上表侧表示的卡。
function s.desfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		and (c:IsControler(tp) or c:IsFaceup())
end
-- 发动时目标函数：检查场上是否存在可作为对象的卡，让玩家选择1张要破坏的魔法·陷阱卡；若选择的是自己场上的卡，则追加回手·墓地相关类别并记录标记1，否则标记0；最后设置破坏操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.desfilter(chkc,tp) and chkc~=c end
	-- 发动条件检查：确认双方场上存在至少1张满足条件且能成为效果对象的魔法·陷阱卡（自身除外）。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c,tp) end
	-- 向玩家提示「请选择要破坏的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张满足条件的魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c,tp)
	if g:IsExists(Card.IsControler,1,nil,tp) then
		e:SetCategory(CATEGORY_DESTROY|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_DESTROY)
		e:SetLabel(0)
	end
	-- 设置操作信息：确定要破坏的卡为所选对象，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 放置对象的过滤条件：墓地中的怪兽卡，未被禁止出场，且在自己魔法与陷阱区域满足唯一性检查。
function s.stfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
end
-- 回收对象的过滤条件：墓地中的装备魔法卡或永续魔法卡，且可以加入手卡。
function s.thfilter(c)
	return (c:IsAllTypes(TYPE_EQUIP+TYPE_SPELL) or c:IsAllTypes(TYPE_CONTINUOUS+TYPE_SPELL)) and c:IsAbleToHand()
end
-- 效果处理：破坏对象卡；若对象是自己场上的卡（标记为1），则检查墓地是否存在可放置的怪兽或可回收的装备·永续魔法，让玩家选择适用其中1个效果或不做处理，然后分别执行放置怪兽或回收魔法的处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡仍与连锁相关且在场上，将其以效果破坏，并确认标记为1（即对象是自己场上的卡）才继续追加处理。
	if tc:IsRelateToChain() and tc:IsOnField() and Duel.Destroy(tc,REASON_EFFECT)~=0 and e:GetLabel()==1 then
		-- 检查自己墓地是否存在满足条件（不受王家长眠之谷影响）的可放置怪兽。
		local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,0,1,nil,tp)
			-- 并且自己的魔法与陷阱区域还有可用的空格。
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在满足条件（不受王家长眠之谷影响）的可回收装备·永续魔法卡。
		local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
		if not b1 and not b2 then return end
		-- 让玩家从可适用的选项中选择：放置怪兽、回收魔法或什么都不做。
		local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"放置怪兽"
			{b2,aux.Stringid(id,2),2},  --"回收魔法"
			{true,aux.Stringid(id,3),3})  --"什么都不做"
		-- 若选择了适用追加效果（不是什么都不做），则中断效果使后续处理视为不同时处理。
		if op~=3 then Duel.BreakEffect() end
		if op==1 then
			-- 向玩家提示「请选择要放置到场上的卡」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
			-- 让玩家从自己墓地选择1只满足条件的怪兽。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp)
			local pc=g:GetFirst()
			if pc then
				-- 将选择的怪兽表侧表示放置到自己的魔法与陷阱区域。
				Duel.MoveToField(pc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
				-- 从自己墓地把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
				local e1=Effect.CreateEffect(c)
				e1:SetCode(EFFECT_CHANGE_TYPE)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
				e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
				pc:RegisterEffect(e1)
			end
		elseif op==2 then
			-- 向玩家提示「请选择要加入手牌的卡」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			-- 让玩家从自己墓地选择1张满足条件的装备·永续魔法卡。
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if g:GetCount()>0 then
				-- 将选择的卡以效果原因加入持有者手卡。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的卡。
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
