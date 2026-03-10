--ソードハンター
-- 效果：
-- 这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
function c51345461.initial_effect(c)
	-- 效果原文内容：这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51345461,0))  --"装备"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51345461.eqtg)
	e1:SetOperation(c51345461.eqop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：战斗破坏且为该卡造成的破坏，并且在当前回合被破坏，且未被禁止的怪兽。
function c51345461.filter(c,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid and not c:IsForbidden()
end
-- 效果作用：设置连锁操作信息，将符合条件的墓地怪兽作为装备卡进行装备处理。
function c51345461.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：获取满足条件的墓地怪兽组（战斗破坏且为该卡造成的破坏，并且在当前回合被破坏）。
	local g=Duel.GetMatchingGroup(c51345461.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e:GetHandler(),Duel.GetTurnCount())
	-- 效果作用：设置当前处理的连锁的操作信息，指定要装备的卡片数量和类型为CATEGORY_EQUIP。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 效果原文内容：这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
function c51345461.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前玩家在魔法陷阱区域可用的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 效果作用：再次获取满足条件的墓地怪兽组（战斗破坏且为该卡造成的破坏，并且在当前回合被破坏）。
	local g=Duel.GetMatchingGroup(c51345461.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e:GetHandler(),Duel.GetTurnCount())
	if g:GetCount()==0 then return end
	if g:GetCount()>ft then return end
	local tc=g:GetFirst()
	while tc do
		-- 效果作用：将目标怪兽作为装备卡装备给此卡，保持原表示形式并分步执行。
		Duel.Equip(tp,tc,c,false,true)
		-- 效果原文内容：这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c51345461.eqlimit)
		tc:RegisterEffect(e1)
		-- 效果原文内容：这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(200)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 效果作用：完成装备过程的处理，触发装备时点。
	Duel.EquipComplete()
end
-- 效果作用：限制该装备卡只能被此卡装备
function c51345461.eqlimit(e,c)
	return e:GetOwner()==c
end
