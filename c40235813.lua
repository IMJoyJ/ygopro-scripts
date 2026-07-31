--時の黒魔術師
local s,id,o=GetID()
-- 初始化效果，注册卡牌的代码列表并创建主效果
function s.initial_effect(c)
	-- 记录该卡的代码列表，用于后续效果判断
	aux.AddCodeList(c,id)
	-- 创建发动效果，设置效果描述、分类、类型、时点、属性、提示时机、目标函数和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION+CATEGORY_DESTROY+CATEGORY_COIN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_COIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义检索手牌的过滤条件，排除自身并包含指定代码且可加入手牌的卡
function s.thfilter(c)
	-- 返回满足条件的卡：不是自身、记载了指定代码、可以加入手牌
	return not c:IsCode(id) and aux.IsCodeListed(c,id) and c:IsAbleToHand()
end
-- 检查卡组是否存在满足检索条件的卡，并判断是否已使用过该效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测卡组中是否存在满足检索条件的卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 若未支付费用或该玩家未使用过此效果，则允许发动
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检测己方场上是否存在至少1只怪兽
	local b2=Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 若未支付费用或该玩家未使用过此效果，则允许发动
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动选项，选项1为检索手牌，选项2为破坏并造成伤害
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
			-- 注册标识效果，防止该玩家在本回合再次发动此效果
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息，表示将从卡组中加入手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_COIN)
			-- 注册标识效果，防止该玩家在本回合再次发动此效果
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取己方场上的所有怪兽作为目标
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		-- 设置操作信息，表示将破坏场上怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		-- 设置操作信息，表示进行硬币投掷
		Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	end
end
-- 定义计算攻击力的过滤条件，排除攻击值小于0的卡并检查是否满足覆盖条件
function s.calfilter(c)
	if c:GetTextAttack()<0 then return false end
	-- 返回满足覆盖条件的卡
	return aux.covcheck(c)
end
-- 处理效果发动，根据选择的选项执行不同操作：选项1为检索手牌并触发后续效果，选项2为投掷硬币并破坏怪兽造成伤害
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组中选择一张满足条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡送入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看该卡
			Duel.ConfirmCards(1-tp,g)
		end
		-- 创建一个在结束阶段触发的效果，用于检索墓地中的卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.thop2)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该效果给玩家
		Duel.RegisterEffect(e1,tp)
	elseif e:GetLabel()==2 then
		local p=1-tp
		-- 提示玩家选择硬币正反面
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 让玩家宣言硬币正反面
		local coin=Duel.AnnounceCoin(tp)
		-- 投掷一次硬币
		local res=Duel.TossCoin(tp,1)
		if coin==res then
			p=tp
		end
		-- 获取指定玩家场上的所有怪兽作为目标
		local sg=Duel.GetMatchingGroup(aux.TRUE,p,LOCATION_MZONE,0,nil)
		local cg=sg:Filter(s.calfilter,nil)
		-- 破坏场上怪兽，若成功则继续处理后续效果
		if Duel.Destroy(sg,REASON_EFFECT)~=0 then
			-- 获取实际被操作的卡组
			local og=Duel.GetOperatedGroup()
			if og:GetCount()>0 and p==1-tp then
				-- 对对方造成伤害，伤害值为被破坏怪兽中满足条件的攻击力总和的一半向上取整
				Duel.Damage(1-tp,math.ceil((og&cg):GetSum(Card.GetTextAttack,nil)/2),REASON_EFFECT)
			end
		end
	end
end
-- 定义墓地检索的过滤条件，必须是自身且可加入手牌
function s.thfilter2(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
-- 处理结束阶段效果，从墓地中检索一张自身卡并加入手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家该卡发动了效果
	Duel.Hint(HINT_CARD,0,id)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从墓地中选择一张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看该卡
		Duel.ConfirmCards(1-tp,g)
	end
end
