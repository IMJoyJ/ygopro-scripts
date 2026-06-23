--No.67 パラダイスマッシャー
-- 效果：
-- 5星怪兽×2只以上
-- ①：1回合1次，自己主要阶段1把这张卡2个超量素材取除才能发动。双方各掷2次骰子。出现的数目合计大的玩家直到下个回合的结束时不能把怪兽的效果发动，不能攻击宣言。
-- ②：持有超量素材的这张卡在怪兽区域存在，自己或者对方掷骰子的场合，1回合只有1次可以把那之内1个数目作为7适用。
function c35772782.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为5的怪兽2只以上作为素材进行召唤
	aux.AddXyzProcedure(c,nil,5,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段1把这张卡2个超量素材取除才能发动。双方各掷2次骰子。出现的数目合计大的玩家直到下个回合的结束时不能把怪兽的效果发动，不能攻击宣言。
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
	-- ②：持有超量素材的这张卡在怪兽区域存在，自己或者对方掷骰子的场合，1回合只有1次可以把那之内1个数目作为7适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE_NEGATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c35772782.dicecon)
	e2:SetOperation(c35772782.diceop)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为67
aux.xyz_number[35772782]=67
-- 效果发动条件：当前阶段为自己的主要阶段1
function c35772782.dccon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为自己的主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 效果发动费用：从自己场上取除2个超量素材
function c35772782.dccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果发动时点：设置连锁操作信息，表示将要进行骰子投掷
function c35772782.dctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将要进行骰子投掷
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,2)
end
-- 效果处理：投掷骰子并根据结果施加限制效果
function c35772782.dcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 投掷双方骰子，各投2次
	local d1,d2,d3,d4=Duel.TossDice(tp,2,2)
	if d1+d2>d3+d4 then
		-- 创建一个禁止对方发动怪兽效果的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c35772782.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 创建一个禁止对方攻击宣言的永续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将效果注册到场上
		Duel.RegisterEffect(e2,tp)
	elseif d1+d2<d3+d4 then
		-- 创建一个禁止对方发动怪兽效果的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(0,1)
		e1:SetValue(c35772782.actlimit)
		e1:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将效果注册到场上
		Duel.RegisterEffect(e1,tp)
		-- 创建一个禁止对方攻击宣言的永续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e2:SetTargetRange(0,1)
		e2:SetReset(RESET_PHASE+PHASE_END,2)
		-- 将效果注册到场上
		Duel.RegisterEffect(e2,tp)
	end
end
-- 限制效果：只能对怪兽卡发动
function c35772782.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 效果发动条件：该卡拥有超量素材且未使用过此效果
function c35772782.dicecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and c:GetFlagEffect(35772782)==0
end
-- 效果处理：选择是否修改骰子结果
function c35772782.diceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	-- 询问玩家是否修改骰子结果
	if Duel.SelectYesNo(tp,aux.Stringid(35772782,1)) then  --"是否修改骰子结果？"
		-- 提示玩家该卡被发动
		Duel.Hint(HINT_CARD,0,35772782)
		e:GetHandler():RegisterFlagEffect(35772782,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 获取当前骰子结果
		local dc={Duel.GetDiceResult()}
		local ac=1
		local ct=(ev&0xff)+(ev>>16&0xff)
		if ct>1 then
			-- 提示玩家选择要修改的骰子序号
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(35772782,2))  --"请选择要修改的骰子序号"
			-- 让玩家选择要修改的骰子序号
			local val,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
			ac=idx+1
		end
		dc[ac]=7
		-- 设置骰子结果为修改后的值
		Duel.SetDiceResult(table.unpack(dc))
	end
end
