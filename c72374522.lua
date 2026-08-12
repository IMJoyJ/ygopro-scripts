--紫毒の茨牙
-- 效果：
-- 这个卡名在规则上也当作「捕食」卡使用。
-- ①：以自己场上1只「凶饿毒融合龙」为对象才能发动。持有比那只怪兽低的攻击力的对方场上的怪兽全部破坏。那之后，以下效果可以适用。这个回合，作为对象的怪兽不能攻击。
-- ●自己手卡全部丢弃，给与对方这个效果破坏的怪兽的原本攻击力合计数值的伤害。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「凶饿毒融合龙」的卡片密码登记在该卡的关联卡片列表中
	aux.AddCodeList(c,41209827)
	-- ①：以自己场上1只「凶饿毒融合龙」为对象才能发动。持有比那只怪兽低的攻击力的对方场上的怪兽全部破坏。那之后，以下效果可以适用。这个回合，作为对象的怪兽不能攻击。●自己手卡全部丢弃，给与对方这个效果破坏的怪兽的原本攻击力合计数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「凶饿毒融合龙」，且对方场上存在攻击力比其低的怪兽
function s.cfilter(c,tp)
	return c:IsCode(41209827) and c:IsFaceup() and c:IsAttackAbove(1)
		-- 检查对方场上是否存在至少1只攻击力比该怪兽低的表侧表示怪兽
		and Duel.IsExistingMatchingCard(s.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack())
end
-- 过滤条件：对方场上表侧表示且攻击力低于指定数值的怪兽
function s.desfilter(c,atk)
	return c:IsAttackBelow(atk-1) and c:IsFaceup()
end
-- 效果发动时的目标选择与处理：检查并选择自己场上的1只「凶饿毒融合龙」作为对象，并预设破坏对方场上符合条件怪兽的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.cfilter(chkc,tp) end
	-- 步骤0：检查自己场上是否存在符合条件的可作为对象的「凶饿毒融合龙」
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只符合条件的「凶饿毒融合龙」作为效果的对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 获取对方场上所有攻击力低于所选怪兽攻击力的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,g:GetFirst():GetAttack())
	-- 设置效果处理时的操作信息为：破坏这些符合条件的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理函数：破坏符合条件的对方怪兽，并可适用丢弃全部手卡给予对方伤害的效果，最后使作为对象的怪兽本回合不能攻击
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为对象的「凶饿毒融合龙」
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() or not tc:IsFaceup() or not tc:IsType(TYPE_MONSTER) then return end
	-- 获取对方场上当前攻击力低于作为对象的怪兽攻击力的表侧表示怪兽
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
	-- 破坏这些怪兽，若成功破坏了至少1只怪兽则继续处理
	if Duel.Destroy(dg,REASON_EFFECT)~=0 then
		-- 获取本次操作中实际被破坏的怪兽卡片组
		local sg=Duel.GetOperatedGroup()
		local dam=sg:GetSum(Card.GetBaseAttack)
		-- 检查自己手卡中是否存在可以因效果丢弃的卡
		if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT+REASON_DISCARD)
			and dam>0
			-- 询问玩家是否选择适用追加伤害的效果
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否追加伤害？"
			-- 中断当前效果处理，使后续的丢手卡和伤害处理与破坏不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要丢弃的手卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 获取自己手牌中所有可以丢弃的卡片组
			local hg=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,nil,REASON_EFFECT+REASON_DISCARD)
			-- 将这些手牌全部丢弃送去墓地
			Duel.SendtoGrave(hg,REASON_EFFECT+REASON_DISCARD)
			-- 给与对方被破坏怪兽的原本攻击力合计数值的伤害
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
	-- 这个回合，作为对象的怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
