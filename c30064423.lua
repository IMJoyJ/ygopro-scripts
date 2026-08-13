--トポロジック・ブラスター・ドラゴン
-- 效果：
-- 效果怪兽2只以上
-- 自己不能在作为这张卡所连接区的额外怪兽区域让怪兽出现。
-- ①：这张卡在额外怪兽区域存在的状态，连接怪兽所连接区有怪兽特殊召唤的场合发动。从以下效果选1个适用。这个回合，自己的「拓扑冲击波龙」的效果不能有相同效果适用。
-- ●这张卡以外的场上的怪兽全部回到卡组。
-- ●场上的魔法·陷阱卡全部回到卡组。
-- ●把对方的额外卡组确认，那之内的1张除外。
local s,id,o=GetID()
-- 初始化函数：为拓扑冲击波龙注册连接召唤手续（效果怪兽2只以上）、苏生限制、禁止在自身连接到的额外怪兽区域让怪兽出现的永续效果，以及①的诱发效果。
function s.initial_effect(c)
	-- 设置连接召唤手续：使用2只以上效果怪兽作为连接素材（不要求其他限制）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- 自己不能在作为这张卡所连接区的额外怪兽区域让怪兽出现。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_MUST_USE_MZONE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.zonelimit)
	c:RegisterEffect(e1)
	-- ①：这张卡在额外怪兽区域存在的状态，连接怪兽所连接区有怪兽特殊召唤的场合发动。从以下效果选1个适用。这个回合，自己的「拓扑冲击波龙」的效果不能有相同效果适用。●这张卡以外的场上的怪兽全部回到卡组。●场上的魔法·陷阱卡全部回到卡组。●把对方的额外卡组确认，那之内的1张除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"发动"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.econ)
	e2:SetTarget(s.etg)
	e2:SetOperation(s.eop)
	c:RegisterEffect(e2)
end
-- 返回可用怪兽区域掩码：将双方主怪兽区设为可用，并把这张卡当前连接到的额外怪兽区域从可用区域中排除，从而禁止在该区域让怪兽出现。
function s.zonelimit(e)
	return 0x1f001f | (0x600060 & ~e:GetHandler():GetLinkedZone())
end
-- 过滤函数：判断一只怪兽是否处于zone掩码对应的连接区域；通过其位置与控制者编码出区域序号，并检查zone中该序号位是否为1。
function s.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:IsPreviousControler(1) then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0
end
-- ①效果的发动条件：本卡在额外怪兽区域（Sequence>4）、本次特殊召唤的怪兽不包含本卡，且其中存在被特殊召唤到本卡连接区（zone掩码）的怪兽。
function s.econ(e,tp,eg,ep,ev,re,r,rp)
	-- 把玩家0和玩家1的连接区域合并为一个32位掩码：玩家0的连接区在低16位，玩家1的连接区左移16位到高16位。
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,zone) and e:GetHandler():GetSequence()>4
end
-- 筛选可返回卡组的魔法·陷阱卡，用于‘场上的魔法·陷阱卡全部回到卡组’选项。
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- Target函数：在chk==0时检查三个可选分支（怪兽回卡组/魔陷回卡组/除外对方额外卡组）中至少有一个存在合法对象，以满足必发效果的发动条件。
function s.etg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方主要怪兽区是否存在除本卡以外可回到卡组的怪兽，对应选项1的可行性条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
		-- 检查场上是否存在可回到卡组的魔法·陷阱卡，对应选项2的可行性条件。
		or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 检查对方额外卡组是否存在可除外的卡，对应选项3的可行性条件。
		or Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
end
-- 效果处理函数：分别计算三个选项的可行性和本回合是否已使用，让玩家选择一项；若三项均不可行则直接终止；根据选择执行对应效果并登记防止重复使用的flag。
function s.eop(e,tp,eg,ep,ev,re,r,rp)
	-- 选项1可行条件：场上除本卡以外存在可回卡组的怪兽（aux.ExceptThisCard(e)用于排除本卡）。
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,1,aux.ExceptThisCard(e))
		-- 并且玩家tp身上没有id对应的flag（说明本回合尚未选择过‘怪兽全部回到卡组’）。
		and Duel.GetFlagEffect(tp,id)==0
	-- 选项2可行条件：场上存在可回卡组的魔法·陷阱卡。
	local b2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		-- 并且玩家tp身上没有id+o对应的flag（本回合尚未选择过‘魔陷全部回到卡组’）。
		and Duel.GetFlagEffect(tp,id+o)==0
	-- 选项3可行条件：对方额外卡组存在可除外的卡。
	local b3=Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil)
		-- 并且玩家tp身上没有id+o*2对应的flag（本回合尚未选择过‘除外对方额外卡组1张’）。
		and Duel.GetFlagEffect(tp,id+o*2)==0
	if not (b1 or b2 or b3) then return end
	-- 调用通用选项选择函数，将三个可行选项展示给玩家选择，返回所选选项编号存入op。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"怪兽全部回到卡组"
			{b2,aux.Stringid(id,2),2},  --"魔法·陷阱卡全部回到卡组"
			{b3,aux.Stringid(id,3),3})  --"除外额外卡组"
	if op==1 then
		-- 为玩家tp登记id标志（结束阶段重置），表示本回合已使用选项1，本回合不能再选相同效果。
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		-- 获取双方场上除本卡以外所有可回卡组的怪兽，准备执行‘怪兽全部回到卡组’。
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 将获取到的怪兽g全部送回持有者卡组并洗切，完成‘这张卡以外的场上的怪兽全部回到卡组’。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==2 then
		-- 为玩家tp登记id+o标志（结束阶段重置），表示本回合已使用选项2，本回合不能再选相同效果。
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		-- 获取场上所有可回卡组的魔法·陷阱卡，准备执行‘魔陷全部回到卡组’。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if g:GetCount()>0 then
			-- 将获取到的魔法·陷阱卡g全部送回持有者卡组并洗切，完成‘场上的魔法·陷阱卡全部回到卡组’。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	elseif op==3 then
		-- 为玩家tp登记id+o*2标志（结束阶段重置），表示本回合已使用选项3，本回合不能再选相同效果。
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		-- 获取对方额外卡组的全部卡片，作为要确认和选择除外的对象。
		local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续的除外动作作为独立效果段执行，避免时点冲突。
			Duel.BreakEffect()
			-- 将对方额外卡组的所有卡展示给tp玩家确认。
			Duel.ConfirmCards(tp,g,true)
			-- 设置选择提示信息为‘请选择要除外的卡’，供玩家在FilterSelect时看到。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local tg=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil)
			if tg:GetCount()>0 then
				-- 将选中的卡以表侧表示除外，实现‘那之内的1张除外’。
				Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
			end
			-- 洗切对方（1-tp）的额外卡组，使额外卡组在除外操作后随机化。
			Duel.ShuffleExtra(1-tp)
		end
	end
end
