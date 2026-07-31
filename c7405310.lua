--エクストラゲート
-- 效果：
-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方的额外卡组的场合，选择自己1张手卡丢弃。
function c7405310.initial_effect(c)
	-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏除外。持有宣言的等级的怪兽不在对方的额外卡组场合，选择自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7405310.target)
	e1:SetOperation(c7405310.operation)
	c:RegisterEffect(e1)
end
-- 卡片发动准备：检查发动条件并由玩家宣言1~12的等级，记录宣言的等级
function c7405310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：手牌中除了此卡外至少存在1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 发动条件检查：对方额外卡组至少存在1张可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 提示玩家选择/宣言等级或阶级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让发动玩家宣言1到12的任意等级
	local lv=Duel.AnnounceLevel(tp)
	e:SetLabel(lv)
end
-- 过滤条件：额外卡组中等级等于宣言等级的怪兽
function c7405310.filter(c,lv)
	return c:IsLevel(lv)
end
-- 卡片效果处理：对方从额外卡组除外1只宣言等级的怪兽，若没有则自己丢弃1张手牌
function c7405310.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否处于无法除外卡片的状态
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 获取对方额外卡组中所有等级等于宣言等级的怪兽
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
		-- 若对方额外卡组无对应等级怪兽，从自己手牌选择1张丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
