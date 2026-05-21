--シャインエルフ
-- 效果：
-- 2星怪兽×2
-- 对方对怪兽的召唤·特殊召唤成功时，把这张卡1个超量素材取除才能发动。那些怪兽的攻击力下降500。
function c97170107.initial_effect(c)
	-- 为卡片添加超量召唤手续：2星怪兽×2
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 对方对怪兽的召唤·特殊召唤成功时，把这张卡1个超量素材取除才能发动。那些怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(97170107,0))  --"攻击下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c97170107.cost)
	e1:SetTarget(c97170107.target)
	e1:SetOperation(c97170107.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤出对方场上表侧表示、攻击力大于0且与当前效果有关联的怪兽
function c97170107.filter(c,e,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:GetAttack()>0 and (not e or c:IsRelateToEffect(e))
end
-- 发动代价：把这张卡1个超量素材取除
function c97170107.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查是否存在符合条件的对方召唤·特殊召唤的怪兽，并将其设为效果处理的目标
function c97170107.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c97170107.filter,1,nil,nil,tp) end
	-- 将召唤·特殊召唤成功的怪兽群设为当前效果的处理对象
	Duel.SetTargetCard(eg)
end
-- 效果处理：使符合条件的对方召唤·特殊召唤的怪兽攻击力下降500
function c97170107.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c97170107.filter,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 那些怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
