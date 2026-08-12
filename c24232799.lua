--脚納母艦ブラキオーバー
-- 效果：
-- 「机动要犀 铁犀三角龙」或「盾航战车 电子剑龙」＋机械族·恐龙族怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要从墓地特殊召唤的怪兽存在，这张卡不会被战斗破坏。
-- ②：这张卡在怪兽区域存在的状态，从手卡有怪兽特殊召唤的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，设置苏生限制，添加融合素材代码列表，并注册两个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤所需的素材代码列表，允许使用卡号为12275533和99733359的卡作为融合素材
	aux.AddMaterialCodeList(c,12275533,99733359)
	-- 设置该卡的融合召唤条件，要求一个融合代码为12275533或99733359的怪兽和一个机械族或恐龙族的怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionCode,12275533,99733359),aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE+RACE_DINOSAUR),true)
	-- ①：只要从墓地特殊召唤的怪兽存在，这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，从手卡有怪兽特殊召唤的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 判断是否有从墓地特殊召唤的怪兽存在
function s.indescon(e)
	-- 检查是否存在从墓地特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,LOCATION_GRAVE)
end
-- 判断是否从手卡特殊召唤了怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
end
-- 设置效果的发动条件和目标选择逻辑
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可破坏的目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在可破坏的目标
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为破坏目标
	local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏目标
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，确定将要破坏的卡的数量为2
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 执行效果的破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将与连锁相关的卡破坏
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
