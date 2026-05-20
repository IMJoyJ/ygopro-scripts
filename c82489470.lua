--軒轅の相剣師
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，可以再把那只攻击宣言的怪兽破坏。
-- ②：怪兽被表侧表示除外的场合，把场上·墓地的这张卡除外才能发动。从自己的手卡·墓地把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
function c82489470.initial_effect(c)
	-- 注册卡片记载了「阿不思的落胤」（卡号68468459）的事实
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
	-- ②：怪兽被表侧表示除外的场合，把场上·墓地的这张卡除外才能发动。从自己的手卡·墓地把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
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
-- 效果①的发动准备与可行性检查函数
function c82489470.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（检查是否满足发动条件）时，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤自己场上需以「阿不思的落胤」为融合素材的表侧表示融合怪兽的过滤函数
function c82489470.atkfilter(c)
	-- 检查卡片是否为表侧表示的、以「阿不思的落胤」为融合素材的融合怪兽
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsFaceup()
end
-- 效果①的效果处理函数
function c82489470.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将此卡特殊召唤，并无效该次攻击
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) and Duel.NegateAttack()
		-- 检查自己场上是否存在需以「阿不思的落胤」为融合素材的融合怪兽
		and Duel.IsExistingMatchingCard(c82489470.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否选择将那只攻击宣言的怪兽破坏
		and Duel.SelectYesNo(tp,aux.Stringid(82489470,0)) then  --"是否把攻击怪兽破坏？"
		-- 获取当前进行攻击宣言的怪兽
		local tc=Duel.GetAttacker()
		-- 高亮选中该攻击怪兽
		Duel.HintSelection(Group.FromCards(tc))
		-- 因效果破坏该攻击怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤表侧表示被除外的怪兽的过滤函数
function c82489470.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 效果②的发动条件检查函数（检查是否有怪兽被表侧表示除外）
function c82489470.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82489470.rmfilter,1,nil)
end
-- 效果②的发动代价处理函数（将场上或墓地的这张卡除外）
function c82489470.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将自身表侧表示除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤手卡或墓地中攻击力和守备力数值相同的光属性·魔法师族怪兽的过滤函数
function c82489470.spfilter(c,e,tp)
	-- 检查卡片是否为攻击力与守备力数值相同的光属性·魔法师族怪兽
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与可行性检查函数
function c82489470.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk==0时，检查自身除外后自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 检查手卡或墓地是否存在可特殊召唤的符合条件的怪兽
		and Duel.IsExistingMatchingCard(c82489470.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp) end
	-- 设置从手卡或墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果②的效果处理函数
function c82489470.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有空余的怪兽区域，则不进行后续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地（受王家之谷影响）选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82489470.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
