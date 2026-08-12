--道化の一座 メテオ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：在自己怪兽的上级召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●双方的场上·墓地的同调怪兽全部回到额外卡组。
-- ●以「道化一座 舞流星小丑」以外的自己墓地1张「道化一座」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含同调召唤手续、上级召唤成功时封锁对方发动的效果、以及被解放时选择发动的效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：在自己怪兽的上级召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.sucop)
	c:RegisterEffect(e1)
	-- ①：在自己怪兽的上级召唤成功时对方不能把魔法·陷阱·怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(s.cedop)
	c:RegisterEffect(e2)
	-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"选择效果"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 限制连锁发动的过滤函数，只允许自己（tp）发动效果，即对方（rp）不能发动效果。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤在自己场上上级召唤成功的怪兽。
function s.sucfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsControler(tp)
end
-- 上级召唤成功时的效果处理，若在连锁0（非连锁中）则直接限制对方发动效果；若在连锁1中，则注册标记并创建临时效果以在连锁结束时应用限制。
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	if not eg:IsExists(s.sucfilter,1,nil,tp) then return end
	-- 判断当前是否不在连锁处理中（即上级召唤成功作为动作直接发生，不入连锁）。
	if Duel.GetCurrentChain()==0 then
		-- 设定直到连锁结束为止的连锁限制，使对方不能发动效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	-- 判断当前是否在连锁1的处理中（例如通过卡的效果在连锁中进行上级召唤）。
	elseif Duel.GetCurrentChain()==1 then
		-- 为玩家注册全局标识，用于记录在连锁中发生了上级召唤成功。
		Duel.RegisterFlagEffect(tp,id+o*2,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ②：这张卡被解放的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。●双方的场上·墓地的同调怪兽全部回到额外卡组。●以「道化一座 舞流星小丑」以外的自己墓地1张「道化一座」卡为对象才能发动。那张卡加入手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(s.resetop)
		-- 注册全局效果，在有新连锁发动时重置上级召唤成功的标识。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册全局效果，在效果处理被中断时重置上级召唤成功的标识。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置上级召唤成功标识并使该临时效果失效。
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	-- 手动清除玩家的上级召唤成功标识。
	Duel.ResetFlagEffect(tp,id+o*2)
	e:Reset()
end
-- 连锁结束时的效果处理，若存在上级召唤成功标识，则在此时应用限制对方发动的效果，并清除标识。
function s.cedop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否拥有上级召唤成功的标识。
	if Duel.GetFlagEffect(tp,id+o*2)~=0 then
		-- 在连锁结束时，设定直到下一个连锁结束为止的连锁限制，使对方不能发动效果。
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
	-- 清除玩家的上级召唤成功标识。
	Duel.ResetFlagEffect(tp,id+o*2)
end
-- 过滤双方场上、墓地可以回到额外卡组的同调怪兽。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToDeck()
end
-- 过滤自己墓地「道化一座 舞流星小丑」以外可以加入手卡的「道化一座」卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1dc) and c:IsAbleToHand()
end
-- 被解放时选择效果的发动准备与目标选择，根据玩家的选择分支注册对应的效果分类、属性并进行对象选择或操作信息设置。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查双方场上、墓地是否存在至少1只同调怪兽。
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,nil)
		-- 并且检查本回合是否尚未选择过第一个效果（回到额外卡组）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查自己墓地是否存在可以成为效果对象的「道化一座 舞流星小丑」以外的「道化一座」卡。
	local b2=Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且检查本回合是否尚未选择过第二个效果（回收墓地卡片）。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 提供选项供玩家选择要发动的效果分支。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"回收同调怪兽"
			{b2,aux.Stringid(id,2),2})  --"回到手卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TODECK)
			e:SetProperty(EFFECT_FLAG_DELAY)
			-- 注册第一个效果（回到额外卡组）在本回合已选择过的全局标识。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 获取双方场上、墓地所有的同调怪兽。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 设置操作信息为将这些同调怪兽送回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_GRAVE+LOCATION_MZONE)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
			-- 注册第二个效果（回收墓地卡片）在本回合已选择过的全局标识。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 提示玩家选择要返回手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择自己墓地1张满足条件的「道化一座」卡作为效果对象。
		local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置操作信息为将选择的对象卡片加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 被解放时选择效果的实际处理，根据之前选择的分支，执行将同调怪兽全部回到额外卡组，或者将墓地的目标卡片加入手卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 获取当前双方场上、墓地所有的同调怪兽。
		local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,nil)
		-- 检查这些卡片是否受到「王家长眠之谷」的影响，若受影响则使效果无效。
		if aux.NecroValleyNegateCheck(g) then return end
		-- 将这些同调怪兽全部送回持有者的额外卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	elseif e:GetLabel()==2 then
		-- 获取作为效果对象的那张墓地卡片。
		local tc=Duel.GetFirstTarget()
		-- 检查该卡片是否仍与当前连锁相关，且不受「王家长眠之谷」的影响。
		if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
			-- 将该卡片加入玩家手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
