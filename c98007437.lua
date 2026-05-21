--鎧騎士竜－ナイト・アームド・ドラゴン－
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己把5星以上的龙族怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这张卡的属性·等级变成和自己的除外状态的1只龙族怪兽相同。
-- ③：这张卡被送去墓地的场合，以自己场上1只龙族怪兽为对象才能发动（双方不能对应这个效果的发动把效果发动）。那只怪兽的攻击力上升1000。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤、属性等级变化、攻击力上升三个效果
function s.initial_effect(c)
	-- ①：自己把5星以上的龙族怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合才能发动。这张卡的属性·等级变成和自己的除外状态的1只龙族怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"属性等级变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.raattg)
	e2:SetOperation(s.raatop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己场上1只龙族怪兽为对象才能发动（双方不能对应这个效果的发动把效果发动）。那只怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"攻击力上升"
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.atktg)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
-- 过滤自己特殊召唤成功的表侧表示5星以上龙族怪兽
function s.spfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsRace(RACE_DRAGON) and c:IsLevelAbove(5) and c:IsFaceup()
end
-- 检查是否有满足条件的5星以上龙族怪兽特殊召唤成功，作为效果①的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp)
end
-- 效果①的发动准备与合法性检测，检查怪兽区域空位及自身是否能特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数，将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤自己除外状态的、且属性或等级与自身不同的龙族怪兽
function s.raatfilter(c,ec)
	return c:IsFaceupEx() and c:IsRace(RACE_DRAGON)
		and (not c:IsAttribute(ec:GetAttribute())
		or not c:IsLevel(ec:GetLevel()))
end
-- 效果②的发动准备与合法性检测，检查除外状态是否存在可复制属性或等级的龙族怪兽
function s.raattg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己的除外状态是否存在至少1只属性或等级与自身不同的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.raatfilter,tp,LOCATION_REMOVED,0,1,nil,c) end
end
-- 效果②的效果处理函数，选择除外状态的1只龙族怪兽，使自身的属性和等级变成与其相同
function s.raatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在场上表侧表示存在，且除外状态仍有满足条件的龙族怪兽
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.raatfilter,tp,LOCATION_REMOVED,0,1,nil,c) then
		-- 提示玩家选择一张表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家从自己的除外状态中选择1只满足条件的龙族怪兽
		local tg=Duel.SelectMatchingCard(tp,s.raatfilter,tp,LOCATION_REMOVED,0,1,1,nil,c)
		if tg:GetCount()>0 then
			-- 闪烁显示被选中的除外状态的怪兽
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			-- 这张卡的属性·等级变成和自己的除外状态的1只龙族怪兽相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(tc:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e2:SetValue(tc:GetAttribute())
			c:RegisterEffect(e2)
		end
	end
end
-- 过滤自己场上表侧表示的龙族怪兽
function s.atkfilter2(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果③的发动准备与合法性检测，选择自己场上1只表侧表示的龙族怪兽作为对象，并限制双方不能对应发动效果
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.atkfilter2(chkc) end
	-- 检查自己场上是否存在可以作为效果对象的表侧表示龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一张表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只表侧表示的龙族怪兽作为效果对象
	Duel.SelectTarget(tp,s.atkfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 限制连锁，使得双方不能对应这个效果的发动把效果发动
	Duel.SetChainLimit(aux.FALSE)
end
-- 效果③的效果处理函数，使作为对象的怪兽攻击力上升1000
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
