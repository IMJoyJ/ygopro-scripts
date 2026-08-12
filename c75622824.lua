--トリッキーズ・マジック4
-- 效果：
-- ①：把自己场上1只表侧表示的「诡术师」送去墓地才能发动。对方场上的怪兽数量的「诡术师衍生物」（魔法师族·风·5星·攻2000/守1200）在自己场上守备表示特殊召唤。这衍生物不能攻击宣言。
function c75622824.initial_effect(c)
	-- ①：把自己场上1只表侧表示的「诡术师」送去墓地才能发动。对方场上的怪兽数量的「诡术师衍生物」（魔法师族·风·5星·攻2000/守1200）在自己场上守备表示特殊召唤。这衍生物不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c75622824.cost)
	e1:SetTarget(c75622824.target)
	e1:SetOperation(c75622824.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「诡术师」且能作为代价送去墓地
function c75622824.cfilter(c)
	return c:IsFaceup() and c:IsCode(14778250) and c:IsAbleToGraveAsCost()
end
-- 效果发动代价：将自己场上1只表侧表示的「诡术师」送去墓地
function c75622824.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只满足过滤条件的「诡术师」
	if chk==0 then return Duel.IsExistingMatchingCard(c75622824.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1只满足过滤条件的「诡术师」
	local g=Duel.SelectMatchingCard(tp,c75622824.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动时的合法性检测：检查对方场上是否有怪兽、自己场上是否有足够的怪兽区域，以及是否能特殊召唤衍生物
function c75622824.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return ct>0 and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,59822133))
		-- 检查自己场上的怪兽区域是否足够容纳即将特殊召唤的衍生物数量
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>ct-2
		-- 检查玩家是否可以特殊召唤指定的「诡术师衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,75622825,0,TYPES_TOKEN_MONSTER,2000,1200,5,RACE_SPELLCASTER,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) end
	-- 设置当前处理的连锁信息：包含产生衍生物效果，数量为对方场上怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,ct,0,0)
	-- 设置当前处理的连锁信息：包含特殊召唤效果，数量为对方场上怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,0,0)
end
-- 效果处理：在自己场上守备表示特殊召唤对应数量的「诡术师衍生物」，并赋予其不能攻击宣言的效果
function c75622824.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取对方场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)
	if ft<ct then return end
	-- 检查玩家是否可以特殊召唤指定的「诡术师衍生物」，若不能则结束处理
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,75622825,0,TYPES_TOKEN_MONSTER,2000,1200,5,RACE_SPELLCASTER,ATTRIBUTE_WIND,POS_FACEUP_DEFENSE) then return end
	for i=1,ct do
		-- 创建「诡术师衍生物」卡片数据
		local token=Duel.CreateToken(tp,75622825)
		-- 将衍生物以表侧守备表示特殊召唤到自己场上（单步处理）
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这衍生物不能攻击宣言。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
	end
	-- 完成所有怪兽的特殊召唤处理
	Duel.SpecialSummonComplete()
end
