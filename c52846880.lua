--カタストルの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除「灾亡虫之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃，以自己墓地1只「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：自己的「影灵衣」怪兽和从额外卡组特殊召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
function c52846880.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：把这张卡从手卡丢弃，以自己墓地1只「影灵衣」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡的特殊召唤条件为必须通过仪式召唤方式特殊召唤，且不能使用除自身以外的怪兽进行仪式召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ②：自己的「影灵衣」怪兽和从额外卡组特殊召唤的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52846880,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,52846880)
	e2:SetCost(c52846880.spcost)
	e2:SetTarget(c52846880.sptg)
	e2:SetOperation(c52846880.spop)
	c:RegisterEffect(e2)
	-- 设置此卡的特殊召唤条件为必须通过仪式召唤方式特殊召唤，且不能使用除自身以外的怪兽进行仪式召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(52846880,1))  --"怪兽破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c52846880.condition)
	e3:SetTarget(c52846880.target)
	e3:SetOperation(c52846880.operation)
	c:RegisterEffect(e3)
end
-- 过滤掉自身，用于判断仪式召唤中是否使用了除自身外的其他怪兽作为祭品
function c52846880.mat_filter(c)
	return not c:IsCode(52846880)
end
-- 支付效果代价：将自身从手牌丢入墓地
function c52846880.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身从手牌丢入墓地作为发动效果的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 筛选可以特殊召唤的「影灵衣」怪兽
function c52846880.spfilter(c,e,tp)
	return c:IsSetCard(0xb4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置选择目标：从自己墓地中选择一只「影灵衣」怪兽作为特殊召唤对象
function c52846880.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52846880.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在符合条件的「影灵衣」怪兽
		and Duel.IsExistingTarget(c52846880.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地中的「影灵衣」怪兽作为目标
	local g=Duel.SelectTarget(tp,c52846880.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，确定将要特殊召唤的怪兽数量和对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作：将选定的怪兽从墓地特殊召唤到场上
function c52846880.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足破坏效果发动条件：己方「影灵衣」怪兽与从额外卡组特殊召唤的怪兽战斗
function c52846880.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取本次战斗中的防守怪兽
	local bc=Duel.GetAttackTarget()
	if not bc then return false end
	if tc:IsControler(1-tp) then tc,bc=bc,tc end
	if tc:IsSetCard(0xb4) and bc:IsSummonLocation(LOCATION_EXTRA) then
		e:SetLabelObject(bc)
		return true
	else return false end
end
-- 设置破坏效果的目标：将符合条件的防守怪兽设为破坏对象
function c52846880.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetLabelObject()
	-- 设置效果处理时的操作信息，确定将要破坏的怪兽数量和对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 执行破坏操作：将符合条件的怪兽从场上破坏
function c52846880.operation(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
