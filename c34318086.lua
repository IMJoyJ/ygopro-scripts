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
-- 效果①解放代价的过滤函数：必须是「魔术少女」字段怪兽，且不能是「柠檬魔术少女」自身。
function c34318086.cfilter(c)
	return c:IsSetCard(0x20a2) and not c:IsCode(34318086)
end
-- 效果①的代价处理函数：从自己场上选择并解放1只「柠檬魔术少女」以外的「魔术少女」怪兽作为发动代价。
function c34318086.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①发动条件检查：确认自己场上是否存在至少1只可解放的「魔术少女」怪兽（非柠檬魔术少女）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c34318086.cfilter,1,nil) end
	-- 选择1只满足条件的「魔术少女」怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c34318086.cfilter,1,1,nil)
	-- 将选择的怪兽解放，作为此次效果发动的代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义效果①检索目标的过滤函数：必须是魔法师族怪兽，且可以被加入手卡。
function c34318086.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
-- 效果①的发动时判定：确认卡组中存在符合条件的魔法师族怪兽，并设定将1张卡加入手卡的操作信息。
function c34318086.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①的发动条件：卡组中存在至少1只魔法师族怪兽且能被加入手卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c34318086.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时将1张卡从卡组加入手卡的操作信息（回手牌、检索卡组类别）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的解决处理：从卡组选择1只魔法师族怪兽加入手牌，并让对方确认。
function c34318086.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示，并让玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的魔法师族怪兽。
	local g=Duel.SelectMatchingCard(tp,c34318086.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的那张卡，以确认效果处理。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义效果②特殊召唤目标的过滤函数：必须是魔法师族怪兽，且可以被特殊召唤。
function c34318086.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：自己主要怪兽区有空位，且手牌中存在可以特殊召唤的魔法师族怪兽。
function c34318086.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌中存在至少1只满足特殊召唤条件的魔法师族怪兽。
		and Duel.IsExistingMatchingCard(c34318086.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时要将1张手牌怪兽特殊召唤的操作信息（特殊召唤类别）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的解决处理：从手牌选1只魔法师族怪兽特殊召唤，对其附加效果无效化；若条件满足，将攻击对象转移为那只怪兽，并将攻击怪兽的攻击力减半。
function c34318086.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认自己场上仍有可用的主要怪兽区空位（若已被占用则结束处理）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌选择1只可特殊召唤的魔法师族怪兽。
	local g=Duel.SelectMatchingCard(tp,c34318086.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选到了目标且特殊召唤步骤成功，则继续处理；这里开始进行特殊召唤（作为连锁处理的一部分）。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果无效（对应效果②原文“从手卡把1只魔法师族怪兽效果无效特殊召唤”中的“效果无效”）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效（对应效果②原文“从手卡把1只魔法师族怪兽效果无效特殊召唤”中的“效果无效”）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成一整套特殊召唤处理，确定特殊召唤成功。
		Duel.SpecialSummonComplete()
		-- 获取当前进行攻击的怪兽（即被转移攻击对象的原攻击怪兽）。
		local at=Duel.GetAttacker()
		-- 若攻击怪兽存在、不免疫此效果，且成功将攻击对象转移为刚特殊召唤的怪兽，则继续执行攻击力减半处理。
		if at and not at:IsImmuneToEffect(e) and Duel.ChangeAttackTarget(tc) then
			-- 中断当前效果处理，使之后的攻击力减半处理视为另一个独立的效果处理（避免错过时点）。
			Duel.BreakEffect()
			-- 攻击怪兽的攻击力变成一半。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK_FINAL)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			e3:SetValue(math.ceil(at:GetAttack()/2))
			at:RegisterEffect(e3)
		end
	end
end
