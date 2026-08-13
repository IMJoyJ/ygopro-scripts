--怒髪天衝セイバーザウルス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。自己的手卡·场上（表侧表示）1只恐龙族怪兽破坏。那之后，可以把场上1只怪兽的表示形式变更。
-- ②：其他的自己的恐龙族怪兽进行战斗的伤害步骤开始时才能发动。这张卡破坏，那只恐龙族怪兽的攻击力直到战斗阶段结束时上升2000。
local s,id,o=GetID()
-- 为剑角龙注册XYZ召唤手续（4星怪兽×2叠放），并注册①起动效果和②诱发效果，②与同名卡的①效果各自1回合1次。
function s.initial_effect(c)
	-- 添加XYZ召唤手续：将等级4的任意2只怪兽叠放作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。自己的手卡·场上（表侧表示）1只恐龙族怪兽破坏。那之后，可以把场上1只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：其他的自己的恐龙族怪兽进行战斗的伤害步骤开始时才能发动。这张卡破坏，那只恐龙族怪兽的攻击力直到战斗阶段结束时上升2000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏并上升攻击力"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 支付代价函数：检查这张卡是否有1个超量素材可移除，若有则移除1个超量素材作为发动代价。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 破坏对象过滤条件：该怪兽为表侧表示（含手牌）且种族为恐龙族。
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_DINOSAUR)
end
-- 效果发动目标判定：确认自己手牌·场上存在符合条件的恐龙族怪兽，并设置破坏效果的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：只有自己手牌·场上至少存在1只符合条件的恐龙族怪兽时才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：本次效果将破坏1张自己手牌·场上（表侧表示）的恐龙族怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
-- 效果处理函数：选择并破坏1只自己手牌·场上的恐龙族怪兽；若破坏成功且场上有可变更表示形式的怪兽，询问玩家是否变更，然后选择1只怪兽切换其表示形式。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手牌·场上选择1张符合条件的恐龙族怪兽作为破坏对象。
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if dg:GetCount()>0 then
		-- 显示所选卡片的选中动画，并将其记录为被选择的卡片。
		Duel.HintSelection(dg)
		-- 判断破坏是否成功；若破坏成功且场上存在可以变更表示形式的怪兽，则继续后续处理。
		if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			-- 询问玩家是否要变更表示形式，由玩家决定是否执行变更处理。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
			-- 向玩家显示“请选择要改变表示形式的怪兽”的选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 从双方场上选择1只可以变更表示形式的怪兽，并将其设为效果对象。
			local cg=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			if cg:GetCount()>0 then
				-- 中断当前效果处理，使变更表示形式的处理与破坏处理分开结算，避免影响时点。
				Duel.BreakEffect()
				-- 显示所选怪兽的选中动画，并记录为被选择的对象。
				Duel.HintSelection(cg)
				-- 将所选怪兽的表示形式变更为相反的形式（表侧攻击变表侧守备，表侧守备变表侧攻击）。
				Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end
-- ②效果发动条件：伤害步骤开始时，若有其他自己的恐龙族怪兽正在进行战斗，记录该怪兽并返回true。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if not a:IsControler(tp) then a,d=d,a end
	if a and a~=e:GetHandler() and a:IsFaceup() and a:IsControler(tp) and a:IsRace(RACE_DINOSAUR) and a:IsRelateToBattle() then
		e:SetLabelObject(a)
		return true
	end
	return false
end
-- ②效果目标函数：本效果不需要取对象，发动时直接允许，并设置破坏这张卡的操作信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次效果将破坏这张剑角龙自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ②效果处理函数：破坏这张卡；若破坏成功且记录的战斗怪兽仍与战斗相关并满足恐龙族条件，则给予其攻击力上升2000的效果直到战斗阶段结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=e:GetLabelObject()
	-- 检查这张卡仍与效果关联后执行破坏；只有破坏成功才继续给那只恐龙族怪兽加攻击力。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		if not a or not a:IsRelateToBattle() then return end
		if a:IsFaceup() and a:IsRace(RACE_DINOSAUR) and a:IsType(TYPE_MONSTER) then
			-- 那只恐龙族怪兽的攻击力直到战斗阶段结束时上升2000。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			a:RegisterEffect(e1)
		end
	end
end
