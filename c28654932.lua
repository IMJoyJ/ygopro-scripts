--深黒の落とし穴
-- 效果：
-- 5星以上的效果怪兽特殊召唤成功时才能发动。那些5星以上的效果怪兽从游戏中除外。
function c28654932.initial_effect(c)
	-- 5星以上的效果怪兽特殊召唤成功时才能发动。那些5星以上的效果怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c28654932.target)
	e1:SetOperation(c28654932.activate)
	c:RegisterEffect(e1)
end
-- 筛选符合条件的怪兽：必须是表侧表示、效果怪兽、等级5以上且能够被除外；若传入效果e（效果处理阶段），还要求该怪兽与当前效果e仍有关联（未因离场等原因失去联系）。
function c28654932.filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:IsLevelAbove(5)
		and (not e or c:IsRelateToEffect(e)) and c:IsAbleToRemove()
end
-- 发动前的目标判定：检查特殊召唤成功的怪兽中是否存在至少1只满足条件的怪兽；若存在，则将特殊召唤成功的全部怪兽设为当前连锁的关联对象，并将筛选出的满足条件的怪兽作为除外对象记录到操作信息中（数量为筛选出的数量），用于效果处理及连锁判定。
function c28654932.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c28654932.filter,1,nil,nil) end
	local g=eg:Filter(c28654932.filter,nil,nil)
	-- 将本次特殊召唤成功的所有怪兽（eg）设置为当前连锁的广义关联对象，用于在效果处理时判断这些怪兽是否仍与效果存在联系（不取对象效果也会建立此联系）。
	Duel.SetTargetCard(eg)
	-- 设置当前连锁的操作信息，宣告将进行除外处理；要处理的对象为筛选出的满足条件的怪兽g，数量为g的数量；因是不取对象的除外效果，目标玩家和位置参数填0。该信息用于其他卡（如星尘龙等）发动响应判定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理函数：从本次特殊召唤成功的怪兽中，根据filter筛选出仍满足条件、与效果e仍有关联且可被除外的怪兽；若数量大于0，则执行除外。
function c28654932.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c28654932.filter,nil,e)
	if g:GetCount()>0 then
		-- 以表侧表示形式，将筛选出的怪兽从游戏中除外，除外原因为效果（REASON_EFFECT）。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
