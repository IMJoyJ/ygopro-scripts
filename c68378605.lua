--還流の精ヴォドニカ
-- 效果：
-- 「泉之精灵 沃德尼卡」以外的10星怪兽被送去墓地的场合（伤害步骤除外）：可以从自己的手卡·墓地把这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- 可以以自己墓地1只10星怪兽为对象；那只怪兽在对方场上效果无效特殊召唤，那之后，自己抽1张。
-- 「泉之精灵 沃德尼卡」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 定义初始效果函数，为卡片注册两个效果。
function s.initial_effect(c)
	-- 创建第一个效果，描述为“这张卡特殊召唤”，类别为特殊召唤，类型为场地诱发效果，触发条件为送入墓地，延迟生效，作用范围为手牌和墓地，限制每回合使用次数为1次。
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
	-- 创建第二个效果，描述为“特殊召唤”，类别为特殊召唤和抽卡，类型为起动效果，作用范围为主怪兽区，允许选择对象，限制每回合使用次数为1次（id+o）。
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
-- 定义一个过滤函数s.cfilter，用于筛选等级为10且不是沃德尼卡的卡片。
function s.cfilter(c,tp)
	return c:IsLevel(10) and not c:IsCode(id)
end
-- 定义条件函数s.spcon，检查是否存在满足s.cfilter条件的卡片。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 定义目标选择函数s.sptg，在chk为0时，检查场上是否有可用的怪兽区以及当前卡是否可以特殊召唤（表侧守备）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息，表示将要进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义效果函数s.spop，处理第一个效果。如果当前卡与连锁相关且不受王家长眠之谷的影响，则尝试以表侧守备形式特殊召唤该卡。之后创建一个效果，使这张卡离场时重新定向到移除区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查当前卡是否与连锁相关并且不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 如果特殊召唤成功，则执行后续操作。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 创建效果以重定向离开场地的卡片
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 定义过滤函数s.spfilter，用于筛选等级为10且可以特殊召唤的卡片（表侧攻击表示）。
function s.spfilter(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp)
end
-- 定义目标选择函数s.sptg2，在chk为0时，检查是否存在墓地中满足s.spfilter条件的卡片、对方场上是否有可用的怪兽区以及玩家是否可以抽牌。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否存在墓地中满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查对方场上是否有可用的怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 检查当前玩家是否可以抽一张牌
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 使用Duel.SelectTarget函数，让玩家从墓地中选择满足s.spfilter条件的卡片。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息，表示将要进行抽牌。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义效果函数s.spop2，处理第二个效果。获取目标卡片tc，如果tc与连锁相关且不受王家长眠之谷的影响，则尝试以表侧攻击形式特殊召唤该卡。之后创建两个效果：一个禁用目标怪兽，另一个禁用其效果。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain()
		-- 检查目标卡是否与连锁相关并且不受王家长眠之谷的影响。
		and aux.NecroValleyFilter()(tc)
		-- 如果特殊召唤成功，则执行后续操作。
		and Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP) then
		-- 创建效果禁用目标怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 创建效果禁用目标怪兽的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程。
		Duel.SpecialSummonComplete()
		-- 中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 让玩家抽一张牌。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
