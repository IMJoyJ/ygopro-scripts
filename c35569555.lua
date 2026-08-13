--凶導の聖告
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●从卡组把1只「教导」仪式怪兽或者1张「教导」仪式魔法卡加入手卡。对方场上有怪兽存在的场合，可以再从卡组把1张「教导」卡加入手卡。
-- ②：1回合1次，自己场上有「教导」仪式怪兽存在的场合才能发动。把自己或者对方的额外卡组确认，那之内的1只怪兽送去墓地。
local s,id,o=GetID()
-- 创建并注册此卡的两个效果：①发动时检索教导仪式卡的效果（1回合1次，受卡名限制）和②自己场上有教导仪式怪兽时从额外卡组送墓的效果（1回合1次）。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，以下效果可以适用。●从卡组把1只「教导」仪式怪兽或者1张「教导」仪式魔法卡加入手卡。对方场上有怪兽存在的场合，可以再从卡组把1张「教导」卡加入手卡。
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
-- 定义检索过滤条件：筛选卡组中持有「教导」字段、且（根据specify参数）是指定的教导仪式怪兽或教导仪式魔法卡，并且可以被加入手卡的卡。
function s.thfilter(c,specify)
	return c:IsSetCard(0x145) and (not specify or (c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER+TYPE_SPELL))) and c:IsAbleToHand()
end
-- 处理①的发动效果：先检索教导仪式怪兽/仪式魔法卡加入手卡；若对方场上有怪兽，还可再检索1张教导卡加入手卡，并向对方展示。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组中筛选出所有满足条件（specify=true，即教导仪式怪兽或教导仪式魔法卡）且可加入手卡的卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil,true)
	-- 若存在可检索的教导仪式卡，且玩家选择发动检索，则进入选择环节。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否从卡组把「教导」仪式卡加入手卡？"
		-- 给出选择提示：请选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡加入手卡；若实际加入成功且该卡现在位于手卡，才继续处理后续可能追加的检索。
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 and sg:GetFirst():IsLocation(LOCATION_HAND) then
			-- 向对方展示这张加入手卡的教导仪式卡。
			Duel.ConfirmCards(1-tp,sg)
			-- 在自己卡组中筛选出所有教导卡（specify=false，不限定仪式）且可加入手卡的卡，用于第二次追加检索。
			local g2=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
			-- 若存在可追加检索的教导卡、且对方场上有怪兽，同时玩家选择追加，则进行第二次检索。
			if #g2>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否再从卡组把「教导」卡加入手卡？"
				-- 给出选择提示：请选择要加入手牌的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				local sg2=g2:Select(tp,1,1,nil)
				-- 中断当前效果链，使第二次加入手卡的处理与第一次加入手卡的处理视为不同时处理，以避免错过时点。
				Duel.BreakEffect()
				-- 将第二次选中的教导卡加入手卡。
				Duel.SendtoHand(sg2,nil,REASON_EFFECT)
				-- 向对方展示第二次加入手卡的教导卡。
				Duel.ConfirmCards(1-tp,sg2)
			end
		end
	end
end
-- 定义己方场上存在的表侧表示的「教导」仪式怪兽的判定条件。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x145) and c:IsType(TYPE_RITUAL)
end
-- ②的发动条件函数：判断自己场上是否存在满足s.cfilter（表侧教导仪式怪兽）的怪兽。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1只表侧表示的教导仪式怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义额外卡组中的怪兽是否能被送去墓地的判定条件：自己的额外卡组怪兽需是怪兽且能被送去墓地；对方的额外卡组怪兽需由本玩家能够将其送去墓地。
function s.tgfilter0(c,tp)
	if c:IsControler(tp) then
		return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
	else
		-- 检查当前效果操作者是否可以将对方的这张额外卡组怪兽送去墓地（用于排除不能送墓的限制）。
		return Duel.IsPlayerCanSendtoGrave(tp,c)
	end
end
-- ②的发动目标设定：在发动时确认双方额外卡组中存在可以送去墓地的怪兽，并声明操作信息为从额外卡组将1只怪兽送去墓地。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查（chk==0时）：双方额外卡组合计是否存在至少1只可被送去墓地的怪兽，若否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter0,tp,LOCATION_EXTRA,LOCATION_EXTRA,1,nil,tp) end
	-- 设置操作信息：本次效果处理将把1只怪兽送去墓地，目标范围为双方额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_EXTRA)
end
-- 定义用于实际选择送墓的额外卡组怪兽的过滤条件：必须是怪兽且可以被送去墓地。
function s.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 处理②的发动效果：让玩家选择确认自己或对方的额外卡组，然后从该额外卡组中选择1只怪兽送去墓地；若选择对方额外卡组，则送墓后洗切对方额外卡组。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己的额外卡组中的所有卡片。
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	-- 获取对方的额外卡组中的所有卡片。
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
	-- 让玩家在“自己的额外卡组”和“对方的额外卡组”之间选择，并返回所选选项的序号。
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		g=g1
	elseif sel==1 then
		g=g2
		-- 向自己展示对方的额外卡组（公开确认）。
		Duel.ConfirmCards(tp,g,true)
	end
	-- 给出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:FilterSelect(tp,s.tgfilter,1,1,nil)
	if #sg>0 then
		-- 中断当前效果处理，使送墓动作在独立时点处理，避免时点被占用。
		Duel.BreakEffect()
		-- 将选中的1只怪兽从额外卡组送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	if sel==1 then
		-- 若选择的是对方的额外卡组，则送墓后洗切对方的额外卡组。
		Duel.ShuffleExtra(1-tp)
	end
end
