--ブリザード・ウォリアー
-- 效果：
-- ①：这张卡战斗破坏对方怪兽的场合发动。把对方卡组最上面的卡确认，回到卡组最上面或最下面。
function c96565487.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽的场合发动。把对方卡组最上面的卡确认，回到卡组最上面或最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96565487,0))  --"确认卡组"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c96565487.condition)
	e1:SetOperation(c96565487.operation)
	c:RegisterEffect(e1)
end
-- 判断此卡是否与战斗相关，且战斗破坏的卡是否为怪兽
function c96565487.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 执行确认对方卡组最上方卡片并选择放回卡组最上方或最下方的操作
function c96565487.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(1-tp,1)
	if g:GetCount()==0 then return end
	-- 给自身玩家确认获取到的卡片
	Duel.ConfirmCards(tp,g)
	local tc=g:GetFirst()
	-- 让自身玩家选择将卡片放回卡组最上面还是最下面
	local opt=Duel.SelectOption(tp,aux.Stringid(96565487,1),aux.Stringid(96565487,2))  --"返回卡组最上面/返回卡组最下面"
	if opt==1 then
		-- 若玩家选择放回最下面，则将该卡移动到卡组最下方
		Duel.MoveSequence(tc,opt)
	end
end
