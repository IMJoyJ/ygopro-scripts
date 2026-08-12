--天刑王 ブラック・ハイランダー
-- 效果：
-- 恶魔族调整＋调整以外的恶魔族怪兽1只以上
-- 只要这张卡在场上表侧表示存在，双方不能同调召唤。1回合1次，选择有装备卡装备的1只对方怪兽才能发动。选择的怪兽装备的装备卡全部破坏，给与对方基本分破坏数量×400的数值的伤害。
function c75326861.initial_effect(c)
	-- 设置同调召唤手续：恶魔族调整+1只以上调整以外的恶魔族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),aux.NonTuner(Card.IsRace,RACE_FIEND),1)
	c:EnableReviveLimit()
	-- 只要这张卡在场上表侧表示存在，双方不能同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetTarget(c75326861.splimit)
	c:RegisterEffect(e1)
	-- 1回合1次，选择有装备卡装备的1只对方怪兽才能发动。选择的怪兽装备的装备卡全部破坏，给与对方基本分破坏数量×400的数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75326861,0))  --"装备卡破坏"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c75326861.target)
	e2:SetOperation(c75326861.operation)
	c:RegisterEffect(e2)
end
-- 限制特殊召唤的类型为同调召唤
function c75326861.splimit(e,c,tp,sumtp,sumpos)
	return bit.band(sumtp,SUMMON_TYPE_SYNCHRO)==SUMMON_TYPE_SYNCHRO
end
-- 过滤装备卡数量大于0的卡片（即有装备卡装备的怪兽）
function c75326861.filter(c)
	return c:GetEquipCount()>0
end
-- 效果发动的对象选择与操作信息设置
function c75326861.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c75326861.filter(chkc) end
	-- 检查对方场上是否存在至少1只装备有装备卡的怪兽
	if chk==0 then return Duel.IsExistingTarget(c75326861.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择对方的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只装备有装备卡的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75326861.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local eqg=g:GetFirst():GetEquipGroup()
	-- 设置破坏操作的信息，目标为该怪兽装备的所有装备卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eqg,eqg:GetCount(),0,0)
	-- 设置伤害操作的信息，对象为对方玩家，数值为装备卡数量×400
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eqg:GetCount()*400)
end
-- 效果处理：破坏目标怪兽装备的所有装备卡，并给与对方对应数量×400的伤害
function c75326861.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local eqg=tc:GetEquipGroup()
		if eqg:GetCount()>0 then
			-- 因效果破坏该怪兽装备的所有装备卡，并返回实际破坏的数量
			local des=Duel.Destroy(eqg,REASON_EFFECT)
			-- 因效果给与对方玩家“实际破坏数量×400”的伤害
			Duel.Damage(1-tp,des*400,REASON_EFFECT)
		end
	end
end
