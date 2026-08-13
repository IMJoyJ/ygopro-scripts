--脚納母艦ブラキオーバー
-- 效果：
-- 「机动要犀 铁犀三角龙」或「盾航战车 电子剑龙」＋机械族·恐龙族怪兽
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要从墓地特殊召唤的怪兽存在，这张卡不会被战斗破坏。
-- ②：这张卡在怪兽区域存在的状态，从手卡有怪兽特殊召唤的场合，以自己以及对方场上的卡各1张为对象才能发动。那些卡破坏。
local s,id,o=GetID()
-- 初始化该卡的效果：设置融合召唤手续（以「机动要犀 铁犀三角龙」或「盾航战车 电子剑龙」＋机械族·恐龙族怪兽为素材）、苏生限制、①的不会被战斗破坏效果以及②的从手卡特召时破坏双方场上各1张卡的效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 将「机动要犀 铁犀三角龙」和「盾航战车 电子剑龙」登记为该卡融合素材的关联卡名。
	aux.AddMaterialCodeList(c,12275533,99733359)
	-- 为这张卡添加融合召唤手续：以1只「机动要犀 铁犀三角龙」或「盾航战车 电子剑龙」和1只机械族·恐龙族怪兽作为融合素材。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionCode,12275533,99733359),aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE+RACE_DINOSAUR),true)
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
-- 定义①效果的条件：场上存在从墓地特殊召唤的怪兽时才不会被战斗破坏。
function s.indescon(e)
	-- 检查双方场上是否存在至少1只从墓地特殊召唤的怪兽（召唤位置为墓地）。
	return Duel.IsExistingMatchingCard(Card.IsSummonLocation,0,LOCATION_MZONE,LOCATION_MZONE,1,nil,LOCATION_GRAVE)
end
-- 定义②效果的触发条件：本次特殊召唤成功的怪兽中至少有1只是从手卡特殊召唤的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonLocation,1,nil,LOCATION_HAND)
end
-- 定义②效果的目标选择流程：不在对象核对时选择；发动时需确认自己场上和对方场上各存在至少1张可选为对象的卡。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定条件之一：自己场上存在至少1张可以成为效果的对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil)
		-- 判定条件之二：对方场上存在至少1张可以成为效果的对象的卡。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给操作玩家显示选择要破坏的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上的1张卡作为效果对象，并加入当前连锁的处理对象。
	local g1=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 再次给操作玩家显示选择要破坏的卡片的提示信息，用于选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为效果对象，并加入当前连锁的处理对象。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置本次连锁的操作信息：破坏分类，对象为已选择的2张卡，用于各种效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- ②效果处理：破坏本次效果选择的全部对象卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将当前连锁中所有关联的对象卡以效果原因破坏。
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
