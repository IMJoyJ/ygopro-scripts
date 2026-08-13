--シンクロ・マテリアル
-- 效果：
-- 选择对方场上表侧表示存在的1只怪兽发动。这个回合自己同调召唤的场合，可以把选择的怪兽作为同调素材。这张卡发动的回合，自己不能进行战斗阶段。
function c14507213.initial_effect(c)
	-- 选择对方场上表侧表示存在的1只怪兽发动。这个回合自己同调召唤的场合，可以把选择的怪兽作为同调素材。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c14507213.cost)
	e1:SetTarget(c14507213.target)
	e1:SetOperation(c14507213.activate)
	c:RegisterEffect(e1)
end
-- 定义选择对象的筛选条件：怪兽必须是表侧表示，并且可以作为同调素材使用。
function c14507213.filter(c)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial()
end
-- 发动代价处理：检查本回合自己尚未进行过战斗阶段，然后给自己附加“本回合不能进入战斗阶段”的誓约效果。
function c14507213.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件，确认本回合自己进入战斗阶段的次数为0（即尚未进行过战斗阶段）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 选择对方场上表侧表示存在的1只怪兽发动。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能进入战斗阶段”的效果注册给发动玩家，使其在本回合内无法进入战斗阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 对象选择处理：确认存在可选对象后，提示玩家从对方场上选择1只表侧表示且可作为同调素材的怪兽，并将其设为效果对象。
function c14507213.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14507213.filter(chkc) end
	-- 检查对方场上是否存在至少1只满足筛选条件的表侧表示怪兽，以保证效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c14507213.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向发动玩家显示“请选择表侧表示的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家从对方场上选择1只符合条件的表侧表示怪兽，并将其登记为这张卡的效果对象。
	Duel.SelectTarget(tp,c14507213.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理时取得选择的对象，若对象仍与效果关联，则给它赋予“本回合可以作为发动玩家的同调素材”的效果，持续到回合结束。
function c14507213.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这张卡发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 这个回合自己同调召唤的场合，可以把选择的怪兽作为同调素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
		e1:SetOwnerPlayer(tp)
		e1:SetValue(c14507213.matval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 作为同调素材资格的判定：要求该怪兽的控制者是效果拥有者，即只有发动这张卡的玩家在本次同调召唤中可以使用该怪兽作为素材。
function c14507213.matval(e,c)
	return c:IsControler(e:GetOwnerPlayer())
end
