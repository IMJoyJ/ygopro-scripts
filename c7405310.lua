--エクストラゲート
-- 效果：
-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方的额外卡组的场合，选择自己1张手卡丢弃。
function c7405310.initial_effect(c)
	-- 宣言从1到12的任意等级发动。对方把额外卡组存在的1只持有宣言的等级的怪兽从游戏中除外。持有宣言的等级的怪兽不在对方的额外卡组的场合，选择自己1张手卡丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c7405310.target)
	e1:SetOperation(c7405310.operation)
	c:RegisterEffect(e1)
end
-- 魔法卡发动效果的目标函数：检查自己手卡和对方额外卡组是否满足发动条件并宣言等级，记录等级到效果标签
function c7405310.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否至少有1张手卡可以被丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,0,1,e:GetHandler())
		-- 并且检查对方额外卡组是否有可以被除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	-- 提示玩家选择等级
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	-- 让玩家宣言1到12的一个等级
	local lv=Duel.AnnounceLevel(tp)
	e:SetLabel(lv)
end
-- 过滤函数：用于检查卡片等级是否与宣言的等级一致
function c7405310.filter(c,lv)
	return c:IsLevel(lv)
end
-- 魔法卡发动效果的处理函数：尝试让对方从额外卡组除外对应等级的怪兽，如果不存在则让自己丢弃1张手卡
function c7405310.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否可以执行除外操作
	if not Duel.IsPlayerCanRemove(tp) then return end
	-- 从对方额外卡组获取等级等于刚才所宣言等级的怪兽组
	local g=Duel.GetMatchingGroup(c7405310.filter,1-tp,LOCATION_EXTRA,0,nil,e:GetLabel())
	if g:GetCount()~=0 then
		-- 提示对方玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil)
		if rg:GetCount()~=0 then
			-- 对方将所选的怪兽正面表示除外
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		end
	else
		-- 自己选择并丢弃1张手卡
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
