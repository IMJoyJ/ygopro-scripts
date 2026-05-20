--勇炎星－エンショウ
-- 效果：
-- 1回合1次，这张卡战斗破坏对方怪兽送去墓地时，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。此外，1回合1次，把自己场上表侧表示存在的1张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。选择场上1张魔法·陷阱卡破坏。
function c70355994.initial_effect(c)
	-- 1回合1次，这张卡战斗破坏对方怪兽送去墓地时，可以从卡组选1张名字带有「炎舞」的魔法卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70355994,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCountLimit(1)
	e1:SetCondition(c70355994.setcon)
	e1:SetTarget(c70355994.settg)
	e1:SetOperation(c70355994.setop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，把自己场上表侧表示存在的1张名字带有「炎舞」的魔法·陷阱卡送去墓地才能发动。选择场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70355994,1))  --"魔陷破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c70355994.descost)
	e2:SetTarget(c70355994.destg)
	e2:SetOperation(c70355994.desop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否因战斗将对方怪兽破坏并送去墓地，作为效果发动的条件
function c70355994.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsReason(REASON_BATTLE)
end
-- 过滤卡组中属于「炎舞」且可以盖放的魔法卡
function c70355994.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 盖放效果的靶向/发动准备阶段，检查卡组中是否存在可盖放的「炎舞」魔法卡
function c70355994.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「炎舞」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c70355994.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 盖放效果的处理，从卡组选择1张「炎舞」魔法卡在自己场上盖放
function c70355994.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足条件的「炎舞」魔法卡
	local g=Duel.SelectMatchingCard(tp,c70355994.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤自己场上表侧表示、能作为代价送去墓地的「炎舞」魔陷，且场上存在其他可作为破坏对象的魔陷
function c70355994.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在除该卡以外的魔法·陷阱卡作为破坏对象
		and Duel.IsExistingTarget(c70355994.filter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 破坏效果的发动代价处理，需将场上1张表侧表示的「炎舞」魔陷送去墓地（兼容「炎星仙-鹫真人」的免代价效果）
function c70355994.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可作为代价送去墓地的「炎舞」魔陷
	if chk==0 then return Duel.IsExistingMatchingCard(c70355994.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or (Duel.IsPlayerAffectedByEffect(tp,46241344) and Duel.IsExistingTarget(c70355994.filter2,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)) end
	-- 检查是否可以通过正常将场上的「炎舞」魔陷送去墓地来支付代价
	if Duel.IsExistingMatchingCard(c70355994.filter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家选择1张自己场上表侧表示的「炎舞」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,c70355994.filter1,tp,LOCATION_ONFIELD,0,1,1,nil)
		-- 将选择的卡作为发动代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	end
end
-- 过滤场上的魔法·陷阱卡
function c70355994.filter2(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的靶向/发动准备阶段，选择场上1张魔法·陷阱卡作为对象，并设置破坏的操作信息
function c70355994.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c70355994.filter2(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张魔法·陷阱卡作为效果对象
	local g2=Duel.SelectTarget(tp,c70355994.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏1张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,1,0,0)
end
-- 破坏效果的处理，将选择的对象卡破坏
function c70355994.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
