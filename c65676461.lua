--No.32 海咬龍シャーク・ドレイク
-- 效果：
-- 4星怪兽×3
-- ①：1回合1次，这张卡的攻击破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。那只怪兽在对方场上攻击表示特殊召唤。这个效果特殊召唤的怪兽的攻击力下降1000。这个效果特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
function c65676461.initial_effect(c)
	-- 添加XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，这张卡的攻击破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。那只怪兽在对方场上攻击表示特殊召唤。这个效果特殊召唤的怪兽的攻击力下降1000。这个效果特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65676461,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c65676461.atcon)
	e1:SetCost(c65676461.atcost)
	e1:SetTarget(c65676461.attg)
	e1:SetOperation(c65676461.atop)
	c:RegisterEffect(e1)
end
-- 设定该卡为「No.32」怪兽
aux.xyz_number[65676461]=32
-- 检查发动条件：这张卡的攻击破坏对方怪兽送去墓地
function c65676461.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 必须是这张卡进行攻击，且在战斗状态中
	return c==Duel.GetAttacker() and c:IsRelateToBattle() and c:IsStatus(STATUS_OPPO_BATTLE)
		and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 检查并执行发动代价：把这张卡1个超量素材取除
function c65676461.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查并设置效果的目标：对方场上有空位，且被破坏的怪兽可以特殊召唤
function c65676461.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 且被破坏的怪兽可以以表侧攻击表示在对方场上特殊召唤
		and Duel.GetAttackTarget():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) end
	-- 建立被破坏的怪兽与当前效果的联系
	Duel.GetAttackTarget():CreateEffectRelation(e)
	-- 设置连锁信息，表明此效果包含特殊召唤被破坏怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,Duel.GetAttackTarget(),1,0,0)
end
-- 效果处理：将破坏的怪兽在对方场上特殊召唤，使其攻击力下降1000，并使这张卡可以再进行1次攻击
function c65676461.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被攻击（破坏）的怪兽
	local bc=Duel.GetAttackTarget()
	if not bc:IsRelateToEffect(e) then return end
	-- 尝试将该怪兽以表侧攻击表示特殊召唤到对方场上
	if Duel.SpecialSummonStep(bc,0,tp,1-tp,false,false,POS_FACEUP_ATTACK) then
		-- 这个效果特殊召唤的怪兽的攻击力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的追加攻击效果不与特殊召唤同时处理
			Duel.BreakEffect()
			-- 这个效果特殊召唤的场合，这次战斗阶段中，这张卡只再1次可以攻击。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
		end
	end
end
