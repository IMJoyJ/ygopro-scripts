--増幅する悪意
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方回合的准备阶段时自己墓地存在的「增幅的恶意」的数量的对方卡组最上面的卡送去墓地。
function c14255590.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，对方回合的准备阶段时自己墓地存在的「增幅的恶意」的数量的对方卡组最上面的卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14255590,0))  --"卡组送墓"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c14255590.discon)
	e1:SetTarget(c14255590.distg)
	e1:SetOperation(c14255590.disop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：判断是否满足对方回合的准备阶段这一发动时机，即效果控制者不是当前回合玩家时条件成立。
function c14255590.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回效果控制者tp不是当前回合玩家（即当前为对方回合），从而只在对方回合准备阶段满足条件。
	return tp~=Duel.GetTurnPlayer()
end
-- 发动时的目标/操作设定函数：在发动时进行合法性检查（chk==0直接通过），并登记效果操作信息；该效果为不取对象效果。
function c14255590.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定本效果的操作信息：效果分类为卡组送墓，不取对象，不锁定具体卡片，预计送墓数量为0（实际数量处理时确定），涉及玩家为tp，目标位置参数为3（表示卡组）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 效果处理函数：确认效果持有者仍在场上且效果有效（未转移控制权、未离场、非里侧），然后统计自己墓地中「增幅的恶意」的数量，并按该数量将对方卡组最上方卡送去墓地。
function c14255590.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 统计自己墓地中卡名「增幅的恶意」（卡号14255590）的卡的数量，作为从对方卡组送墓的卡片张数。
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,14255590)
	if ct>0 then
		-- 将对方玩家（1-tp）卡组最上方ct张卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
