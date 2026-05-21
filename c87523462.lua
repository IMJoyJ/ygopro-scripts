--有翼賢者ファルコス
-- 效果：
-- 被这张卡战斗破坏并将送去墓地的对方表侧攻击表示的怪兽，可以把其放回对方卡组最上面。
function c87523462.initial_effect(c)
	-- 被这张卡战斗破坏并将送去墓地的对方表侧攻击表示的怪兽，可以把其放回对方卡组最上面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87523462,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCondition(c87523462.tdcon)
	e1:SetTarget(c87523462.tdtg)
	e1:SetOperation(c87523462.tdop)
	c:RegisterEffect(e1)
end
-- 确认自身在战斗中且表侧表示，并验证被战斗破坏的怪兽是否满足“送去墓地的对方表侧攻击表示怪兽”的条件
function c87523462.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not c:IsRelateToBattle() or c:IsFacedown() then return false end
	return bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp) and bc:GetBattlePosition()==POS_FACEUP_ATTACK
end
-- 效果发动的目标选择与确认，检查被破坏的怪兽是否能送回卡组，并将其设为效果处理的对象
function c87523462.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsAbleToDeck() end
	-- 将战斗破坏的怪兽设置为当前效果的处理对象
	Duel.SetTargetCard(bc)
	-- 设置效果处理信息，声明该效果的操作分类为“送回卡组”，操作对象为该怪兽，数量为1
	Duel.SetOperationInfo(0,CATEGORY_TODECK,bc,1,0,0)
end
-- 效果处理，获取目标怪兽，若其仍与效果关联，则将其送回持有者卡组最上面
function c87523462.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果设定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 通过效果将目标怪兽送回其持有者的卡组最上面
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
