--No.67 パラダイスマッシャー
-- 效果：
-- 5星怪兽×2只以上
-- ①：1回合1次，自己主要阶段1把这张卡2个超量素材取除才能发动。双方各掷2次骰子。出现的数目合计大的玩家直到下个回合的结束时不能把怪兽的效果发动，不能攻击宣言。
-- ②：持有超量素材的这张卡在怪兽区域存在，自己或者对方掷骰子的场合，1回合只有1次可以把那之内1个数目作为7适用。
function c35772782.initial_effect(c)
	-- 为这张卡添加超量召唤手续：等级5的怪兽2只以上（最多99只）叠放作超量召唤，对应“5星怪兽×2只以上”的召唤条件。
	aux.AddXyzProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 对应①效果：1回合1次，自己主要阶段1把这张卡2个超量素材取除才能发动。双方各掷2次骰子。出现的数目合计大的玩家直到下个回合的结束时不能把怪兽的效果发动，不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35772782,0))
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c35772782.dccon)
	e1:SetCost(c35772782.dccost)
	e1:SetTarget(c35772782.dctg)
	e1:SetOperation(c35772782.dcop)
	c:RegisterEffect(e1)
	-- 对应②效果：持有超量素材的这张卡在怪兽区域存在，自己或者对方掷骰子的场合，1回合只有1次可以把那之内1个数目作为7适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE_NEGATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c35772782.dicecon)
	e2:SetOperation(c35772782.diceop)
	c:RegisterEffect(e2)
end
-- 设定这张卡的XYZ编号为67，即“No.67”的编号标记。
aux.xyz_number[35772782]=67
-- ①效果的发动条件函数：判断是否满足发动阶段条件。
function c35772782.dccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段1，只有主要阶段1才能发动①效果。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- ①效果的代价函数：发动时去除这张卡的2个超量素材。
function c35772782.dccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ①效果的目标处理函数：效果无选取对象，登记骰子效果信息。
function c35772782.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：类别为骰子，双方各掷2次骰子（PLAYER_ALL表示双方，参数2表示次数）。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,2)
end
-- ①效果处理：双方各掷2次骰子，比较合计值，对点数合计较小的一方赋予直到下个回合结束不能发动怪兽效果、不能攻击宣言的制约。
function c35772782.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让双方各投掷2次骰子，返回4个点数（自己2个对方2个）。
	local d1,d2,d3,d4=Duel.TossDice(tp,2,2)
	if d1+d2>d3+d4 then
		-- 对应效果原文中的“不能把怪兽的效果发动”部分。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c35772782.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将“不能发动怪兽效果”的限制效果注册并适用于负方玩家。
		Duel.RegisterEffect(e1,tp)
		-- 对应效果原文中的“不能攻击宣言”部分。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将“不能攻击宣言”的限制效果注册并适用于负方玩家。
		Duel.RegisterEffect(e2,tp)
	elseif d1+d2<d3+d4 then
		-- 对应效果原文中的“不能把怪兽的效果发动”部分。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c35772782.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将“不能发动怪兽效果”的限制效果注册并适用于负方玩家。
		Duel.RegisterEffect(e1,tp)
		-- 对应效果原文中的“不能攻击宣言”部分。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetTargetRange(0,1)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将“不能攻击宣言”的限制效果注册并适用于负方玩家。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 过滤函数：判断被限制的效果种类为怪兽效果。
function c35772782.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ②效果的发动条件：这张卡有超量素材，且本回合尚未使用过②效果。
function c35772782.dicecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and c:GetFlagEffect(35772782)==0
end
-- ②效果处理：询问是否修改骰子，选择后将其中一个骰子结果作为7适用，并记录本回合已使用标记。
function c35772782.diceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号。
	local cc=Duel.GetCurrentChain()
	-- 获取当前连锁的唯一标识（CHAININFO_CHAIN_ID），用于关联本次掷骰事件。
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	-- 询问玩家是否要发动②效果修改骰子结果。
	if Duel.SelectYesNo(tp,aux.Stringid(35772782,1)) then  --"是否修改骰子结果？"
		-- 展示这张卡的卡片动画/提示，表示正在应用②效果。
		Duel.Hint(HINT_CARD,0,35772782)
		e:GetHandler():RegisterFlagEffect(35772782,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 读取当前掷骰子的全部点数，存入表dc。
		local dc={Duel.GetDiceResult()}
		local ac=1
		local ct=(ev&0xff)+(ev>>16&0xff)
		if ct>1 then
			-- 提示玩家选择需要修改为7的骰子序号。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(35772782,2))  --"请选择要修改的骰子序号"
			-- 让玩家宣言一个数字（对应可选序号），返回选中的值及在选项中的位置。
			local val,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
			ac=idx+1
		end
		dc[ac]=7
		-- 将修改后的骰子点数写回，使骰子结果生效。
		Duel.SetDiceResult(table.unpack(dc))
	end
end
