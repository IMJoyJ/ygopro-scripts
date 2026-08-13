--ソードハンター
-- 效果：
-- 这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
function c51345461.initial_effect(c)
	-- 这张卡战斗破坏怪兽的战斗阶段结束时，墓地存在的那些怪兽作为攻击力上升200点的装备卡装备在这张卡上。
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
-- 过滤符合条件的怪兽：被战斗破坏、且是被这张卡战斗破坏、且在这个回合被破坏、且未被宣言禁止的卡。
function c51345461.filter(c,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid and not c:IsForbidden()
end
-- 作为诱发必发效果的发动判定：无特殊发动条件，直接允许发动；之后检索符合条件的怪兽并登记装备操作信息。
function c51345461.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索本回合被这张卡战斗破坏并存在于双方墓地的怪兽（排除禁止卡），作为可能被装备的对象集合。
	local g=Duel.GetMatchingGroup(c51345461.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e:GetHandler(),Duel.GetTurnCount())
	-- 登记本次连锁的操作信息：将检索到的那些怪兽作为装备卡使用，数量为g中的卡数，完成装备类别的宣告。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 效果处理：如果这张卡仍与效果关联且表侧表示，且魔陷区空格充足，则将符合条件的墓地怪兽全部装备给这张卡，并赋予装备限制与攻击力上升效果；若空间不足则不处理。
function c51345461.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得此卡控制者可用的魔陷区空格数量，用于判断能否把那些怪兽装备到魔陷区。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 效果处理时重新检索本回合被这张卡战斗破坏并存在于墓地的怪兽（排除禁止卡），避免发动时与处理时情况不一致。
	local g=Duel.GetMatchingGroup(c51345461.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e:GetHandler(),Duel.GetTurnCount())
	if g:GetCount()==0 then return end
	if g:GetCount()>ft then return end
	local tc=g:GetFirst()
	while tc do
		-- 把怪兽tc作为装备卡装备给这张卡c，up=false表示保持原表示形式，is_step=true表示这是分解装备步骤，后续需要调用Duel.EquipComplete完成装备。
		Duel.Equip(tp,tc,c,false,true)
		-- 装备在这张卡上。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c51345461.eqlimit)
		tc:RegisterEffect(e1)
		-- 攻击力上升200点。
		local e2=Effect.CreateEffect(tc)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(200)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 结束分解装备过程，触发装备成功时点，使装备动作完整生效。
	Duel.EquipComplete()
end
-- 装备限制判定：只有这张卡（猎剑猎人）才能成为这些装备卡的装备对象，即效果持有者与装备对象必须相同。
function c51345461.eqlimit(e,c)
	return e:GetOwner()==c
end
