--騎甲虫隊降下作戦
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：在自己场上把1只「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）特殊召唤。那之后，自己场上有攻击力3000以上的昆虫族怪兽存在的场合，可以选场上1张魔法·陷阱卡破坏。
function c87240371.initial_effect(c)
	-- ①：在自己场上把1只「骑甲虫衍生物」（昆虫族·地·3星·攻/守1000）特殊召唤。那之后，自己场上有攻击力3000以上的昆虫族怪兽存在的场合，可以选场上1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,87240371+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c87240371.target)
	e1:SetOperation(c87240371.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的可行性检查（检查怪兽区域空位以及是否能特殊召唤衍生物）
function c87240371.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤满足特定属性、种族、攻守和等级的衍生物怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) end
	-- 设置连锁信息，表示该效果包含产生衍生物的操作
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁信息，表示该效果包含特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
-- 效果处理的核心逻辑（特殊召唤衍生物，并根据条件选择是否破坏场上的魔法·陷阱卡）
function c87240371.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查怪兽区域空位和是否能特殊召唤衍生物，若不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummonMonster(tp,64213018,0x170,TYPES_TOKEN_MONSTER,1000,1000,3,RACE_INSECT,ATTRIBUTE_EARTH) then return end
	-- 创建「骑甲虫衍生物」的卡片数据
	local token=Duel.CreateToken(tp,87240372)
	-- 获取当前发动的这张卡（用于后续破坏效果时，防止破坏自身）
	local ec=aux.ExceptThisCard(e)
	-- 将衍生物以表侧表示特殊召唤到自己场上，并检查是否特殊召唤成功
	if Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查自己场上是否存在攻击力3000以上的昆虫族怪兽
		and Duel.IsExistingMatchingCard(c87240371.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查场上是否存在除这张卡以外的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c87240371.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ec)
		-- 询问玩家是否选择破坏场上的一张魔法·陷阱卡
		and Duel.SelectYesNo(tp,aux.Stringid(87240371,0)) then  --"是否选魔法·陷阱卡破坏？"
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择场上1张除这张卡以外的魔法·陷阱卡
		local sg=Duel.SelectMatchingCard(tp,c87240371.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,ec)
		-- 中断当前效果处理，使后续的破坏操作与特殊召唤不视为同时处理（满足“那之后”的时点要求）
		Duel.BreakEffect()
		-- 显式地在场上框选并展示被选中的卡片
		Duel.HintSelection(sg)
		-- 因效果破坏选中的卡片
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
-- 过滤条件：表侧表示、昆虫族且攻击力在3000以上的怪兽
function c87240371.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAttackAbove(3000)
end
-- 过滤条件：魔法卡或陷阱卡
function c87240371.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
