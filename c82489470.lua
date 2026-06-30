--軒轅の相剣師
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：怪兽的攻击宣言时才能发动。这张卡从手卡特殊召唤，那次攻击无效。自己场上有需以「阿不思的落胤」为融合素材的融合怪兽存在的场合，可以再把那只攻击宣言的怪兽破坏。
-- ②：怪兽被表侧表示除外的场合，把场上·墓地的这张卡除外才能发动。从自己的手卡·墓地把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
function c82489470.initial_effect(c)
	-- 记录卡片效果中记有「阿不思的落胤」的卡密码
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
	-- 这个卡名的②的效果1回合只能使用1次。②：怪兽被表侧表示除外的场合，把场上·墓地的这张卡除外才能发动。从自己的手卡·墓地把攻击力和守备力的数值相同的1只魔法师族·光属性怪兽特殊召唤。
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
-- 处理特殊召唤并无效攻击效果发动时的目标检测，确认怪兽区域有空位且自身可以被特殊召唤，并设置特殊召唤的操作信息
function c82489470.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检测怪兽区域是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤出场上表侧表示的需以「阿不思的落胤」为融合素材的融合怪兽
function c82489470.atkfilter(c)
	-- 判断怪兽是否为表侧表示的融合怪兽且将「阿不思的落胤」作为融合素材
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsFaceup()
end
-- 效果处理：从手牌特殊召唤这张卡，无效那次攻击，若自己场上有特定融合怪兽存在则可选择将那只攻击怪兽破坏
function c82489470.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 特殊召唤此卡，并如果成功，则无效那次攻击
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and Duel.NegateAttack()
		-- 并检查自己场上是否存在需以「阿不思的落胤」为融合素材的表侧表示融合怪兽
		and Duel.IsExistingMatchingCard(c82489470.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否将那只发起攻击的怪兽破坏
		and Duel.SelectYesNo(tp,aux.Stringid(82489470,0)) then  --"是否把攻击怪兽破坏？"
		-- 获取攻击宣言的怪兽
		local tc=Duel.GetAttacker()
		-- 手动显示选择的攻击怪兽的选定动画
		Duel.HintSelection(Group.FromCards(tc))
		-- 将攻击怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤出除外状态的表侧表示怪兽
function c82489470.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsFaceup()
end
-- 检查效果触发的条件：有怪兽被表侧表示除外
function c82489470.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c82489470.rmfilter,1,nil)
end
-- 处理效果发动的代价，将场上或墓地的这张卡除外
function c82489470.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将作为此卡效果来源的自身正面除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤出符合特殊召唤条件的攻击力和守备力数值相同的魔法师族·光属性怪兽
function c82489470.spfilter(c,e,tp)
	-- 判断怪兽是否为攻击力与守备力相同的光属性魔法师族怪兽
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER) and aux.AtkEqualsDef(c)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理特殊召唤效果发动时的目标检测，确认怪兽区域有空位，且手牌或墓地存在符合特殊召唤条件的怪兽，并设置特殊召唤的操作信息
function c82489470.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时检测怪兽区域是否有可用的空位（包含自身离开怪兽区域后的计算）
	if chk==0 then return Duel.GetMZoneCount(tp,c)>0
		-- 且手牌或墓地存在符合特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c82489470.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp) end
	-- 设置当前连锁的操作信息为从手牌或墓地特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果处理，让玩家选择手牌或墓地符合条件的一只怪兽并特殊召唤
function c82489470.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己的怪兽区域是否已没有空位，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或不受王家长眠之谷影响的墓地中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82489470.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
