--氷結界の還零龍 トリシューラ
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡同调召唤时才能发动。对方场上最多3张卡除外。
-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从自己的额外卡组·墓地把1只「冰结界之龙 三叉龙」攻击力变成3300特殊召唤。对方场上有表侧表示怪兽存在的场合，再让那些怪兽攻击力变成一半，效果无效化。
function c70980824.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽2只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时才能发动。对方场上最多3张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70980824,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c70980824.remcon)
	e1:SetTarget(c70980824.remtg)
	e1:SetOperation(c70980824.remop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从自己的额外卡组·墓地把1只「冰结界之龙 三叉龙」攻击力变成3300特殊召唤。对方场上有表侧表示怪兽存在的场合，再让那些怪兽攻击力变成一半，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70980824,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,70980824)
	e2:SetCondition(c70980824.spcon)
	e2:SetTarget(c70980824.sptg)
	e2:SetOperation(c70980824.spop)
	c:RegisterEffect(e2)
end
-- 检查发动条件：这张卡是否成功进行了同调召唤。
function c70980824.remcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动准备：检查对方场上是否存在可除外的卡，并设置除外的操作信息。
function c70980824.remtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张可以被除外的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 设置连锁中的操作信息：将对方场上的卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD)
end
-- 效果①的处理：让玩家选择对方场上最多3张卡并除外。
function c70980824.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有可以被除外的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	if #g>0 then
		-- 提示玩家选择要除外的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(tp,1,3,nil)
		-- 在场上显示被选择卡片的视觉效果。
		Duel.HintSelection(sg)
		-- 将选择的卡片以表侧表示因效果除外。
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 检查发动条件：同调召唤的这张卡在怪兽区域因对方被破坏。
function c70980824.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsPreviousLocation(LOCATION_MZONE) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤条件：检查额外卡组或墓地中是否存在可以特殊召唤的「冰结界之龙 三叉龙」，并判断是否有可用的怪兽区域。
function c70980824.spfilter(c,e,tp)
	if not (c:IsCode(52687916) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查从额外卡组特殊召唤该怪兽时，额外怪兽区域是否有空位。
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查从墓地特殊召唤该怪兽时，主怪兽区域是否有空位。
		return Duel.GetMZoneCount(tp)>0
	end
end
-- 效果②的发动准备：检查自己额外卡组或墓地是否存在可特殊召唤的「冰结界之龙 三叉龙」，并设置特殊召唤的操作信息。
function c70980824.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的额外卡组或墓地是否存在满足特殊召唤条件的「冰结界之龙 三叉龙」。
	if chk==0 then return Duel.IsExistingMatchingCard(c70980824.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从额外卡组或墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果②的处理：特殊召唤「冰结界之龙 三叉龙」并将其攻击力变成3300，若对方场上有表侧表示怪兽，则再将其攻击力减半且效果无效。
function c70980824.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组或墓地选择1只满足条件的「冰结界之龙 三叉龙」（受王家长眠之谷影响）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c70980824.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选择的怪兽以表侧攻击表示进行特殊召唤的单步处理。
		local res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		if res then
			-- 攻击力变成3300
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(3300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤的最终处理。
		Duel.SpecialSummonComplete()
		-- 获取对方场上所有表侧表示的怪兽。
		local dg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if res and #dg>0 then
			-- 中断当前效果处理，使后续的攻击力减半和效果无效化处理视为不同时进行。
			Duel.BreakEffect()
			local dc=dg:GetFirst()
			while dc do
				local atk=dc:GetAttack()
				-- 那些怪兽攻击力变成一半
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_SET_ATTACK_FINAL)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				e2:SetValue(math.ceil(atk/2))
				dc:RegisterEffect(e2)
				-- 使与目标怪兽相关的连锁中已发动的效果无效化。
				Duel.NegateRelatedChain(dc,RESET_TURN_SET)
				-- 效果无效化
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_DISABLE)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e3)
				-- 效果无效化
				local e4=Effect.CreateEffect(c)
				e4:SetType(EFFECT_TYPE_SINGLE)
				e4:SetCode(EFFECT_DISABLE_EFFECT)
				e4:SetValue(RESET_TURN_SET)
				e4:SetReset(RESET_EVENT+RESETS_STANDARD)
				dc:RegisterEffect(e4)
				dc=dg:GetNext()
			end
		end
	end
end
