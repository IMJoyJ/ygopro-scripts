--軒轅の相剣師
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，可以再把那只攻击宣言的怪兽破坏。
-- ②：怪兽被表侧表示除外的场合，把场上·墓地的这张卡除外才能发动。从自己的手卡·墓地把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
function c82489470.initial_effect(c)
	-- 注册卡名记载信息，标记这张卡上记载着「阿不思的落胤」（卡号68468459）
	aux.AddCodeList(c,68468459)
	-- ①：怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，可以再把那只攻击宣言的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c82489470.atktg)
	e1:SetOperation(c82489470.atkop)
	c:RegisterEffect(e1)
	-- ②：怪兽被表侧表示除外的场合，把场上·墓地的这张卡除外才能发动。从自己的手卡·墓地把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。（这个卡名的②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,82489470)
	e2:SetCondition(c82489470.spcon)
	e2:SetCost(c82489470.spcost)
	e2:SetTarget(c82489470.sptg)
	e2:SetOperation(c82489470.spop)
	c:RegisterEffect(e2)
end
-- ①效果的目标函数：确认自己主要怪兽区有空位且这张卡可以从手卡特殊召唤
function c82489470.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区必须有1个以上空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣告将把这张卡（1只）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：筛选自己场上需以「阿不思的落胤」为融合素材的表侧表示融合怪兽
function c82489470.atkfilter(c)
	-- 判断该卡是表侧表示的融合怪兽，且融合素材中包含「阿不思的落胤」（卡号68468459）
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsFaceup()
end
-- ①效果的处理：这张卡从手卡特殊召唤并使那次攻击无效，之后可根据条件破坏攻击怪兽
function c82489470.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡仍与效果关联，则把它从手卡以表侧攻击表示特殊召唤，并将那次攻击无效
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.NegateAttack()
		-- 确认自己场上存在需以「阿不思的落胤」为融合素材的表侧表示融合怪兽
		and Duel.IsExistingMatchingCard(c82489470.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否把那只攻击宣言的怪兽破坏，选择「是」才继续处理
		and Duel.SelectYesNo(tp,aux.Stringid(82489470,0)) then  --"是否把攻击怪兽破坏？"
		-- 取得这次攻击宣言的攻击怪兽
		local tc=Duel.GetAttacker()
		-- 为攻击怪兽显示被选中的提示动画，标记其为处理对象
		Duel.HintSelection(Group.FromCards(tc))
		-- 以效果破坏那只攻击宣言的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：筛选被表侧表示除外的怪兽
function c82489470.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- ②效果的发动条件：本次除外的卡中存在表侧表示除外的怪兽
function c82489470.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82489470.rmfilter,1,nil)
end
-- ②效果的代价：把场上·墓地的这张卡除外
function c82489470.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 把这张卡以表侧表示除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤函数：筛选自己手卡·墓地中可以特殊召唤的攻击力和守备力数值相同的魔法师族·光属性怪兽
function c82489470.spfilter(c,e,tp)
	-- 判断该卡是攻击力和守备力数值相同的魔法师族·光属性怪兽
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标函数：确认这张卡离场后自己主要怪兽区有空位，且手卡·墓地存在可特殊召唤的满足条件的怪兽
function c82489470.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检查：这张卡离场后自己主要怪兽区必须有1个以上空位
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 确认自己手卡·墓地存在攻击力和守备力数值相同且可以特殊召唤的魔法师族·光属性怪兽
		and Duel.IsExistingMatchingCard(c82489470.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp) end
	-- 设置操作信息：宣告将从自己手卡·墓地把1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果的处理：从自己手卡·墓地选1只满足条件的魔法师族·光属性怪兽特殊召唤
function c82489470.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区没有空位则中止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己手卡·墓地选择1只满足条件且不受「王家长眠之谷」影响的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82489470.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 把选中的那只怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
