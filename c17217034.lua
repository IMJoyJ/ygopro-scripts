--合体術式－エンゲージ・ゼロ
-- 效果：
-- 光·暗属性怪兽2只
-- 这个卡名在规则上也当作「闪刀姬」卡使用。自己对「合体术式-交闪零式」1回合只能有1次特殊召唤，这张卡不能作为连接素材。
-- ①：这张卡特殊召唤的场合，以场上1只攻击力2500以上的怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：自己墓地有「闪刀姬-零衣」以及「闪刀姬-露世」存在的场合，这张卡攻击的伤害步骤开始时才能发动。对方场上的怪兽全部破坏。
local s,id,o=GetID()
-- 初始化效果注册函数：设置1回合1次特殊召唤限制、连接召唤手续（光·暗属性怪兽2只）、召唤限制，并注册①特殊召唤成功时无效场上怪兽效果的诱发效果、②攻击伤害步骤开始时的破坏效果，以及‘不能作为连接素材’的永续效果。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	-- 连接召唤手续：以2只光属性或暗属性怪兽作为连接素材进行连接召唤。
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
-- 定义①效果的过滤函数：选择场上表侧表示、效果未被无效且为效果怪兽，并且攻击力在2500以上的怪兽作为对象。
function s.nefilter(c)
	-- 返回true的条件：该怪兽是表侧表示、效果未被无效且原本是效果怪兽，并且攻击力在2500以上。
	return aux.NegateMonsterFilter(c) and c:IsAttackAbove(2500)
end
-- ①效果的发动/选目标函数：发动时检查场上是否存在符合条件的对象，若存在则让玩家选择1只怪兽作为对象，并设置本次操作要无效1张卡的信息。
function s.netg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.nefilter(chkc) end
	-- 发动合法性检查：确认双方场上存在至少1只满足s.nefilter条件的怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.nefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示文字（HINTMSG_DISABLE：请选择要无效的卡），作为后续选卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 让发动玩家从双方场上选择1只满足s.nefilter条件的怪兽作为效果对象，并将该卡设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.nefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次效果将无效1张卡（CATEGORY_DISABLE），对象为已选择的g，用于发动检测和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理：取得对象怪兽；若对象仍与该效果相关且表侧表示，则将其相关连锁无效化，并对其赋予‘效果无效化’和‘效果发动无效化’状态直到回合结束。
function s.neop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得这张卡发动效果时所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与对象怪兽相关的连锁效果无效化，并在变里侧时重置，即同时无效其效果及相关连锁。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：本次攻击的怪兽是本卡，且自己墓地同时存在「闪刀姬-零衣」（26077387）和「闪刀姬-露世」（37351133）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前攻击的攻击怪兽是这张卡本身。
	return Duel.GetAttacker()==e:GetHandler()
		-- 检查自己墓地是否存在1张卡号为26077387的卡（「闪刀姬-零衣」）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,26077387)
		-- 检查自己墓地是否存在1张卡号为37351133的卡（「闪刀姬-露世」）。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,37351133)
end
-- ②效果的发动检查与操作信息设置函数：确认对方场上有怪兽存在，取得对方场上全部怪兽并设置操作信息为破坏这些怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上存在至少1只怪兽（aux.TRUE表示任意怪兽），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上的全部怪兽（不取对象，效果处理时确定破坏目标）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果将破坏对方场上全部怪兽，数量为sg的数量，分类为CATEGORY_DESTROY。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ②效果处理：实际处理时再次获取对方场上的全部怪兽，并用效果将其全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的全部怪兽（不取对象，在效果处理时确定破坏目标）。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以效果（REASON_EFFECT）破坏sg这些怪兽。
	Duel.Destroy(sg,REASON_EFFECT)
end
