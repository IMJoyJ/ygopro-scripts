--合体術式－エンゲージ・ゼロ
-- 效果：
-- 光·暗属性怪兽2只
-- 这个卡名在规则上也当作「闪刀姬」卡使用。自己对「合体术式-交闪零式」1回合只能有1次特殊召唤，这张卡不能作为连接素材。
-- ①：这张卡特殊召唤的场合，以场上1只攻击力2500以上的怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：自己墓地有「闪刀姬-零衣」以及「闪刀姬-露世」存在的场合，这张卡攻击的伤害步骤开始时才能发动。对方场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化效果函数，设置卡片的特殊召唤次数限制、连接召唤手续、复活限制，并注册三个效果
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 添加连接召唤手续，要求使用2只光属性和暗属性的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT+ATTRIBUTE_DARK),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以场上1只攻击力2500以上的怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.netg)
	e1:SetOperation(s.neop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有「闪刀姬-零衣」以及「闪刀姬-露世」存在的场合，这张卡攻击的伤害步骤开始时才能发动。对方场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- 这张卡不能作为连接素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于筛选可以被无效化的怪兽（表侧表示、效果怪兽且攻击力不低于2500）
function s.nefilter(c)
	-- 筛选表侧表示、效果怪兽且攻击力不低于2500的怪兽
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2500)
end
-- 设置效果目标选择函数，检查场上是否存在满足条件的怪兽并选择目标
function s.netg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.nefilter(chkc) end
	-- 检查是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.nefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,s.nefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要无效的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 设置效果处理函数，使目标怪兽的效果无效
function s.neop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使目标怪兽相关的连锁无效化
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 创建使目标怪兽效果无效的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建使目标怪兽效果无效化的永续效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 设置效果发动条件函数，检查是否为该卡攻击且墓地存在指定卡片
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前攻击的怪兽是否为该卡
	return Duel.GetAttacker()==e:GetHandler()
		-- 检查自己墓地是否存在「闪刀姬-零衣」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,26077387)
		-- 检查自己墓地是否存在「闪刀姬-露世」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,37351133)
end
-- 设置效果目标选择函数，检查对方场上是否存在怪兽并准备破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息，记录将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 设置效果处理函数，破坏对方场上的所有怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将所有怪兽破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
