--幻獣機レイステイルス
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。选择场上1张魔法·陷阱卡破坏。
function c30811116.initial_effect(c)
	-- 这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c30811116.lvval)
	c:RegisterEffect(e1)
	-- 只要自己场上有衍生物存在，这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 判断场上是否存在衍生物的条件函数
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 这张卡给与对方基本分战斗伤害时，把1只「幻兽机衍生物」特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30811116,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c30811116.spcon)
	e4:SetTarget(c30811116.sptg)
	e4:SetOperation(c30811116.spop)
	c:RegisterEffect(e4)
	-- 1回合1次，把1只衍生物解放才能发动。选择场上1张魔法·陷阱卡破坏
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(30811116,1))  --"魔陷破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1)
	e5:SetCost(c30811116.descost)
	e5:SetTarget(c30811116.destg)
	e5:SetOperation(c30811116.desop)
	c:RegisterEffect(e5)
end
-- 计算场上所有幻兽机衍生物的等级总和
function c30811116.lvval(e,c)
	local tp=c:GetControler()
	-- 获取场上所有幻兽机衍生物并求和其等级
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 确认战斗伤害是由对方造成的
function c30811116.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置特殊召唤衍生物和衍生物token的处理信息
function c30811116.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤衍生物的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置衍生物token的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 检查是否有足够的召唤位置并特殊召唤衍生物token
function c30811116.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤该衍生物token
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 创建一个幻兽机衍生物token
		local token=Duel.CreateToken(tp,30811117)
		-- 将创建的衍生物token特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 支付效果的解放费用，解放一个衍生物
function c30811116.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的衍生物
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 选择一个可解放的衍生物
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选中的衍生物解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 过滤魔法或陷阱卡的函数
function c30811116.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择并设置要破坏的魔法或陷阱卡
function c30811116.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c30811116.filter(chkc) end
	-- 检查场上是否存在可破坏的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c30811116.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张魔法或陷阱卡作为目标
	local g=Duel.SelectTarget(tp,c30811116.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏魔法或陷阱卡的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡破坏
function c30811116.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理中选择的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
