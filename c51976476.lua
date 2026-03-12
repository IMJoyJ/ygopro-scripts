--姑息な落とし穴
-- 效果：
-- ①：对方把怪兽守备表示特殊召唤时才能发动。那些守备表示怪兽除外。
function c51976476.initial_effect(c)
	-- 效果原文内容：①：对方把怪兽守备表示特殊召唤时才能发动。那些守备表示怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c51976476.target)
	e1:SetOperation(c51976476.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：筛选满足条件的怪兽（召唤玩家为指定玩家、守备表示、可以除外）
function c51976476.filter(c,e,tp)
	return c:IsSummonPlayer(tp) and c:IsDefensePos() and c:IsAbleToRemove()
		and (not e or (c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)))
end
-- 规则层面作用：判断是否满足发动条件并设置效果对象和操作信息
function c51976476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c51976476.filter,1,nil,nil,1-tp) end
	local g=eg:Filter(c51976476.filter,nil,nil,1-tp)
	-- 规则层面作用：将目标怪兽组设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 规则层面作用：设置当前连锁的操作信息，包括除外效果分类、目标卡组及数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 规则层面作用：处理效果发动，检索符合条件的怪兽并除外
function c51976476.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(c51976476.filter,nil,e,1-tp)
	if g:GetCount()>0 then
		-- 规则层面作用：以效果原因将目标卡组除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
