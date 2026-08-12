--断影烈破
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：为让怪兽的效果发动而让手卡·场上的卡被表侧除外的场合才能发动。从除外的卡种类对应的以下让1个适用。
-- ●怪兽：场上1张表侧表示的魔法·陷阱卡的效果直到回合结束时无效。
-- ●魔法：自己抽2张。
-- ●陷阱：场上1只怪兽除外。
-- ②：这张卡为让怪兽的效果发动而被除外的场合才能发动。自己的除外状态的1张其他卡加入手卡。
local s,id,o=GetID()
-- 初始化函数：注册卡片的发动效果、①效果、②效果，并注册延迟事件和全局监听器
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：为让怪兽的效果发动而让手卡·场上的卡被表侧除外的场合才能发动。从除外的卡种类对应的以下让1个适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"效果发动"
	e2:SetCategory(CATEGORY_DISABLE|CATEGORY_DRAW|CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.actg)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	-- 注册合并延迟事件，将同一时点内发生的卡片除外事件合并为自定义事件触发
	aux.RegisterMergedDelayedEvent(c,id,EVENT_REMOVE,g)
	-- ②：这张卡为让怪兽的效果发动而被除外的场合才能发动。自己的除外状态的1张其他卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		-- ①：为让怪兽的效果发动而让手卡·场上的卡被表侧除外的场合才能发动。从除外的卡种类对应的以下让1个适用。●怪兽：场上1张表侧表示的魔法·陷阱卡的效果直到回合结束时无效。●魔法：自己抽2张。●陷阱：场上1只怪兽除外。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_REMOVE)
		ge1:SetOperation(s.checkop)
		-- 注册全局环境效果，用于持续监听卡片除外事件
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局事件处理函数：若卡片是因为怪兽效果发动而被除外，则为其注册一个临时的Flag标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历当前事件中所有被除外的卡片
	for tc in aux.Next(eg) do
		if re and re:GetHandler():IsType(TYPE_MONSTER) then
			tc:RegisterFlagEffect(id,RESET_EVENT+RESET_REMOVE,0,1)
		end
	end
end
-- 过滤函数：筛选出因怪兽效果发动作为Cost而从手卡或场上表侧除外的卡片
function s.cfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(id)~=0
		and c:IsReason(REASON_COST)
		and c:IsPreviousLocation(LOCATION_ONFIELD+LOCATION_HAND)
end
-- 过滤函数：筛选出场上表侧表示且可以被无效的魔法·陷阱卡
function s.disfiter(c)
	-- 判断卡片是否为魔法或陷阱卡，且符合可被无效的条件
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and aux.NegateAnyFilter(c)
end
-- ①效果的发动准备：根据因怪兽效果发动而除外的卡片种类，检测并设置对应的效果分类与标签值
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.cfilter,1,nil)
	-- 检查场上是否存在至少1张可以被无效的表侧表示魔法·陷阱卡
	local b1=Duel.IsExistingMatchingCard(s.disfiter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and g:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
	-- 检查当前玩家是否可以效果抽2张卡
	local b2=Duel.IsPlayerCanDraw(tp,2)
		and g:IsExists(Card.IsType,1,nil,TYPE_SPELL)
	-- 检查场上是否存在至少1只可以被除外的怪兽
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and g:IsExists(Card.IsType,1,nil,TYPE_TRAP)
	if chk==0 then return b1 or b2 or b3 end
	local category=0
	local label=0
	if b1 then
		category=category|CATEGORY_DISABLE
		label=label|TYPE_MONSTER
	end
	if b2 then
		category=category|CATEGORY_DRAW
		label=label|TYPE_SPELL
	end
	if b3 then
		category=category|CATEGORY_REMOVE
		label=label|TYPE_TRAP
	end
	e:SetCategory(category)
	e:SetLabel(label)
end
-- ①效果的处理：根据除外的卡片种类，让玩家选择并适用对应的效果（无效魔陷、抽2张卡或除外怪兽）
function s.acop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local label=e:GetLabel()
	local g=eg:Filter(s.cfilter,1,nil)
	-- 检查场上是否存在可无效的魔陷，且除外的卡中包含怪兽卡
	local b1=Duel.IsExistingMatchingCard(s.disfiter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and label&TYPE_MONSTER~=0
	-- 检查玩家是否可以抽卡，且除外的卡中包含魔法卡
	local b2=Duel.IsPlayerCanDraw(tp)
		and label&TYPE_SPELL~=0
	-- 检查场上是否存在可除外的怪兽，且除外的卡中包含陷阱卡
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and label&TYPE_TRAP~=0
	if not b1 and not b2 and not b3 then return end
	-- 提示玩家从当前满足条件的可用选项中选择一个适用
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"怪兽：魔陷无效"
		{b2,aux.Stringid(id,3),2},  --"魔法：抽卡"
		{b3,aux.Stringid(id,4),3})  --"陷阱：怪兽除外"
	if op==1 then
		-- 给玩家发送提示信息，要求选择要无效的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家选择场上1张表侧表示的魔法·陷阱卡
		local sg=Duel.SelectMatchingCard(tp,s.disfiter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if sg:GetCount()>0 then
			-- 闪烁显示被选中的卡片，并将其记录为效果对象
			Duel.HintSelection(sg)
			local tc=sg:GetFirst()
			-- 使与目标卡片相关的连锁效果无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- ●怪兽：场上1张表侧表示的魔法·陷阱卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- ●怪兽：场上1张表侧表示的魔法·陷阱卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- ●怪兽：场上1张表侧表示的魔法·陷阱卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	elseif op==2 then
		-- 让玩家因效果抽2张卡
		Duel.Draw(tp,2,REASON_EFFECT)
	elseif op==3 then
		-- 获取场上所有可以被除外的怪兽卡
		local tg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if tg:GetCount()>0 then
			-- 给玩家发送提示信息，要求选择要除外的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 闪烁显示被选中的怪兽卡，并将其记录为效果对象
			Duel.HintSelection(sg)
			-- 以效果将选中的怪兽卡表侧表示除外
			Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果的发动条件：这张卡作为Cost被除外，且该连锁是由怪兽效果的发动所引起的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数：筛选出可以加入手牌的除外状态的卡片
function s.thfilter(c)
	return c:IsAbleToHand()
end
-- ②效果的发动准备：检查除外状态是否存在其他卡片，并设置将除外卡片加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的除外状态是否存在至少1张除这张卡以外的其他可以加入手牌的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 设置效果处理信息：将1张除外状态的卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end
-- ②效果的处理：让玩家选择自己除外状态的1张其他卡片加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择自己除外状态的1张其他卡片（排除这张卡自身）
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 闪烁显示被选中的除外卡片，并将其记录为效果对象
		Duel.HintSelection(g)
		-- 以效果将选中的卡片加入持有者的手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
