--斬機ディヴィジョン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把额外怪兽区域1只自己的电子界族怪兽解放才能发动。从手卡以及自己墓地各选最多1只电子界族·4星怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
function c89743495.initial_effect(c)
	-- ①：把额外怪兽区域1只自己的电子界族怪兽解放才能发动。从手卡以及自己墓地各选最多1只电子界族·4星怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89743495,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,89743495)
	e1:SetCost(c89743495.cost)
	e1:SetTarget(c89743495.target)
	e1:SetOperation(c89743495.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时变成一半。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,89743496)
	e2:SetTarget(c89743495.atktg)
	e2:SetOperation(c89743495.atkop)
	c:RegisterEffect(e2)
end
-- 过滤可解放的额外怪兽区域的电子界族怪兽
function c89743495.costfilter(c,tp)
	-- 检查是否为电子界族、解放后能让自身场上留有空位、且位于额外怪兽区域
	return c:IsRace(RACE_CYBERSE) and Duel.GetMZoneCount(tp,c,tp)>0 and c:GetSequence()>=5
end
-- ①效果的发动代价（Cost）处理函数
function c89743495.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足解放条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c89743495.costfilter,1,nil,tp) end
	-- 玩家选择1只满足条件的怪兽作为解放对象
	local g=Duel.SelectReleaseGroup(tp,c89743495.costfilter,1,1,nil,tp)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤手卡或墓地中可以特殊召唤的4星电子界族怪兽
function c89743495.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查选择的卡片组是否来自不同的区域（手卡和墓地各最多1张）
function c89743495.fselect(g)
	return g:GetClassCount(Card.GetLocation)==g:GetCount()
end
-- ①效果的发动准备（Target）处理函数
function c89743495.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少1只可以特殊召唤的4星电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89743495.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡或墓地特殊召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的效果处理（Operation）函数
function c89743495.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自身场上空余的怪兽区域数量，最大限制为2
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),2)
	-- 获取手卡以及墓地中满足条件且不受王家之谷影响的怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c89743495.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c89743495.fselect,false,1,ft)
	if sg and sg:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动准备（Target）处理函数
function c89743495.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ②效果的效果处理（Operation）函数
function c89743495.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		-- 那只怪兽的攻击力直到回合结束时变成一半。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(math.ceil(atk/2))
		tc:RegisterEffect(e1)
	end
end
