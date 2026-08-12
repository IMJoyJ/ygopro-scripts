--武神帝－カグツチ
-- 效果：
-- 兽战士族4星怪兽×2
-- 这张卡超量召唤成功时，从自己卡组上面把5张卡送去墓地。这张卡的攻击力上升这个效果送去墓地的名字带有「武神」的卡数量×100的数值。此外，自己场上的名字带有「武神」的兽战士族怪兽被战斗或者卡的效果破坏的场合，可以作为那1只破坏的怪兽的代替而把这张卡1个超量素材取除。「武神帝-迦具土」在自己场上只能有1只表侧表示存在。
function c1855932.initial_effect(c)
	c:SetUniqueOnField(1,0,1855932)
	-- 添加超量召唤手续，使用满足兽战士族条件的4星怪兽作为素材进行2次叠放
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEASTWARRIOR),4,2)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，从自己卡组上面把5张卡送去墓地。这张卡的攻击力上升这个效果送去墓地的名字带有「武神」的卡数量×100的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1855932,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c1855932.discon)
	e1:SetTarget(c1855932.distg)
	e1:SetOperation(c1855932.disop)
	c:RegisterEffect(e1)
	-- 自己场上的名字带有「武神」的兽战士族怪兽被战斗或者卡的效果破坏的场合，可以作为那1只破坏的怪兽的代替而把这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c1855932.reptg)
	e2:SetValue(c1855932.repval)
	c:RegisterEffect(e2)
end
-- 效果适用的条件：此卡为超量召唤成功
function c1855932.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 设置连锁处理信息：将从卡组送去墓地的卡作为处理对象，数量为5
function c1855932.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理信息：将从卡组送去墓地的卡作为处理对象，数量为5
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,5)
end
-- 执行效果处理：从卡组上面送去墓地5张卡，并根据送去墓地的「武神」卡数量提升攻击力
function c1855932.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 从玩家卡组最上方送去墓地5张卡
	Duel.DiscardDeck(tp,5,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 统计实际送去墓地的「武神」卡数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsSetCard,nil,0x88)
		if ct>0 then
			-- 为该卡添加攻击力提升效果，提升值为「武神」卡数量乘以100
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(ct*100)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 筛选符合条件的场上的「武神」兽战士族怪兽（用于代替破坏）
function c1855932.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 处理代替破坏的效果：检查是否可以移除1个超量素材，并选择要代替破坏的怪兽
function c1855932.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c1855932.repfilter,1,nil,tp) end
	-- 检查是否可以移除1个超量素材并让玩家选择是否发动此效果
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		local g=eg:Filter(c1855932.repfilter,nil,tp)
		if g:GetCount()==1 then
			e:SetLabelObject(g:GetFirst())
		else
			-- 提示玩家选择要代替破坏的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
			local cg=g:Select(tp,1,1,nil)
			e:SetLabelObject(cg:GetFirst())
		end
		return true
	else return false end
end
-- 返回效果值：判断是否为被选中的要代替破坏的怪兽
function c1855932.repval(e,c)
	return c==e:GetLabelObject()
end
