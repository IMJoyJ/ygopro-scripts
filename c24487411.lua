--デトネイト・デリーター
-- 效果：
-- 电子界族怪兽2只以上
-- ①：1回合1次，除连接3以上的连接怪兽外的表侧表示怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
-- ②：1回合1次，把这张卡所连接区1只自己怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c24487411.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：可用2只以上电子界族怪兽作为连接素材进行连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2)
	-- ①：1回合1次，除连接3以上的连接怪兽外的表侧表示怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetCountLimit(1)
	e1:SetTarget(c24487411.destg1)
	e1:SetOperation(c24487411.desop1)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡所连接区1只自己怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c24487411.descost2)
	e2:SetTarget(c24487411.destg2)
	e2:SetOperation(c24487411.desop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：取得这张卡的战斗对象，若该怪兽为表侧表示且不是连接3以上的连接怪兽，则满足发动条件，并登记将该怪兽破坏。
function c24487411.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and not tc:IsLinkAbove(3) end
	-- 登记本次连锁的操作信息：以效果破坏那1只战斗对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- ①效果处理时，若战斗对象怪兽仍与本次战斗关联，则将其破坏。
function c24487411.desop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 以效果破坏该怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断卡片c是否属于集合g，用于筛选这张卡所连接区的怪兽。
function c24487411.cfilter(c,g)
	return g:IsContains(c)
end
-- ②效果的发动代价处理：先检查这张卡所连接区是否存在可解放的自己怪兽，若存在则选择1只作为代价解放。
function c24487411.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 发动代价检查：确认这张卡所连接区存在至少1只可解放的自己怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c24487411.cfilter,1,nil,lg) end
	-- 选择1只位于这张卡所连接区的自己怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c24487411.cfilter,1,1,nil,lg)
	-- 将选择的怪兽作为发动代价解放。
	Duel.Release(g,REASON_COST)
end
-- ②效果的取对象目标处理：选择对方场上1只怪兽为对象；选择后登记破坏该怪兽的操作信息。
function c24487411.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 确认对方场上有至少1只可以成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 给操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次连锁的操作信息：以效果破坏选中的那1只对方怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理时，若对象怪兽仍与效果关联，则将其破坏。
function c24487411.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动②效果时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
