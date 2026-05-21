--ペア・ルック
-- 效果：
-- ①：双方卡组最上面的卡给双方确认，那些卡是相同种类（怪兽·魔法·陷阱）的场合，双方把那些卡加入手卡。不是的场合，双方把那些卡除外。
function c94446564.initial_effect(c)
	-- ①：双方卡组最上面的卡给双方确认，那些卡是相同种类（怪兽·魔法·陷阱）的场合，双方把那些卡加入手卡。不是的场合，双方把那些卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c94446564.target)
	e1:SetOperation(c94446564.activate)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理可行性检查（双方卡组最上方都有卡，且都能加入手卡或除外）
function c94446564.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组最上方的一张卡
		local g1=Duel.GetDecktopGroup(tp,1)
		local tc1=g1:GetFirst()
		-- 获取对方卡组最上方的一张卡
		local g2=Duel.GetDecktopGroup(1-tp,1)
		local tc2=g2:GetFirst()
		return tc1 and tc2 and tc1:IsAbleToRemove(tp) and tc2:IsAbleToRemove(1-tp) and tc1:IsAbleToHand() and tc2:IsAbleToHand()
	end
end
-- 效果处理：确认双方卡组最上方的卡，相同种类则加入手卡，不同种类则除外
function c94446564.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若任意一方卡组没有卡，则不处理效果
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 or Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)==0 then return end
	-- 给双方确认自己卡组最上方的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 给双方确认对方卡组最上方的一张卡
	Duel.ConfirmDecktop(1-tp,1)
	-- 获取自己卡组最上方的一张卡
	local g1=Duel.GetDecktopGroup(tp,1)
	local tc1=g1:GetFirst()
	-- 获取对方卡组最上方的一张卡
	local g2=Duel.GetDecktopGroup(1-tp,1)
	local tc2=g2:GetFirst()
	if bit.band(tc1:GetType(),0x7)==bit.band(tc2:GetType(),0x7) then
		-- 使接下来的加入手卡操作不触发系统自动洗牌
		Duel.DisableShuffleCheck()
		-- 将自己卡组最上方的卡加入手卡
		Duel.SendtoHand(tc1,nil,REASON_EFFECT)
		-- 将对方卡组最上方的卡加入手卡
		Duel.SendtoHand(tc2,nil,REASON_EFFECT)
		-- 洗切自己手卡
		Duel.ShuffleHand(tp)
		-- 洗切对方手卡
		Duel.ShuffleHand(1-tp)
	else
		-- 使接下来的除外操作不触发系统自动洗牌
		Duel.DisableShuffleCheck()
		-- 将自己卡组最上方的卡表侧表示除外
		Duel.Remove(tc1,POS_FACEUP,REASON_EFFECT)
		-- 将对方卡组最上方的卡表侧表示除外
		Duel.Remove(tc2,POS_FACEUP,REASON_EFFECT)
	end
end
