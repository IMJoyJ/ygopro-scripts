--凶導の聖告
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●从卡组把1只「教导」仪式怪兽或者1张「教导」仪式魔法卡加入手卡。对方场上有怪兽存在的场合，可以再从卡组把1张「教导」卡加入手卡。
-- ②：1回合1次，自己场上有「教导」仪式怪兽存在的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡牌效果，设置主效果为发动时可以检索仪式怪兽或仪式魔法卡，设置副效果为可以确认额外卡组并送去墓地
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。●从卡组把1只「教导」仪式怪兽或者1张「教导」仪式魔法卡加入手卡。对方场上有怪兽存在的场合，可以再从卡组把1张「教导」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上有「教导」仪式怪兽存在的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
-- 检索过滤函数，用于筛选「教导」卡组中的仪式怪兽或仪式魔法卡
function s.thfilter(c,specify)
	return c:IsSetCard(0x145) and (not specify or (c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER+TYPE_SPELL))) and c:IsAbleToHand()
end
-- 发动处理函数，执行检索和加入手牌的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的「教导」卡组卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,true)
	-- 判断是否选择检索卡片
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把「教导」仪式卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手牌并确认
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
			-- 确认对手手牌
			Duel.ConfirmCards(1-tp,sg)
			-- 获取满足条件的「教导」卡组卡片（用于第二次检索）
			local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			-- 判断是否选择第二次检索
			if #g2>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否再从卡组把「教导」卡加入手卡？"
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg2=g2:Select(tp,1,1,nil)
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将选中的卡加入手牌
				Duel.SendtoHand(sg2,nil,REASON_EFFECT)
				-- 确认对手手牌
				Duel.ConfirmCards(1-tp,sg2)
			end
		end
	end
end
-- 判断场上的「教导」仪式怪兽是否存在
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145) and c:IsType(TYPE_RITUAL)
end
-- 判断是否满足发动条件
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上的「教导」仪式怪兽是否存在
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断额外卡组中的卡片是否可以送去墓地
function s.tgfilter0(c,tp)
	if c:IsControler(tp) then
		return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
	else
		-- 判断玩家是否可以将卡片送去墓地
		return Duel.IsPlayerCanSendtoGrave(tp,c)
	end
end
-- 设置发动时的处理信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有满足条件的额外卡组卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter0,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil,tp) end
	-- 设置操作信息，用于发动效果检测
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- 过滤函数，用于筛选额外卡组中的怪兽
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 发动效果处理函数，执行确认额外卡组并送去墓地的效果
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己的额外卡组中的卡片
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 获取对方的额外卡组中的卡片
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g1==0 and #g2==0 then return end
	local g
	local off=1
	local ops={}
	local opval={}
	if #g1>0 then
		ops[off]=aux.Stringid(id,3)  --"把自己的额外卡组确认"
		opval[off]=0
		off=off+1
	end
	if #g2>0 then
		ops[off]=aux.Stringid(id,4)  --"把对方的额外卡组确认"
		opval[off]=1
		off=off+1
	end
	-- 选择确认自己的额外卡组或对方的额外卡组
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		g=g1
	elseif sel==1 then
		g=g2
		-- 确认玩家选择的额外卡组
		Duel.ConfirmCards(tp,g,true)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:FilterSelect(tp,s.tgfilter,1,1,nil)
	if #sg>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	if sel==1 then
		-- 洗切对方的额外卡组
		Duel.ShuffleExtra(1-tp)
	end
end
