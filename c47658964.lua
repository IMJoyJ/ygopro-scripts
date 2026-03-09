--紅蓮の炎壁
-- 效果：
-- 把自己墓地存在的名字带有「熔岩」的怪兽任意数量从游戏中除外发动。为这张卡发动而除外的怪兽数量的「熔岩衍生物」（炎族·炎·1星·攻/守0）在自己场上守备表示特殊召唤。
function c47658964.initial_effect(c)
	-- 效果原文内容：把自己墓地存在的名字带有「熔岩」的怪兽任意数量从游戏中除外发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c47658964.cost)
	e1:SetTarget(c47658964.target)
	e1:SetOperation(c47658964.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的卡片组，检查是否为「熔岩」卡且可作为除外代价
function c47658964.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 效果作用：检测是否满足发动条件并选择除外的卡，设置除外数量标签并执行除外操作
function c47658964.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即自己墓地存在至少1张名字带有「熔岩」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c47658964.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 效果作用：获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 效果作用：向玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 效果作用：选择满足条件的卡片组作为除外对象
	local g=Duel.SelectMatchingCard(tp,c47658964.cfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
	e:SetLabel(g:GetCount())
	-- 效果作用：将选中的卡片以正面表示形式从游戏中除外作为发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果原文内容：为这张卡发动而除外的怪兽数量的「熔岩衍生物」（炎族·炎·1星·攻/守0）在自己场上守备表示特殊召唤。
function c47658964.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即玩家场上存在可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断是否可以特殊召唤指定参数的衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,47658965,0x39,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE) end
	-- 效果作用：设置操作信息，标记将要特殊召唤的衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,e:GetLabel(),0,0)
	-- 效果作用：设置操作信息，标记将要特殊召唤的衍生物数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,e:GetLabel(),0,0)
end
-- 效果作用：执行发动效果，检查是否满足特殊召唤条件并处理特殊召唤过程
function c47658964.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 效果作用：判断是否满足特殊召唤条件，包括场上空位不足或无法特殊召唤衍生物
	if ft<e:GetLabel() or not Duel.IsPlayerCanSpecialSummonMonster(tp,47658965,0x39,TYPES_TOKEN_MONSTER,0,0,1,RACE_PYRO,ATTRIBUTE_FIRE,POS_FACEUP_DEFENSE)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		or (e:GetLabel()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	for i=1,e:GetLabel() do
		-- 效果作用：创建指定编号的衍生物卡片
		local token=Duel.CreateToken(tp,47658965)
		-- 效果作用：将衍生物以守备表示形式特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 效果作用：完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
