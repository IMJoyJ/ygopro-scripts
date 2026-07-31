--還流の精ヴォドニカ
-- 效果：
-- 「泉之精灵 沃德尼卡」以外的10星怪兽被送去墓地的场合（伤害步骤除外）：可以从自己的手卡·墓地把这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- 可以以自己墓地1只10星怪兽为对象；那只怪兽在对方场上效果无效特殊召唤，那之后，自己抽1张。
-- 「泉之精灵 沃德尼卡」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌·墓地特召效果、②在对方场上特召墓地10星怪兽并抽卡效果
function s.initial_effect(c)
	-- 「泉之精灵 沃德尼卡」以外的10星怪兽被送去墓地的场合（伤害步骤除外）：可以从自己的手卡·墓地把这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 可以以自己墓地1只10星怪兽为对象才能发动；那只怪兽在对方场上效果无效特殊召唤，那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 触发表件过滤条件：除自身以外的10星怪兽
function s.cfilter(c,tp)
	return c:IsLevel(10) and not c:IsCode(id)
end
-- ①效果发动条件：存在除自身以外的10星怪兽被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①效果发动准备：检查怪兽区域空位与自身特召条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁操作信息：特殊召唤自身1张
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：守备表示特殊召唤自身，并给予离场除外约束
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁且不受王谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将此卡表侧守备表示特殊召唤到己方场上
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果特召目标过滤条件：墓地的10星怪兽且可以在对方场上特殊召唤
function s.spfilter(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- ②效果发动准备与选择目标：检查墓地目标、对方场上空位及抽卡条件，选择对象怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 发动条件检查：墓地是否存在满足条件的10星怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 发动条件检查：对方主要怪兽区域是否有空位
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 发动条件检查：己方玩家是否可以抽1张卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只10星怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息：特殊召唤选择的对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果处理：在对方场上特殊召唤对象怪兽并无效其效果，然后抽1张卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁选定的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 检查对象怪兽不受王谷影响
		and aux.NecroValleyFilter()(tc)
		-- 将对象怪兽表侧表示特殊召唤到对方场上
		and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 那只怪兽在对方场上效果无效特殊召唤
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那只怪兽在对方场上效果无效特殊召唤
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤步骤
		Duel.SpecialSummonComplete()
		-- 效果连接中断（前置特召完成，进行后续处理）
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
