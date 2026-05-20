--ファイアウォール・ドラゴン・ダークフルード－ネオテンペスト
-- 效果：
-- 电子界族怪兽3只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，战斗阶段中对方发动的怪兽的效果无效化。
-- ②：自己·对方回合可以发动。从卡组·额外卡组把1只电子界族怪兽送去墓地。这张卡也当作和送去墓地的那只怪兽相同属性使用，攻击力上升2500。
-- ③：这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡的属性种类数量的攻击。
local s,id,o=GetID()
-- 初始化效果，注册连接召唤手续、①效果（战斗阶段无效对方怪兽效果）、②效果（送墓、变属性、加攻击力）和③效果（追加攻击次数）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：电子界族怪兽3只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),3)
	-- ①：只要这张卡在怪兽区域存在，战斗阶段中对方发动的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合可以发动。从卡组·额外卡组把1只电子界族怪兽送去墓地。这张卡也当作和送去墓地的那只怪兽相同属性使用，攻击力上升2500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	-- 限制该效果在伤害步骤中只能在伤害计算前发动。
	e2:SetCondition(aux.dscon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡在同1次的战斗阶段中可以向怪兽作出最多有这张卡的属性种类数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e3:SetValue(s.eaval)
	c:RegisterEffect(e3)
end
-- ①效果的执行操作：在战斗阶段中，若对方发动了怪兽的效果，则将该效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段。
	local ph=Duel.GetCurrentPhase()
	if re:IsActiveType(TYPE_MONSTER) and rp==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE then
		-- 使该连锁的效果无效。
		Duel.NegateEffect(ev)
	end
end
-- 过滤卡组或额外卡组中可以送去墓地的电子界族怪兽。
function s.tgfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToGrave()
end
-- ②效果的发动准备：检查卡组或额外卡组是否存在可送墓的电子界族怪兽，并设置送去墓地的操作信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足过滤条件的电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil) end
	-- 设置将1张卡从卡组或额外卡组送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ②效果的执行操作：将1只电子界族怪兽送去墓地，并使这张卡获得该怪兽的属性且攻击力上升2500。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组或额外卡组选择1只满足过滤条件的电子界族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功将选择的怪兽因效果送去墓地且该怪兽确实存在于墓地。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡也当作和送去墓地的那只怪兽相同属性使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_ATTRIBUTE)
		e1:SetValue(tc:GetAttribute())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(2500)
		c:RegisterEffect(e2)
	end
end
-- 计算这张卡拥有的属性种类数量，并返回追加攻击的次数（属性种类数减1）。
function s.eaval(e,c)
	local ct=0
	local attr=1
	for i=1,7 do
		if e:GetHandler():IsAttribute(attr) then ct=ct+1 end
		attr=attr<<1
	end
	return ct-1
end
