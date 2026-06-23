--レモン・マジシャン・ガール
-- 效果：
-- ①：1回合1次，把「柠檬魔术少女」以外的自己场上1只「魔术少女」怪兽解放才能发动。从卡组把1只魔法师族怪兽加入手卡。
-- ②：1回合1次，这张卡被选择作为攻击对象的场合才能发动。从手卡把1只魔法师族怪兽效果无效特殊召唤。那之后，攻击对象转移为那只怪兽，攻击怪兽的攻击力变成一半。
function c34318086.initial_effect(c)
	-- ①：1回合1次，把「柠檬魔术少女」以外的自己场上1只「魔术少女」怪兽解放才能发动。从卡组把1只魔法师族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34318086,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c34318086.thcost)
	e1:SetTarget(c34318086.thtg)
	e1:SetOperation(c34318086.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡被选择作为攻击对象的场合才能发动。从手卡把1只魔法师族怪兽效果无效特殊召唤。那之后，攻击对象转移为那只怪兽，攻击怪兽的攻击力变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34318086,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c34318086.sptg)
	e2:SetOperation(c34318086.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为「魔术少女」卡组且不是柠檬魔术少女本身
function c34318086.cfilter(c)
	return c:IsSetCard(0x20a2) and not c:IsCode(34318086)
end
-- 效果处理时检查是否满足解放条件并选择解放对象
function c34318086.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34318086.cfilter,1,nil) end
	-- 选择满足条件的1张怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c34318086.cfilter,1,1,nil)
	-- 将选中的怪兽解放作为效果的代价
	Duel.Release(g,REASON_COST)
end
-- 过滤函数，用于判断是否为魔法师族且能加入手牌
function c34318086.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息，准备检索魔法师族怪兽
function c34318086.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34318086.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定要检索的卡为魔法师族怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时选择并检索魔法师族怪兽加入手牌
function c34318086.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c34318086.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法师族怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，用于判断是否为魔法师族且能特殊召唤
function c34318086.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果处理时的连锁操作信息，准备特殊召唤魔法师族怪兽
function c34318086.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c34318086.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定要特殊召唤的卡为魔法师族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理时选择并特殊召唤魔法师族怪兽
function c34318086.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查场上是否有空位进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张魔法师族怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c34318086.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 尝试特殊召唤选中的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 获取当前攻击的怪兽
		local at=Duel.GetAttacker()
		-- 判断是否可以转移攻击对象并进行转移
		if at and not at:IsImmuneToEffect(e) and Duel.ChangeAttackTarget(tc) then
			-- 中断当前效果处理，使后续效果错时处理
			Duel.BreakEffect()
			-- 将攻击怪兽的攻击力变为一半
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(math.ceil(at:GetAttack()/2))
			at:RegisterEffect(e3)
		end
	end
end
