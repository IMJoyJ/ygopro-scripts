--RR－ライズ・ファルコン
-- 效果：
-- 鸟兽族4星怪兽×3
-- ①：这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1只特殊召唤的怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的攻击力数值。
function c73887236.initial_effect(c)
	-- 添加超量召唤手续：鸟兽族4星怪兽×3
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WINDBEAST),4,3)
	c:EnableReviveLimit()
	-- ①：这张卡可以向特殊召唤的对方怪兽全部各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(c73887236.atkfilter)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以对方场上1只特殊召唤的怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73887236,0))  --"攻击上升"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c73887236.cost)
	e2:SetTarget(c73887236.target)
	e2:SetOperation(c73887236.operation)
	c:RegisterEffect(e2)
end
-- 攻击目标过滤：判定怪兽是否为特殊召唤
function c73887236.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果②的代价：检查并取除这张卡的1个超量素材
function c73887236.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的对象过滤：对方场上表侧表示、攻击力大于0且是特殊召唤的怪兽
function c73887236.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果②的靶向：选择对方场上1只表侧表示的特殊召唤的怪兽作为对象
function c73887236.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c73887236.filter(chkc) end
	-- 在发动时，检查对方场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c73887236.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c73887236.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果②的处理：使这张卡的攻击力上升作为对象的怪兽的攻击力数值
function c73887236.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升作为对象的怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
