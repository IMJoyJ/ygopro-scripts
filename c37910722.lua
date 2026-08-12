--天穹覇龍ドラゴアセンション
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡同调召唤成功时，这张卡的攻击力上升自己手卡数量×800的数值。场上的这张卡被对方破坏送去墓地时，若这张卡的同调召唤使用过的一组同调素材怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「天穹霸龙 龙腾」的这个效果1回合只能使用1次。
function c37910722.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
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
	-- 场上的这张卡被对方破坏送去墓地时，若这张卡的同调召唤使用过的一组同调素材怪兽在自己墓地齐集，可以把那一组特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
-- 判断此卡是否为同调召唤成功
function c37910722.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 若此卡在场上正面表示存在且效果适用，则将此卡攻击力提升手卡数量×800
function c37910722.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取当前玩家手牌数量
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		-- 将此卡攻击力增加手牌数量×800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断此卡是否为对方破坏送入墓地且为己方控制
function c37910722.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_DESTROY)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤墓地中的同调素材怪兽，确保其为同调召唤所用且可特殊召唤
function c37910722.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检测是否满足特殊召唤条件，包括：同调召唤成功、未受青眼精灵龙影响、有足够墓地怪兽、场上空位足够
function c37910722.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	local ct=mg:GetCount()
	if chk==0 then return c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上是否有足够空位
		and ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct
		and mg:FilterCount(c37910722.spfilter,nil,e,tp,c)==ct end
	-- 设置连锁目标为同调素材怪兽
	Duel.SetTargetCard(mg)
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,ct,0,0)
end
-- 处理特殊召唤操作，包括检测青眼精灵龙影响、确认目标卡、检查空位、特殊召唤并使召唤的怪兽效果无效
function c37910722.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local c=e:GetHandler()
	-- 获取连锁中设置的目标卡组
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<mg:GetCount() then return end
	-- 检测场上是否有足够空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<g:GetCount() then return end
	local tc=g:GetFirst()
	while tc do
		-- 特殊召唤一张怪兽
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的怪兽效果无效
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
		tc=g:GetNext()
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
