--絢嵐たる見神
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己抽2张。那之后，手卡有「绚岚」卡或速攻魔法卡存在的场合，选那之内的1张丢弃。不存在的场合，自己手卡全部丢弃。
-- ●从自己的卡组·墓地把1张「旋风」加入手卡。
-- ②：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己的魔法与陷阱区域盖放。
local s,id,o=GetID()
-- 注册卡片效果，包括发动效果和盖放效果
function s.initial_effect(c)
	-- 记录该卡与「旋风」卡的关联
	aux.AddCodeList(c,5318639)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DRAW+CATEGORY_HANDES)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMING_DRAW_PHASE+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己的魔法与陷阱区域盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检索「绚岚」卡或速攻魔法卡
function s.thfilter(c)
	return c:IsCode(5318639) and c:IsAbleToHand()
end
-- 判断是否可以发动效果，包括抽卡和检索旋风
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽2张卡
	local b1=Duel.IsPlayerCanDraw(tp,2)
		-- 判断该效果是否已使用（1回合1次）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 判断卡组或墓地是否存在「旋风」卡
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
		-- 判断该效果是否已使用（1回合1次）
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择发动效果
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"抽卡效果"
			{b2,aux.Stringid(id,3),2})  --"检索旋风"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
			e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			-- 注册抽卡效果已使用的标识
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置抽卡效果的目标玩家
		Duel.SetTargetPlayer(tp)
		-- 设置抽卡效果的抽卡数量
		Duel.SetTargetParam(2)
		-- 设置抽卡效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			e:SetProperty(0)
			-- 注册检索旋风效果已使用的标识
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置检索旋风效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
-- 过滤函数，用于判断手牌是否为「绚岚」卡或速攻魔法卡
function s.cfilter(c)
	return (c:IsSetCard(0x1d1) or c:IsType(TYPE_QUICKPLAY)) and c:IsDiscardable(REASON_EFFECT)
end
-- 处理发动效果的执行逻辑
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取连锁中的目标玩家和抽卡数量
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行抽卡操作
		if Duel.Draw(p,d,REASON_EFFECT)==d then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 判断手牌是否存在「绚岚」卡或速攻魔法卡
			if Duel.IsExistingMatchingCard(s.cfilter,p,LOCATION_HAND,0,1,nil) then
				-- 选择要丢弃的卡
				local dg=Duel.SelectMatchingCard(p,s.cfilter,p,LOCATION_HAND,0,1,1,nil)
				if dg:GetCount()>0 then
					-- 洗切玩家手牌
					Duel.ShuffleHand(p)
					-- 将选中的卡送去墓地
					Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD,p)
				end
			else
				-- 获取玩家手牌组
				local sg=Duel.GetFieldGroup(p,LOCATION_HAND,0)
				-- 将玩家手牌全部送去墓地
				Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD,p)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择「旋风」卡加入手牌
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方查看选中的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 判断该卡是否因「旋风」效果被破坏
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:GetHandler():IsCode(5318639)
end
-- 判断该卡是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置盖放效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 处理盖放效果的执行逻辑
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否与连锁相关且未被王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将该卡盖放在魔法与陷阱区域
		Duel.SSet(tp,c)
	end
end
