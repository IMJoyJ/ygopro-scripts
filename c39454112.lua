--出たら目
-- 效果：
-- ①：只要这张卡在魔法与陷阱区域存在，自己或者对方掷骰子的场合，可以把那之内1个数目作为以下数目适用。
-- ●1·3·5出现的场合：当作6使用。
-- ●2·4·6出现的场合：当作1使用。
function c39454112.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己或者对方掷骰子的场合，可以把那之内1个数目作为以下数目适用。●1·3·5出现的场合：当作6使用。●2·4·6出现的场合：当作1使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE_NEGATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c39454112.diceop)
	c:RegisterEffect(e2)
end
-- 执行掷骰子被重掷时的操作：询问控制者是否适用本卡效果；若适用，展示卡片动画，获取当前骰子结果，若本次有多个骰子则先选择要改变第几次骰子，然后将所选骰子的1/3/5改为6、2/4/6改为1，最后将修改后的结果写回，覆盖原骰子结果。
function c39454112.diceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁序号，以便后续读取该连锁的详细信息。
	local cc=Duel.GetCurrentChain()
	-- 获取当前连锁的唯一标识（Chain ID），用于识别本次掷骰事件所属的连锁。
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	-- 询问这张卡的控制者是否要适用「胡出乱目」的效果，选择“是”则进入后续处理。
	if Duel.SelectYesNo(tp,aux.Stringid(39454112,0)) then  --"是否要使用「胡出乱目」的效果？"
		-- 向双方展示「胡出乱目」的卡片动画，提示正在适用该卡的效果。
		Duel.Hint(HINT_CARD,0,39454112)
		-- 获取当前掷骰子的所有结果，并存入数组dc中，便于按序号修改指定的骰子点数。
		local dc={Duel.GetDiceResult()}
		local ac=1
		local ct=(ev&0xff)+(ev>>16&0xff)
		if ct>1 then
			-- 本次掷骰子数量超过1个时，显示提示消息，让玩家选择要改变第几次骰子的结果。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39454112,1))  --"要改变第几次骰子的结果？"
			-- 让玩家从1到本次掷骰子个数中宣言一个数字，选定要修改的骰子序号；idx为所选数字在选项中的位置，用于确定数组下标。
			local val,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
			ac=idx+1
		end
		if dc[ac]==1 or dc[ac]==3 or dc[ac]==5 then dc[ac]=6
		else dc[ac]=1 end
		-- 将修改后的骰子结果数组写回，强制本次掷骰结果变为修改后的点数，从而实现将特定点数“当作6/1使用”。
		Duel.SetDiceResult(table.unpack(dc))
	end
end
