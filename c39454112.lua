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
	-- 效果原文内容：只要这张卡在魔法与陷阱区域存在，自己或者对方掷骰子的场合，可以把那之内1个数目作为以下数目适用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_TOSS_DICE_NEGATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c39454112.diceop)
	c:RegisterEffect(e2)
end
-- 效果作用：处理掷骰子时的连锁效果
function c39454112.diceop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	-- 效果作用：获取当前连锁的唯一标识
	local cid=Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)
	-- 效果作用：询问玩家是否使用「胡出乱目」的效果
	if Duel.SelectYesNo(tp,aux.Stringid(39454112,0)) then  --"是否要使用「胡出乱目」的效果？"
		-- 效果作用：向玩家显示「胡出乱目」发动的动画提示
		Duel.Hint(HINT_CARD,0,39454112)
		-- 效果作用：获取当前掷骰子的结果
		local dc={Duel.GetDiceResult()}
		local ac=1
		local ct=(ev&0xff)+(ev>>16&0xff)
		if ct>1 then
			-- 效果作用：提示玩家选择要改变第几次骰子的结果
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39454112,1))  --"要改变第几次骰子的结果？"
			-- 效果作用：让玩家宣言要改变的骰子次数
			local val,idx=Duel.AnnounceNumber(tp,table.unpack(aux.idx_table,1,ct))
			ac=idx+1
		end
		if dc[ac]==1 or dc[ac]==3 or dc[ac]==5 then dc[ac]=6
		else dc[ac]=1 end
		-- 效果作用：设置修改后的骰子结果
		Duel.SetDiceResult(table.unpack(dc))
	end
end
