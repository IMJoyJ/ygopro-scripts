--脚納母艦ブラキオーバー
-- 效果：
-- 「机动要犀 铁犀三角龙」或「盾航战车 电子剑龙」＋机械族·恐龙族怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要从墓地特殊召唤的怪兽存在，这张卡不会被战斗破坏。
-- ②：这张卡在怪兽区域存在的状态，从手卡有怪兽特殊召唤的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化「脚纳母舰 超大腕龙」(24232799)：设置苏生限制、融合召唤素材要求，并注册①战破抗性和②手卡特召触发破坏效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：「机动要犀 铁犀三角龙」(12275533)或「盾航战车 电子剑龙」(99733359)＋1只机械族或恐龙族怪兽（允许融合素材替代与额外条件）
	aux.AddFusionProcCodeFun(c,{12275533,99733359},aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE+RACE_DINOSAUR),1,true,true)
	-- ①：只要从墓地特殊召唤的怪兽存在，这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCondition(s.indescon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在怪兽区域存在的状态，从手卡有怪兽特殊召唤的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
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
-- 效果①的Condition函数：检查双方怪兽区域是否存在从墓地特殊召唤出场的怪兽
function s.indescon(e)
	-- 检查场上双方怪兽区中是否存在至少1只召唤位置为墓地（即从墓地特殊召唤）的怪兽
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,LOCATION_GRAVE)
end
-- 效果②的Condition函数：检查本次特殊召唤事件中是否有怪兽是从手卡特殊召唤的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
end
-- 效果②的Target函数：检测自己和对方场上是否各有至少1张可作为对象的卡，随后分别选取各1张卡为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动检测时确认己方场上存在至少1张可作为对象的卡
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil)
		-- 发动检测时确认对方场上存在至少1张可作为对象的卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向己方玩家发送选择己方场上要破坏的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从己方场上选择1张卡作为破坏对象
	local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 向己方玩家发送选择对方场上要破坏的卡片提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为破坏对象
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置将己方与对方场上所选共2张对象卡破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 效果②的Operation函数：获取当前仍与本次连锁关联的所有对象卡片并将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏仍与当前连锁保持关联的双方场上对象卡
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
