--至鋼の玉 ルーベサフィルス
-- 效果：
-- 9星怪兽×2只以上
-- ①：这张卡得到这张卡作为超量素材中的怪兽属性的以下效果。
-- ●炎：这张卡向持有比这张卡高的攻击力的怪兽攻击的攻击宣言时才能发动。这张卡的攻击力直到那次伤害步骤结束时变成2倍。
-- ●水：对方回合1次，以自己场上1张卡为对象才能发动。这个回合，那张卡为对象由对方发动的效果无效化。
-- ②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包括XYZ召唤手续、炎属性素材赋予的攻击力翻倍效果、水属性素材赋予的对象效果无效化效果，以及代替破坏效果。
function s.initial_effect(c)
	-- 添加XYZ召唤手续：9星怪兽2只以上（最多99只）。
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ●炎：这张卡向持有比这张卡高的攻击力的怪兽攻击的攻击宣言时才能发动。这张卡的攻击力直到那次伤害步骤结束时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力翻倍"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ●水：对方回合1次，以自己场上1张卡为对象才能发动。这个回合，那张卡为对象由对方发动的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"以自己的卡为对象"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetTarget(s.dreptg)
	e3:SetOperation(s.drepop)
	c:RegisterEffect(e3)
end
-- 过滤超量素材中特定属性怪兽的辅助函数。
function s.ofilter(c,attr)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(attr)
end
-- 炎属性效果的发动条件：攻击对象存在、表侧表示且攻击力比自身高，并且自身拥有炎属性的超量素材。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击对象（被攻击的怪兽）。
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsFaceup() and bc:GetAttack()>c:GetAttack()
		and c:GetOverlayGroup():IsExists(s.ofilter,1,nil,ATTRIBUTE_FIRE)
end
-- 炎属性效果的处理：若自身表侧表示存在，则直到伤害步骤结束时攻击力变成2倍。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到那次伤害步骤结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
	end
end
-- 水属性效果的发动条件：自身拥有水属性的超量素材，且当前为对方回合。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayGroup():IsExists(s.ofilter,1,nil,ATTRIBUTE_WATER)
		-- 判定当前回合玩家是否为对方。
		and Duel.GetTurnPlayer()==1-tp
end
-- 水属性效果的靶向/发动准备：选择自己场上1张卡作为对象。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 判定自己场上是否存在可以作为对象的目标卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1张卡作为对象。
	Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- 水属性效果的处理：给对象卡片添加标记，并注册一个全局的连锁处理效果，用于在对方效果处理时将其无效化。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))  --"「至钢之玉 红青玉」效果适用中"
		-- 这个回合，那张卡为对象由对方发动的效果无效化。②：这张卡被破坏的场合，可以作为代替把这张卡1个超量素材取除。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetOperation(s.disop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		-- 将用于无效化效果的全局连续效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出作为无效化对象且带有特定标记的卡片。
function s.disfilter(c,e,tp)
	return c==e:GetLabelObject() and c:GetFlagEffect(id)>0
end
-- 连锁处理时的操作：如果对方发动的效果以被保护的卡为对象，则将该效果无效化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	-- 如果是自己发动的效果，或者该连锁的效果无法被无效，则不进行处理。
	if ep==tp or not Duel.IsChainDisablable(ev) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前处理的连锁所指向的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 如果对象卡片组中包含被保护的卡，则无效化该连锁的效果。
	if g and g:IsExists(s.disfilter,1,nil,e,tp) then Duel.NegateEffect(ev,true) end
end
-- 代替破坏效果的条件与选择：判定自身是否因战斗或效果被破坏，且自身拥有可取除的超量素材。
function s.dreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的处理：取除这张卡的1个超量素材。
function s.drepop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
