--幻獣機レイステイルス
-- 效果：
-- 这张卡给与对方基本分战斗伤害时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。此外，1回合1次，把1只衍生物解放才能发动。选择场上1张魔法·陷阱卡破坏。
function c30811116.initial_effect(c)
	-- 对应效果原文：这张卡的等级上升自己场上的「幻兽机衍生物」的等级的合计数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(c30811116.lvval)
	c:RegisterEffect(e1)
	-- 对应效果原文：只要自己场上有衍生物存在，这张卡不会被战斗以及效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	-- 设置该破坏免疫效果的适用条件：自己场上有衍生物存在（aux.tkfcon）。
	e2:SetCondition(aux.tkfcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 对应效果原文：这张卡给与对方基本分战斗伤害时，把1只「幻兽机衍生物」（机械族·风·3星·攻/守0）特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30811116,0))  --"特殊召唤Token"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c30811116.spcon)
	e4:SetTarget(c30811116.sptg)
	e4:SetOperation(c30811116.spop)
	c:RegisterEffect(e4)
	-- 对应效果原文：此外，1回合1次，把1只衍生物解放才能发动。选择场上1张魔法·陷阱卡破坏。
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
-- 计算等级上升数值：统计自己场上所有「幻兽机衍生物」的等级总和，作为此卡的等级上升值。
function c30811116.lvval(e,c)
	local tp=c:GetControler()
	-- 获取自己场上所有名为「幻兽机衍生物」（31533705）的怪兽，并累加它们的等级，作为等级上升数值。
	return Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,nil,31533705):GetSum(Card.GetLevel)
end
-- 战斗伤害诱发条件：受到战斗伤害的玩家不是此卡的控制者，即此卡给予对方战斗伤害。
function c30811116.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 特殊召唤衍生物效果的发动判定：在发动确认时无条件合法，并登记操作信息为生成1只衍生物且特殊召唤。
function c30811116.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次操作包含衍生物生成，数量为1，供连锁判定等系统识别。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 登记本次操作包含特殊召唤，数量为1，供连锁判定等系统识别。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：若主要怪兽区有空位且允许特殊召唤，则生成「幻兽机衍生物」并表侧攻击表示特殊召唤到自己场上。
function c30811116.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的主要怪兽区空格，若无空位则无法特殊召唤，直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以将该衍生物（机械族·风·3星·攻/守0）以表侧表示特殊召唤到场上。
	if Duel.IsPlayerCanSpecialSummonMonster(tp,31533705,0x101b,TYPES_TOKEN_MONSTER,0,0,3,RACE_MACHINE,ATTRIBUTE_WIND) then
		-- 在场上生成1只「幻兽机衍生物」Token（卡号30811117）。
		local token=Duel.CreateToken(tp,30811117)
		-- 将生成的衍生物以表侧攻击表示特殊召唤到自己主要怪兽区。
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 解放衍生物的发动COST处理：检查自己场上是否存在可解放的衍生物，若有则选择1只解放作为代价。
function c30811116.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只衍生物（TYPE_TOKEN）可以解放作为发动代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_TOKEN) end
	-- 从自己场上选择1只衍生物作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_TOKEN)
	-- 将选中的衍生物解放，作为效果发动的COST。
	Duel.Release(g,REASON_COST)
end
-- 定义可选择的对象：场上的魔法·陷阱卡（无论表侧里侧，类型为魔法或陷阱）。
function c30811116.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动的对象选择：检查场上是否存在可选择的魔法陷阱卡，若存在则提示玩家选择1张，并设定破坏操作信息。
function c30811116.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c30811116.filter(chkc) end
	-- 检查双方场上是否存在至少1张可以成为对象的魔法陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c30811116.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从双方场上选择1张魔法陷阱卡，作为本效果的对象。
	local g=Duel.SelectTarget(tp,c30811116.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次操作包含破坏，数量为1，对象为选中的卡，供连锁判定等系统识别。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：取得对象卡，若对象仍与效果关联，则将其破坏。
function c30811116.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那张对象卡（本效果只取1个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象魔法陷阱卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
