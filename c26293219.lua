--バーニング・スカルヘッド
-- 效果：
-- 这张卡从手卡特殊召唤成功时，给与对方基本分1000分伤害。此外，可以把自己场上表侧表示存在的这张卡从游戏中除外，从游戏中除外的1只「骷髅炎鬼」回到墓地。
function c26293219.initial_effect(c)
	-- 这张卡从手卡特殊召唤成功时，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26293219,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c26293219.damcon)
	e1:SetTarget(c26293219.damtg)
	e1:SetOperation(c26293219.damop)
	c:RegisterEffect(e1)
	-- 此外，可以把自己场上表侧表示存在的这张卡从游戏中除外，从游戏中除外的1只「骷髅炎鬼」回到墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26293219,1))  --"返回墓地"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c26293219.rtgcost)
	e2:SetTarget(c26293219.rtgtg)
	e2:SetOperation(c26293219.rtgop)
	c:RegisterEffect(e2)
end
-- 判定效果发动条件：该卡从手卡特殊召唤成功时才满足发动条件。
function c26293219.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 伤害效果的发动处理：无条件可发动，记录对方玩家为伤害对象、伤害值为1000，并设置伤害操作信息。
function c26293219.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设为对方玩家（1-tp），作为伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果参数设为1000，即给予对方的伤害数值。
	Duel.SetTargetParam(1000)
	-- 设置连锁的操作信息：效果分类为伤害，对象玩家为对方，伤害数值为1000，供效果发动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 伤害效果的实际处理：读取之前记录的对象玩家和伤害数值，给对方造成1000点效果伤害。
function c26293219.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和对象参数，分别赋给 p 和 d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给玩家 p 造成 d 点伤害，伤害原因为效果（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 起动效果的代价处理：检查自身能否作为代价除外；能则支付，将自身表侧表示除外作为发动代价。
function c26293219.rtgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将效果持有者（这张卡）表侧表示从游戏中除外，作为发动代价（REASON_COST）。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 对象筛选条件：选择除外区表侧表示且卡名为「骷髅炎鬼」（卡号99899504）的卡。
function c26293219.filter(c)
	return c:IsFaceup() and c:IsCode(99899504)
end
-- 取对象目标处理：从除外区选择1只符合条件的「骷髅炎鬼」作为效果对象，并设置送去墓地的操作信息。
function c26293219.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c26293219.filter(chkc) end
	-- 发动合法性检查：确认除外区是否存在至少1只符合条件的「骷髅炎鬼」可供选择。
	if chk==0 then return Duel.IsExistingTarget(c26293219.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 向操作玩家显示选择提示信息，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让操作玩家从除外区选择1只符合条件的「骷髅炎鬼」，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c26293219.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置连锁的操作信息：效果分类为送去墓地，对象为所选的「骷髅炎鬼」，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理时，取得对象卡；若对象仍与效果关联，则将其从除外区送去墓地，实现「骷髅炎鬼」回到墓地。
function c26293219.rtgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁所选择的第一张对象卡（即目标「骷髅炎鬼」）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去墓地，原因标记为效果与回归墓地（REASON_EFFECT+REASON_RETURN）。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
