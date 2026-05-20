--エクシーズ・アヴェンジャー
-- 效果：
-- 这张卡不受超量怪兽的效果影响。此外，这张卡被和超量怪兽的战斗破坏送去墓地时，把让这张卡破坏的超量怪兽的阶级的以下效果发动。
-- ●3阶以下：对方选额外卡组1张卡送去墓地。
-- ●4阶：自己选对方的额外卡组1张卡送去墓地。
-- ●5阶以上：对方选那只超量怪兽的阶级数量的额外卡组的卡送去墓地。
function c86062400.initial_effect(c)
	-- 这张卡不受超量怪兽的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c86062400.efilter)
	c:RegisterEffect(e1)
	-- 此外，这张卡被和超量怪兽的战斗破坏送去墓地时，把让这张卡破坏的超量怪兽的阶级的以下效果发动。●3阶以下：对方选额外卡组1张卡送去墓地。●4阶：自己选对方的额外卡组1张卡送去墓地。●5阶以上：对方选那只超量怪兽的阶级数量的额外卡组的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86062400,0))  --"额外送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c86062400.tgcon)
	e2:SetTarget(c86062400.tgtg)
	e2:SetOperation(c86062400.tgop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断效果源是否为超量怪兽
function c86062400.efilter(e,te)
	return te:IsActiveType(TYPE_XYZ)
end
-- 发动条件：此卡因战斗破坏送去墓地，且战斗对象是表侧表示的超量怪兽
function c86062400.tgcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and bc:IsFaceup() and bc:IsRelateToBattle() and bc:IsType(TYPE_XYZ)
end
-- 效果选择与声明：根据战斗对象的阶级，设置送去墓地的操作信息
function c86062400.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local rk=e:GetHandler():GetBattleTarget():GetRank()
	if rk<5 then
		-- 设置操作信息：对方额外卡组有1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_EXTRA)
	else
		-- 设置操作信息：对方额外卡组有等同于该超量怪兽阶级数量的卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,rk,1-tp,LOCATION_EXTRA)
	end
end
-- 效果处理：根据战斗对象的阶级，由对应玩家选择对方额外卡组的卡送去墓地
function c86062400.tgop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsFaceup() and bc:IsRelateToBattle() then
		local rk=bc:GetRank()
		local g=nil
		-- 获取对方额外卡组中可以送去墓地的卡片组
		local tg=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
		if tg:GetCount()==0 then return end
		if rk<4 then
			-- 给对方玩家发送选择送去墓地的卡的提示信息
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			g=tg:Select(1-tp,1,1,nil)
		elseif rk==4 then
			-- 让自身玩家确认对方的额外卡组
			Duel.ConfirmCards(tp,tg)
			-- 给自身玩家发送选择送去墓地的卡的提示信息
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			g=tg:Select(tp,1,1,nil)
		else
			-- 给对方玩家发送选择送去墓地的卡的提示信息
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			g=tg:Select(1-tp,rk,rk,nil)
		end
		if g:GetCount()>0 then
			-- 将选中的卡因效果送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
