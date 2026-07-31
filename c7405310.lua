--エクストラゲート
-- 效果：
-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方的额外卡组的场合，选择自己1张手卡丢弃。
function c7405310.initial_effect(c)
	-- ①：宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方额外卡组的场合，选择自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7405310.target)
	e1:SetOperation(c7405310.operation)
	c:RegisterEffect(e1)
end
-- ①效果发动准备：宣言1~12的任意等级
function c7405310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：手牌中是否存在除了此卡以外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 发动条件检查：对方额外卡组是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 提示玩家选择等级/阶级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 玩家宣言1~12的任意等级
	local lv=Duel.AnnounceLevel(tp)
	e:SetLabel(lv)
end
-- 过滤条件：判断怪兽等级是否为宣言的等级
function c7405310.filter(c,lv)
	return c:IsLevel(lv)
end
-- ①效果处理：对方从额外卡组除外1只对应等级怪兽，若无则自己丢弃1张手牌
function c7405310.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方玩家是否可以执行除外操作
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 获取对方额外卡组中持有宣言等级的所有怪兽
	local g=Duel.GetMatchingGroup(c7405310.filter,1-tp,LOCATION_EXTRA,0,nil,e:GetLabel())
	if g:GetCount()~=0 then
		-- 提示对方玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil)
		if rg:GetCount()~=0 then
			-- 将对方选中的1只怪兽表侧表示除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	else
		-- 对方额外卡组无对应等级怪兽时，自己选择1张手牌丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
