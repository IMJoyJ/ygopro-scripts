--バーニング・スカルヘッド
-- 效果：
-- 这张卡从手卡特殊召唤成功时，给与对方基本分1000分伤害。此外，可以把自己场上表侧表示存在的这张卡从游戏中除外，从游戏中除外的1只「骷髅炎鬼」回到墓地。
function c26293219.initial_effect(c)
	-- 这张卡从手卡特殊召唤成功时，给与对方基本分1000分伤害。此外，可以把自己场上表侧表示存在的这张卡从游戏中除外，从游戏中除外的1只「骷髅炎鬼」回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26293219,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c26293219.damcon)
	e1:SetTarget(c26293219.damtg)
	e1:SetOperation(c26293219.damop)
	c:RegisterEffect(e1)
	-- 这张卡从手卡特殊召唤成功时，给与对方基本分1000分伤害。此外，可以把自己场上表侧表示存在的这张卡从游戏中除外，从游戏中除外的1只「骷髅炎鬼」回到墓地。
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
-- 判断此卡是否由手牌区域特殊召唤成功
function c26293219.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 设置连锁处理时的目标玩家为对方玩家，目标参数为1000点伤害
function c26293219.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理时的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理时的目标参数为1000点伤害
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为造成1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 处理连锁效果，对对方玩家造成1000点伤害
function c26293219.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定点数的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 支付效果代价，将此卡从场上除外作为代价
function c26293219.rtgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将此卡从场上除外作为代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 定义过滤函数，用于筛选场上表侧表示的「骷髅炎鬼」卡片
function c26293219.filter(c)
	return c:IsFaceup() and c:IsCode(99899504)
end
-- 设置选择目标效果，从除外区选择一只「骷髅炎鬼」回到墓地
function c26293219.rtgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and c26293219.filter(chkc) end
	-- 判断是否在除外区存在符合条件的「骷髅炎鬼」卡片
	if chk==0 then return Duel.IsExistingTarget(c26293219.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一只符合条件的「骷髅炎鬼」卡片作为目标
	local g=Duel.SelectTarget(tp,c26293219.filter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置连锁操作信息为将目标卡片送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 处理连锁效果，将目标卡片送入墓地
function c26293219.rtgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送入墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
