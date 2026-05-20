--Vodnika the Fountain Spirit
-- 效果：
-- 「泉之精灵 沃德尼卡」以外的10星怪兽被送去墓地的场合（伤害步骤除外）：可以从自己的手卡·墓地把这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- 可以以自己墓地1只10星怪兽为对象；那只怪兽在对方场上效果无效特殊召唤，那之后，自己抽1张。
-- 「泉之精灵 沃德尼卡」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果：注册效果1（送墓诱发自身特召）与效果2（起动效果特召墓地怪兽并抽卡）
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
	-- 可以以自己墓地1只10星怪兽为对象；那只怪兽在对方场上效果无效特殊召唤，那之后，自己抽1张。
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
-- 过滤条件：等级为10且卡名不是「泉之精灵 沃德尼卡」的怪兽
function s.cfilter(c,tp)
	return c:IsLevel(10) and not c:IsCode(id)
end
-- 检查送去墓地的卡中是否存在满足条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 检查自身是否能以守备表示特殊召唤到自己场上
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤自身的连锁处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果1的处理：将自身特殊召唤，并添加离场时除外的约束
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与连锁相关，且不受「王家之谷」影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将自身以守备表示特殊召唤到自己场上，并检查是否成功
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
-- 过滤条件：自己墓地中可以特殊召唤到对方场上的10星怪兽
function s.spfilter(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 检查墓地中是否存在可特召的10星怪兽，且对方场上有空位，且自己可以抽卡
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在满足特殊召唤条件的10星怪兽
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查对方场上是否有可用的怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的10星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤对象怪兽的连锁处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置自己抽1张卡的连锁处理信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果2的处理：将对象怪兽在对方场上效果无效特殊召唤，之后自己抽1张卡
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 检查对象怪兽是否不受「王家之谷」影响
		and aux.NecroValleyFilter()(tc)
		-- 尝试将对象怪兽以表侧表示特殊召唤到对方场上
		and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤的后续处理
		Duel.SpecialSummonComplete()
		-- 中断当前效果处理，使后续的抽卡处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
