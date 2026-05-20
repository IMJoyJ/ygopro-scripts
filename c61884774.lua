--妖仙獣の神颪
-- 效果：
-- ①：自己场上没有怪兽存在的场合，可以从以下效果选择1个发动。这张卡的发动后，直到回合结束时自己不是「妖仙兽」怪兽不能特殊召唤。
-- ●从卡组把1只5星以上的「妖仙兽」怪兽加入手卡。
-- ●从卡组选「妖仙兽 左镰神柱」「妖仙兽 右镰神柱」各1张在自己的灵摆区域放置。这个效果在灵摆区域放置的卡在下次的对方结束阶段破坏。
function c61884774.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，可以从以下效果选择1个发动。这张卡的发动后，直到回合结束时自己不是「妖仙兽」怪兽不能特殊召唤。●从卡组把1只5星以上的「妖仙兽」怪兽加入手卡。●从卡组选「妖仙兽 左镰神柱」「妖仙兽 右镰神柱」各1张在自己的灵摆区域放置。这个效果在灵摆区域放置的卡在下次的对方结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_LIMIT_ZONE)
	e1:SetCondition(c61884774.condition)
	e1:SetTarget(c61884774.target)
	e1:SetOperation(c61884774.activate)
	e1:SetValue(c61884774.zones)
	c:RegisterEffect(e1)
end
-- 限制发动此卡时可以放置的魔法与陷阱区域（灵摆区域）的过滤函数
function c61884774.zones(e,tp,eg,ep,ev,re,r,rp)
	-- 若能发动检索效果则不限制发动区域，若只能发动放置灵摆效果则限制只能在最左和最右的魔陷区（灵摆区）发动
	return Duel.IsExistingMatchingCard(c61884774.thfilter,tp,LOCATION_DECK,0,1,nil) and 0xff or 0xe
end
-- 发动条件：自己场上没有怪兽存在
function c61884774.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 检索过滤条件：卡组中5星以上的「妖仙兽」怪兽
function c61884774.thfilter(c)
	return c:IsSetCard(0xb3) and c:IsLevelAbove(5) and c:IsAbleToHand()
end
-- 灵摆放置过滤条件：卡组中卡名为指定卡号且未被禁止使用的卡
function c61884774.pzfilter(c,cd)
	return c:IsCode(cd) and not c:IsForbidden()
end
-- 效果发动时的目标选择与可行性检查，并让玩家选择要发动的效果
function c61884774.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的5星以上「妖仙兽」怪兽
	local b1=Duel.IsExistingMatchingCard(c61884774.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查卡组中是否存在「妖仙兽 左镰神柱」
	local b2=(Duel.IsExistingMatchingCard(c61884774.pzfilter,tp,LOCATION_DECK,0,1,nil,65025250)
		-- 检查卡组中是否存在「妖仙兽 右镰神柱」
		and Duel.IsExistingMatchingCard(c61884774.pzfilter,tp,LOCATION_DECK,0,1,nil,91420254)
		-- 检查自己的两个灵摆区域是否都为空
		and Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1))
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 两个效果均可发动时，让玩家选择其中一个效果
		op=Duel.SelectOption(tp,aux.Stringid(61884774,0),aux.Stringid(61884774,1))  --"卡组检索/放置刻度"
	elseif b1 then
		-- 只能选择发动检索效果
		op=Duel.SelectOption(tp,aux.Stringid(61884774,0))  --"卡组检索"
	else
		-- 只能选择发动放置灵摆效果
		op=Duel.SelectOption(tp,aux.Stringid(61884774,1))+1  --"放置刻度"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置连锁信息：从卡组将1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(0)
	end
end
-- 效果处理函数：适用特殊召唤限制，并根据选择执行检索或放置灵摆效果，并为放置的灵摆卡注册结束阶段破坏的效果
function c61884774.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是「妖仙兽」怪兽不能特殊召唤。●从卡组把1只5星以上的「妖仙兽」怪兽加入手卡。●从卡组选「妖仙兽 左镰神柱」「妖仙兽 右镰神柱」各1张在自己的灵摆区域放置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c61884774.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不能特殊召唤「妖仙兽」以外怪兽的玩家效果
		Duel.RegisterEffect(e1,tp)
	end
	local op=e:GetLabel()
	if op==0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1只满足条件的「妖仙兽」怪兽
		local g=Duel.SelectMatchingCard(tp,c61884774.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手卡
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 检查两个灵摆区域是否依然可用，若不可用则不处理
		if not Duel.CheckLocation(tp,LOCATION_PZONE,0) or not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
		-- 从卡组获取第一张「妖仙兽 左镰神柱」
		local tc1=Duel.GetFirstMatchingCard(c61884774.pzfilter,tp,LOCATION_DECK,0,nil,65025250)
		-- 从卡组获取第一张「妖仙兽 右镰神柱」
		local tc2=Duel.GetFirstMatchingCard(c61884774.pzfilter,tp,LOCATION_DECK,0,nil,91420254)
		if not (tc1 and tc2) then return end
		-- 将「妖仙兽 左镰神柱」在自己的灵摆区域表侧表示放置
		Duel.MoveToField(tc1,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		-- 将「妖仙兽 右镰神柱」在自己的灵摆区域表侧表示放置
		Duel.MoveToField(tc2,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		local fid=c:GetFieldID()
		tc1:RegisterFlagEffect(61884774,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1,fid)
		tc2:RegisterFlagEffect(61884774,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1,fid)
		local sg=Group.FromCards(tc1,tc2)
		sg:KeepAlive()
		-- 这个效果在灵摆区域放置的卡在下次的对方结束阶段破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c61884774.descon)
		e1:SetOperation(c61884774.desop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 注册在下次对方结束阶段破坏这些卡的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特殊召唤限制：不能特殊召唤「妖仙兽」以外的怪兽
function c61884774.splimit(e,c)
	return not c:IsSetCard(0xb3)
end
-- 破坏过滤条件：带有对应标识（fid）的卡
function c61884774.desfilter(c,fid)
	return c:GetFlagEffectLabel(61884774)==fid
end
-- 破坏效果发动条件：必须是对方回合的结束阶段，且被放置的卡依然存在
function c61884774.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	-- 如果是自己的回合，则不满足“对方结束阶段”的条件
	if Duel.GetTurnPlayer()==tp then return false end
	if not g:IsExists(c61884774.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 破坏效果处理：破坏被该效果放置在灵摆区域的卡
function c61884774.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c61884774.desfilter,nil,e:GetLabel())
	-- 因效果将目标卡片破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
