--エクストラゲート
-- 效果：
-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方的额外卡组的场合，选择自己1张手卡丢弃。
function c7405310.initial_effect(c)
	-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方的额外卡组的场合，选择自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7405310.target)
	e1:SetOperation(c7405310.operation)
	c:RegisterEffect(e1)
end
-- 效果发动时的可行性检查
function c7405310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1张卡（用于不满足条件时丢弃手牌）
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 检查对方额外卡组中是否存在可以被除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 设置提示信息为提示玩家宣言等级
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	-- 让发动效果的玩家宣言一个等级并获取该等级
	local lv=Duel.AnnounceLevel(tp)
	e:SetLabel(lv)
end
-- 过滤函数：筛选等级与宣言等级相同的卡片
function c7405310.filter(c,lv)
	return c:IsLevel(lv)
end
-- 效果处理的核心逻辑，处理除外或丢弃手牌的效果
function c7405310.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家是否可以进行除外操作，若不能则直接返回
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 获取对方额外卡组中所有等级与宣言等级相同的怪兽
	local g=Duel.GetMatchingGroup(c7405310.filter,1-tp,LOCATION_EXTRA,0,nil,e:GetLabel())
	if g:GetCount()~=0 then
		-- 给对方玩家发送提示信息，提示选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil)
		if rg:GetCount()~=0 then
			-- 将对方选择的卡片以表侧表示除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	else
		-- 让玩家选择自己的一张手牌丢弃
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
