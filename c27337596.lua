--聖刻龍王－アトゥムス
-- 效果：
-- 龙族6星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组选1只龙族怪兽，攻击力·守备力变成0特殊召唤。这个效果发动的回合，这张卡不能攻击。
function c27337596.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用满足龙族条件的等级为6的怪兽进行叠放，最少需要2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),6,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从卡组选1只龙族怪兽，攻击力·守备力变成0特殊召唤。这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27337596,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c27337596.spcost)
	e1:SetTarget(c27337596.sptg)
	e1:SetOperation(c27337596.spop)
	c:RegisterEffect(e1)
end
-- 检查是否满足发动条件：本回合未宣布过攻击且自身能移除1个超量素材
function c27337596.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	-- 设置效果：本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义特殊召唤的过滤函数，用于筛选满足条件的龙族怪兽
function c27337596.spfilter(c,e,tp)
	-- 筛选条件：该怪兽为龙族且可以被特殊召唤
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DragonXyzSpSummonType(c))
end
-- 设置效果的目标函数，检查是否满足发动条件：场上存在空位且卡组存在满足条件的龙族怪兽
function c27337596.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组是否存在满足条件的龙族怪兽
		and Duel.IsExistingMatchingCard(c27337596.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只龙族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：选择卡组中的龙族怪兽并特殊召唤，同时设置其攻击力和守备力为0
function c27337596.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c27337596.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,aux.DragonXyzSpSummonType(tc),POS_FACEUP) then
		-- 设置效果：将该怪兽的攻击力设置为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
		-- 如果该怪兽为XYZ召唤类型，则完成召唤程序
		if aux.DragonXyzSpSummonType(tc) then
			tc:CompleteProcedure()
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
