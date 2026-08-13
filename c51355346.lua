--爆炎集合体 ガイヤ・ソウル
-- 效果：
-- 可以把自己场上最多2只炎族怪兽做祭品。因这个效果使用祭品的场合，这张卡的攻击力上升祭品数量×1000的数值。这张卡攻击守备表示怪兽时，若这张卡的攻击力超过守备表示怪兽的守备力，给与对方基本分那个数值的战斗伤害。结束阶段时这张卡破坏。
function c51355346.initial_effect(c)
	-- 可以把自己场上最多2只炎族怪兽做祭品。因这个效果使用祭品的场合，这张卡的攻击力上升祭品数量×1000的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51355346,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c51355346.atkcost)
	e1:SetOperation(c51355346.atkop)
	c:RegisterEffect(e1)
	-- 这张卡攻击守备表示怪兽时，若这张卡的攻击力超过守备表示怪兽的守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- 结束阶段时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51355346,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetTarget(c51355346.destg)
	e3:SetOperation(c51355346.desop)
	c:RegisterEffect(e3)
end
-- 设置起动效果发动所需的代价：从自己场上选择1~2只炎族怪兽解放，并把解放数量存入效果标签，作为后续攻击力上升幅度的依据。
function c51355346.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前检查自己场上是否存在至少1只炎族怪兽可以解放，以此判断效果能否发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_PYRO) end
	-- 由玩家从自己场上选择1~2只炎族怪兽作为发动代价（不选择效果持有者本身）。
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,2,e:GetHandler(),RACE_PYRO)
	-- 将选择的怪兽作为代价解放，因为使用REASON_COST，所以不会受“不被效果解放”等效果影响。
	Duel.Release(g,REASON_COST)
	e:SetLabel(g:GetCount())
end
-- 处理攻击力上升效果：若这张卡仍表侧表示且与效果关联，则赋予其攻击力上升效果，上升数值为之前记录的解祭品数量×1000。
function c51355346.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 因这个效果使用祭品的场合，这张卡的攻击力上升祭品数量×1000的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(e:GetLabel()*1000)
		c:RegisterEffect(e1)
	end
end
-- 结束阶段破坏效果的发动条件：结束阶段必定发动，并设置将这张卡自身破坏的操作信息。
function c51355346.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁将破坏的卡为这张卡自身，数量为1，供其他卡（如星尘龙等）进行效果发动检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 处理结束阶段自坏效果：若这张卡仍与效果关联且表侧表示，则将其破坏。
function c51355346.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 以效果破坏的方式将这张卡破坏，原因使用REASON_EFFECT。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
