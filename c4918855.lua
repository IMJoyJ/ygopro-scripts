--竜血公ヴァンパイア
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤成功的场合，以对方墓地最多2只怪兽为对象才能发动。那些怪兽效果无效在自己场上守备表示特殊召唤。
-- ②：怪兽的效果发动时，那些同名怪兽在自己·对方的墓地存在的场合才能发动。那个发动无效。
-- ③：从对方墓地有怪兽特殊召唤的场合，把自己场上2只怪兽解放才能发动。这张卡从墓地特殊召唤。
function c4918855.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以对方墓地最多2只怪兽为对象才能发动。那些怪兽效果无效在自己场上守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4918855,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,4918855)
	e1:SetTarget(c4918855.sptg1)
	e1:SetOperation(c4918855.spop1)
	c:RegisterEffect(e1)
	-- ②：怪兽的效果发动时，那些同名怪兽在自己·对方的墓地存在的场合才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4918855,1))  --"发动无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4918856)
	e2:SetCondition(c4918855.negcon)
	e2:SetTarget(c4918855.negtg)
	e2:SetOperation(c4918855.negop)
	c:RegisterEffect(e2)
	-- ③：从对方墓地有怪兽特殊召唤的场合，把自己场上2只怪兽解放才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4918855,2))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,4918857)
	e3:SetCondition(c4918855.spcon2)
	e3:SetCost(c4918855.spcost2)
	e3:SetTarget(c4918855.sptg2)
	e3:SetOperation(c4918855.spop2)
	c:RegisterEffect(e3)
end
-- 特殊召唤过滤条件：可守备表示特殊召唤的怪兽
function c4918855.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果发动准备：选择对方墓地怪兽为对象并设置发动条件
function c4918855.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c4918855.spfilter(chkc,e,tp) end
	if chk==0 then return ct>0
		-- 发动条件检查：对方墓地是否存在可特殊召唤的怪兽
		and Duel.IsExistingTarget(c4918855.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	if ct>2 then ct=2 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地最多2只怪兽作为对象
	local g=Duel.SelectTarget(tp,c4918855.spfilter,tp,0,LOCATION_GRAVE,1,ct,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤对方墓地的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ①效果处理：将选择的对方墓地怪兽效果无效并守备表示特殊召唤
function c4918855.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ct<1 then return end
	-- 获取连锁中仍关联的效果对象怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()>ct or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=g:Select(tp,1,1,nil)
	end
	local tc=g:GetFirst()
	while tc do
		-- 将对象怪兽表侧守备表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 那些怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那些怪兽效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	-- 完成特殊召唤步骤结算
	Duel.SpecialSummonComplete()
end
-- ②效果发动条件：怪兽效果发动且墓地存在同名怪兽
function c4918855.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动条件检查：发动的效果为怪兽效果且该发动可被无效
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 发动条件检查：双方墓地是否存在该发动效果怪兽的同名怪兽
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,re:GetHandler():GetCode())
end
-- ②效果发动准备：设置无效发动的操作信息
function c4918855.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息：使怪兽效果的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果处理：使怪兽效果的发动无效
function c4918855.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
-- 触发表决过滤条件：原控制者为对方且从墓地特殊召唤的怪兽
function c4918855.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(1-tp) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ③效果发动条件检查：确认对方墓地是否有怪兽被特殊召唤
function c4918855.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4918855.cfilter,1,nil,tp)
end
-- ③效果发动Cost：把自己场上2只怪兽解放
function c4918855.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可解放的怪兽组
	local rg=Duel.GetReleaseGroup(tp)
	-- Cost检查：是否存在解放2只怪兽后空出怪兽区域的有效组合
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 从自己场上选择2只满足条件的怪兽作为Cost解放
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	-- 处理代替解放次数消耗
	aux.UseExtraReleaseCount(g,tp)
	-- 解放选择的2只怪兽
	Duel.Release(g,REASON_COST)
end
-- ③效果发动准备：检查自身是否可特殊召唤并设置操作信息
function c4918855.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：从墓地特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：将墓地的自身特殊召唤
function c4918855.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
