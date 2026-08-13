--天穹覇龍ドラゴアセンション
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，这张卡的攻击力上升自己手卡数量×800的数值。场上的这张卡被对方破坏送去墓地时，若这张卡的同调召唤使用过的一组同调素材怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「天穹霸龙 龙腾」的这个效果1回合只能使用1次。
function c37910722.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，这张卡的攻击力上升自己手卡数量×800的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37910722,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c37910722.atkcon)
	e1:SetOperation(c37910722.atkop)
	c:RegisterEffect(e1)
	-- 场上的这张卡被对方破坏送去墓地时，若这张卡的同调召唤使用过的一组同调素材怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「天穹霸龙 龙腾」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37910722,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c37910722.spcon)
	e2:SetTarget(c37910722.sptg)
	e2:SetOperation(c37910722.spop)
	c:RegisterEffect(e2)
end
-- 攻击力上升效果的发动条件：这张卡同调召唤成功。
function c37910722.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 攻击力上升效果的处理：这张卡仍表侧表示且与效果关联时，根据手牌数量提升攻击力。
function c37910722.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 统计自己手卡数量，作为攻击力提升的数值依据。
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 这张卡的攻击力上升自己手卡数量×800的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 特殊召唤效果的发动条件：这张卡被对方破坏送去墓地，且破坏前在自己场上由自己控制。
function c37910722.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 筛选同调素材怪兽：必须是曾作为这张卡同调召唤的素材被送去墓地、当前在墓地且可以特殊召唤的怪兽。
function c37910722.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动时的条件检查：确认这张卡为同调召唤、墓地素材齐集、有足够怪兽区空格，且不受青眼精灵龙效果影响；满足则准备选择那组素材。
function c37910722.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=mg:GetCount()
	if chk==0 then return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 确认同调素材数量大于0，且自己场上可用的怪兽区空格不少于素材数量。
		and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and mg:FilterCount(c37910722.spfilter,nil,e,tp,c)==ct end
	-- 将那一组同调素材怪兽设为效果的对象。
	Duel.SetTargetCard(mg)
	-- 设定操作信息：宣布将要把素材怪兽特殊召唤（供连锁判定等使用）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
end
-- 特殊召唤效果处理：再次确认青眼精灵龙效果不在、对象素材仍有效且格子足够，然后逐只特殊召唤并附加效果无效化。
function c37910722.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	-- 获取发动时选择的那组同调素材怪兽。
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<mg:GetCount() then return end
	-- 若自己场上可用怪兽区空格少于要特殊召唤的数量，则处理不成功，直接终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	local tc=g:GetFirst()
	while tc do
		-- 将一只素材怪兽表侧表示特殊召唤到自己的主要怪兽区（特殊召唤步骤，以便附加无效化效果）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成整个特殊召唤步骤，确认特殊召唤成功。
	Duel.SpecialSummonComplete()
end
