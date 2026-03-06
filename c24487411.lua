--デトネイト・デリーター
-- 效果：
-- 电子界族怪兽2只以上
-- ①：1回合1次，除连接3以上的连接怪兽外的表侧表示怪兽和这张卡进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。
-- ②：1回合1次，把这张卡所连接区1只自己怪兽解放，以对方场上1只怪兽为对象才能发动。那只怪兽破坏。
function c24487411.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用至少2只电子界族怪兽作为连接素材
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
-- 效果作用：判断是否满足破坏条件，即战斗中的对方怪兽为表侧表示且连接值不超过2
function c24487411.destg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsFaceup() and not tc:IsLinkAbove(3) end
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果作用：破坏战斗中对方的怪兽
function c24487411.desop1(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断怪兽是否在指定的连接怪兽组中
function c24487411.cfilter(c,g)
	return g:IsContains(c)
end
-- 效果作用：支付解放连接怪兽的费用
function c24487411.descost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否满足解放连接怪兽的条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,c24487411.cfilter,1,nil,lg) end
	-- 选择满足条件的1只连接怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c24487411.cfilter,1,1,nil,lg)
	-- 将选中的连接怪兽以代价原因解放
	Duel.Release(g,REASON_COST)
end
-- 效果作用：选择对方场上1只怪兽作为破坏对象
function c24487411.destg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可破坏的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果作用：破坏选中的对方怪兽
function c24487411.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
