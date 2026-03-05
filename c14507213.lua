--シンクロ・マテリアル
-- 效果：
-- 选择对方场上表侧表示存在的1只怪兽发动。这个回合自己同调召唤的场合，可以把选择的怪兽作为同调素材。这张卡发动的回合，自己不能进行战斗阶段。
function c14507213.initial_effect(c)
	-- 效果原文：选择对方场上表侧表示存在的1只怪兽发动。这个回合自己同调召唤的场合，可以把选择的怪兽作为同调素材。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c14507213.cost)
	e1:SetTarget(c14507213.target)
	e1:SetOperation(c14507213.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：表侧表示且可以作为同调素材的怪兽
function c14507213.filter(c)
	return c:IsFaceup() and c:IsCanBeSynchroMaterial()
end
-- 效果作用：支付费用，检查是否在本回合中已经进入过战斗阶段
function c14507213.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：若玩家在本回合中未进入过战斗阶段则满足费用条件
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 效果原文：这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面：将不能进入战斗阶段的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：设置选择目标，用于选择对方场上表侧表示的怪兽
function c14507213.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14507213.filter(chkc) end
	-- 规则层面：判断是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c14507213.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 规则层面：提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	-- 规则层面：选择对方场上表侧表示的1只满足条件的怪兽作为目标
	Duel.SelectTarget(tp,c14507213.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果作用：处理效果发动后的操作，将目标怪兽设为同调素材
function c14507213.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 效果原文：这个回合自己同调召唤的场合，可以把选择的怪兽作为同调素材。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
		e1:SetOwnerPlayer(tp)
		e1:SetValue(c14507213.matval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 规则层面：定义目标怪兽在同调召唤时可作为额外同调素材
function c14507213.matval(e,c)
	return c:IsControler(e:GetOwnerPlayer())
end
