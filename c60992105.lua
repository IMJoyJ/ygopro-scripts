--玄翼竜 ブラック・フェザー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，战斗或者卡的效果让自己受到伤害时才能发动。从自己卡组上面把最多5张卡送去墓地。这个效果送去墓地的卡之中有怪兽卡的场合，这张卡的攻击力上升400。
function c60992105.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，战斗或者卡的效果让自己受到伤害时才能发动。从自己卡组上面把最多5张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60992105,0))  --"卡组送去墓地"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCountLimit(1)
	e1:SetCondition(c60992105.condition)
	e1:SetTarget(c60992105.target)
	e1:SetOperation(c60992105.operation)
	c:RegisterEffect(e1)
end
-- 发动条件：检查受到伤害的玩家是否为自己
function c60992105.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 发动准备：检查是否能将卡组的卡送去墓地，并设置操作信息
function c60992105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否至少有1张卡可以送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	-- 设置操作信息：将卡组的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
-- 过滤条件：在墓地且是怪兽卡
function c60992105.filter(c)
	return c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER)
end
-- 效果处理：计算最多可以送去墓地的卡片数量（最多5张）
function c60992105.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己卡组的卡片数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>5 then ct=5 end
	local t={}
	for i=1,ct do t[i]=i end
	-- 提示玩家选择要送去墓地的卡片数量
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(60992105,1))  --"请选择要送去墓地的数量"
	-- 让玩家宣言要送去墓地的卡片数量
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 将宣言数量的卡片从卡组最上方送去墓地
	Duel.DiscardDeck(tp,ac,REASON_EFFECT)
	-- 获取实际送去墓地的卡片组
	local g=Duel.GetOperatedGroup()
	if g:IsExists(c60992105.filter,1,nil) and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
