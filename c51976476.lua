--姑息な落とし穴
-- 效果：
-- ①：对方把怪兽守备表示特殊召唤时才能发动。那些守备表示怪兽除外。
function c51976476.initial_effect(c)
	-- ①：对方把怪兽守备表示特殊召唤时才能发动。那些守备表示怪兽除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c51976476.target)
	e1:SetOperation(c51976476.activate)
	c:RegisterEffect(e1)
end
-- 过滤符合条件的怪兽：必须是由对方玩家特殊召唤、当前为守备表示且可被除外的怪兽；若传入效果e用于处理阶段，则还要求该怪兽与发动时的效果仍有关联且仍在怪兽区域。
function c51976476.filter(c,e,tp)
	return c:IsSummonPlayer(tp) and c:IsDefensePos() and c:IsAbleToRemove()
		and (not e or (c:IsRelateToEffect(e) and c:IsLocation(LOCATION_MZONE)))
end
-- 发动时的条件检测与对象设定：检查本次特殊召唤成功的怪兽组中是否存在满足过滤条件的对方怪兽；若存在，则将这些怪兽取出并设为对象，同时登记除外效果的操作信息。
function c51976476.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c51976476.filter,1,nil,nil,1-tp) end
	local g=eg:Filter(c51976476.filter,nil,nil,1-tp)
	-- 将筛选出的守备表示怪兽设置为当前连锁的对象，使效果处理时能够锁定这些怪兽。
	Duel.SetTargetCard(g)
	-- 设置操作信息，声明本效果将除外这些怪兽（数量为g的数量），以供连锁判定和效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：从连锁信息中取得发动时记录的对象，再次过滤出仍然满足条件且与效果关联、仍在场的守备表示怪兽，若存在则执行除外。
function c51976476.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象卡组（即发动时选定的那些守备表示怪兽）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(c51976476.filter,nil,e,1-tp)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽以表侧表示除外，完成效果处理。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
