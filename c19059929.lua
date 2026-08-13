--炎舞－「玉衝」
-- 效果：
-- 这张卡的发动时，选择对方场上盖放的1张魔法·陷阱卡。对方不能对应这张卡的发动把选择的卡发动。只要这张卡在场上存在，选择的卡不能发动。此外，只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升100。
function c19059929.initial_effect(c)
	-- 这张卡的发动时，选择对方场上盖放的1张魔法·陷阱卡。对方不能对应这张卡的发动把选择的卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c19059929.target)
	e1:SetOperation(c19059929.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上的兽战士族怪兽的攻击力上升100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置攻击力上升效果的适用对象筛选函数：只对自己场上的兽战士族怪兽生效，使其攻击力上升100。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_BEASTWARRIOR))
	e2:SetValue(100)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，选择的卡不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_TARGET)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
end
-- 效果发动时的目标处理函数：判断能否发动，选择对方场上1张里侧表示的魔法·陷阱卡作为对象，并设置连锁限制，使对方不能对应这张卡的发动而连锁发动被选中的卡。
function c19059929.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_SZONE) and chkc:IsFacedown() end
	-- 在效果发动合法性检查阶段（chk==0），确认对方场上是否存在至少1张里侧表示的魔法·陷阱卡可以作为对象，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_SZONE,1,e:GetHandler()) end
	-- 向当前玩家显示选择提示信息，提示其选择对方场上盖放的1张魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(19059929,0))  --"请选择对方场上盖放的1张魔法·陷阱卡"
	-- 让玩家从对方场上里侧表示的魔法·陷阱卡中选择1张，并将其登记为这张卡发动时的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_SZONE,1,1,e:GetHandler())
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 为本次效果发动设置连锁限制，限制对方不能连锁发动被选择的这张卡（即不能以该卡作为连锁来发动其效果）。
		Duel.SetChainLimit(c19059929.limit(g:GetFirst()))
	end
end
-- 返回连锁限制判定闭包：当试图连锁的效果的Handler不是被选择的那张卡时返回true（允许连锁），否则返回false（禁止连锁），以实现“对方不能对应这张卡的发动把选择的卡发动”。
function c19059929.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
-- 效果处理时，若这张卡仍在场上且与效果关联，并且被选择的对象卡仍为里侧表示且与效果关联，则将被选择的那张卡设为这张卡的永续对象，为后续“选择的卡不能发动”的持续效果提供对象。
function c19059929.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取这张卡发动时选择的对象卡（即对方场上里侧表示的那张魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
	end
end
