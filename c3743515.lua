--怒髪天衝セイバーザウルス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。自己的手卡·场上（表侧表示）1只恐龙族怪兽破坏。那之后，可以把场上1只怪兽的表示形式变更。
-- ②：其他的自己的恐龙族怪兽进行战斗的伤害步骤开始时才能发动。这张卡破坏，那只恐龙族怪兽的攻击力直到战斗阶段结束时上升2000。
local s,id,o=GetID()
-- 初始化效果，添加XYZ召唤手续并注册两个效果
function s.initial_effect(c)
	-- 为该卡添加XYZ召唤手续，使用4星怪兽叠放2只
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
-- 支付效果代价，移除1个超量素材
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，筛选表侧表示的恐龙族怪兽
function s.desfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_DINOSAUR)
end
-- 设置效果目标，检查是否存在满足条件的怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，指定将要破坏的卡的位置
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
end
-- 处理效果的发动，选择破坏对象并询问是否改变表示形式
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的卡作为破坏对象
	local dg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	if dg:GetCount()>0 then
		-- 显示被选为对象的卡
		Duel.HintSelection(dg)
		-- 破坏选定的卡并检查是否可以改变表示形式
		if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
			-- 询问玩家是否改变表示形式
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
			-- 提示玩家选择要改变表示形式的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
			-- 选择目标怪兽
			local cg=Duel.SelectTarget(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			if cg:GetCount()>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 显示被选为对象的卡
				Duel.HintSelection(cg)
				-- 将目标怪兽变为表侧守备表示
				Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end
-- 判断是否满足效果发动条件，即攻击怪兽为己方恐龙族怪兽
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前攻击目标
	local d=Duel.GetAttackTarget()
	if not a:IsControler(tp) then a,d=d,a end
	if a and a~=e:GetHandler() and a:IsFaceup() and a:IsControler(tp) and a:IsRace(RACE_DINOSAUR) and a:IsRelateToBattle() then
		e:SetLabelObject(a)
		return true
	end
	return false
end
-- 设置效果目标，指定将要破坏的卡
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，指定将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 处理效果的发动，破坏自身并使攻击怪兽攻击力上升
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=e:GetLabelObject()
	-- 确认自身和攻击怪兽有效果关联并破坏自身
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		if not a or not a:IsRelateToBattle() then return end
		if a:IsFaceup() and a:IsRace(RACE_DINOSAUR) and a:IsType(TYPE_MONSTER) then
			-- 为攻击怪兽增加2000攻击力，持续到战斗阶段结束
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(2000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
			a:RegisterEffect(e1)
		end
	end
end
