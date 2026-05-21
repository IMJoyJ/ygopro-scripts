--霞の谷の風使い
-- 效果：
-- 双方手卡有5张以上的场合才能发动。双方玩家直到手卡变成4张把手卡送去墓地。这个效果1回合只能使用1次。
function c92933195.initial_effect(c)
	-- 双方手卡有5张以上的场合才能发动。双方玩家直到手卡变成4张把手卡送去墓地。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92933195,0))  --"手牌调整"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c92933195.handcon)
	e1:SetOperation(c92933195.handop)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：判断双方手卡数量是否都满足5张以上
function c92933195.handcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己和对方的手卡数量是否都大于或等于5张
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>=5 and Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>=5
end
-- 定义效果处理函数：双方玩家将手卡送去墓地直到手卡变成4张
function c92933195.handop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 获取当前回合玩家（自己）的手卡数量
	local ht1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if ht1>=5 then
		-- 提示自己选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家自己选择超出4张部分数量的手卡（即当前手卡数减去4张）
		local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,ht1-4,ht1-4,nil)
		g:Merge(sg)
	end
	-- 获取对方玩家的手卡数量
	local ht2=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
	if ht2>=5 then
		-- 提示对方选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让对方玩家选择超出4张部分数量的手卡（即当前手卡数减去4张）
		local sg=Duel.SelectMatchingCard(1-tp,aux.TRUE,1-tp,LOCATION_HAND,0,ht2-4,ht2-4,nil)
		g:Merge(sg)
	end
	-- 将双方选中的手卡因效果送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
