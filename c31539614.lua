--ワクチンゲール
-- 效果：
-- 3星怪兽×2只以上
-- ①：自己·对方回合，把这张卡1个超量素材取除，以攻击力或守备力和原本数值不同的场上1只怪兽为对象才能发动。那只怪兽的攻击力·守备力变成原本数值。以自己场上的怪兽为对象发动的场合，再让那只怪兽在这个回合不会被战斗·效果破坏。
-- ②：1回合1次，自己场上有其他怪兽特殊召唤的场合，若这张卡的超量素材是3个以上则能发动。那些怪兽的攻击力上升900。
local s,id,o=GetID()
-- 注册卡片的XYZ召唤手续及两个效果：①诱发即时效果，通过取除素材使对象怪兽攻守变回原本并可能附加抗性；②诱发选发效果，在其他怪兽特殊召唤时使其攻击力上升900，并注册合并延迟事件以正确监听特殊召唤。
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续：用任意3星怪兽2只以上（最多99只）叠放进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：自己·对方回合，把这张卡1个超量素材取除，以攻击力或守备力和原本数值不同的场上1只怪兽为对象才能发动。那只怪兽的攻击力·守备力变成原本数值。以自己场上的怪兽为对象发动的场合，再让那只怪兽在这个回合不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻守变原本并破坏耐性"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上有其他怪兽特殊召唤的场合，若这张卡的超量素材是3个以上则能发动。那些怪兽的攻击力上升900。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.atkcon2)
	e2:SetTarget(s.atktg2)
	e2:SetOperation(s.atkop2)
	c:RegisterEffect(e2)
	-- 为卡片注册合并延迟事件：把同一连锁中多次发生的特殊召唤成功合并为一次，在连锁结束后统一触发自定义事件id，避免②效果被重复发动。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
end
-- 效果①的发动代价：从这张卡上取除1个超量素材；chk==0时仅检查是否有足够素材可支付。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象筛选条件：表侧表示怪兽，且当前攻击力不等于原本攻击力，或者（非连接怪兽且当前守备力不等于原本守备力）。
function s.arkfilter(c)
	return c:IsFaceup() and (not c:IsAttack(c:GetBaseAttack()) or (not c:IsType(TYPE_LINK) and not c:IsDefense(c:GetBaseDefense())))
end
-- 效果①的发动目标处理：选择1只符合条件的场上表侧怪兽作为对象；若选择的是自己场上的怪兽，则用标签标记，以便处理时附加破坏抗性。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.arkfilter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只攻击力或守备力与原本数值不同的表侧怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(s.arkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发出选择表侧表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方怪兽区选择1只满足条件的表侧怪兽作为效果对象，并登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,s.arkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 and g:GetFirst():IsControler(tp) then
		e:SetLabel(1)
	end
end
-- 效果①处理：将对象怪兽的攻击力·守备力变成原本数值；若发动时选择的是自己场上的怪兽，则再让其在本回合内不会被战斗·效果破坏。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果选择的对象怪兽（此效果只取1个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) then
		if s.arkfilter(tc) then
			-- 那只怪兽的攻击力变成原本数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(tc:GetBaseAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 那只怪兽的守备力变成原本数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(tc:GetBaseDefense())
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		if e:GetLabel()==1 then
			-- 那只怪兽在这个回合不会被战斗破坏。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(1)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			tc:RegisterEffect(e4)
		end
	end
end
-- 判定怪兽的控制者是否为自己，用于确认特殊召唤的怪兽是否属于自己场上。
function s.cfilter(c,tp)
	return c:IsControler(tp)
end
-- 效果②的发动条件：本组特殊召唤成功的怪兽中存在自己控制的其他怪兽，且不包含这张卡自身。
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 筛选效果②要处理的怪兽：控制者为自己、表侧表示、怪兽且在怪兽区，并可关联到当前连锁。
function s.atkfilter(c,e,tp)
	return c:IsControler(tp) and (not e or c:IsRelateToEffect(e))
		and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE)
end
-- 效果②的发动目标检查与登记：先确认存在符合条件的特召怪兽且这张卡超量素材在3个以上，再将那些怪兽设为效果处理对象。
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.atkfilter,1,nil,nil,tp) and e:GetHandler():GetOverlayCount()>2 end
	local g=eg:Filter(s.atkfilter,nil,nil,tp)
	-- 把本次要处理的特召怪兽组登记为当前连锁的对象，使这些怪兽与效果建立关联。
	Duel.SetTargetCard(g)
end
-- 效果②处理：遍历仍与连锁相关的特召怪兽，为每只表侧表示怪兽赋予攻击力上升900的效果。
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(Card.IsRelateToChain,nil)
	-- 遍历卡片组g中的每一张卡，依次进行处理。
	for tc in aux.Next(g) do
		if tc:IsType(TYPE_MONSTER) and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) then
			-- 那些怪兽的攻击力上升900。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(900)
			tc:RegisterEffect(e1)
		end
	end
end
