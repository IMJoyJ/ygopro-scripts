--ホーリーナイツ・オルビタエル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只光属性怪兽为对象才能发动。那只怪兽解放，从卡组选1张「圣夜骑士」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
-- ②：这张卡在墓地存在，自己场上的表侧表示的龙族·光属性·7星怪兽回到手卡的场合才能发动。这张卡特殊召唤。
function c44818.initial_effect(c)
	-- ①：以自己场上1只光属性怪兽为对象才能发动。那只怪兽解放，从卡组选1张「圣夜骑士」魔法·陷阱卡在自己场上盖放。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44818,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,44818)
	e1:SetTarget(c44818.settg)
	e1:SetOperation(c44818.setop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的表侧表示的龙族·光属性·7星怪兽回到手卡的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44818,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,44819)
	e2:SetCondition(c44818.spcon)
	e2:SetTarget(c44818.sptg)
	e2:SetOperation(c44818.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为场上表侧表示的光属性且可因效果解放的怪兽
function c44818.releasefilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsReleasableByEffect()
end
-- 过滤函数，用于判断是否为「圣夜骑士」魔法·陷阱卡且可盖放
function c44818.setfilter(c)
	return c:IsSetCard(0x159) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果的发动时点处理函数，用于判断是否满足发动条件并设置效果对象
function c44818.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44818.releasefilter(chkc) end
	-- 检查自己场上是否存在满足条件的光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c44818.releasefilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己卡组是否存在满足条件的「圣夜骑士」魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c44818.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择满足条件的光属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c44818.releasefilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示将要解放对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,0,0)
end
-- 效果处理函数，执行解放怪兽并从卡组选择盖放魔法陷阱卡的操作
function c44818.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断对象怪兽是否仍然存在于场上且未被无效化，并执行解放操作
	if tc and tc:IsRelateToEffect(e) and Duel.Release(tc,REASON_EFFECT)~=0 then
		-- 提示玩家选择要盖放的魔法陷阱卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组中选择满足条件的魔法陷阱卡
		local g=Duel.SelectMatchingCard(tp,c44818.setfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的魔法陷阱卡盖放在场上
			Duel.SSet(tp,g:GetFirst())
		end
	end
end
-- 过滤函数，用于判断是否为己方场上表侧表示的龙族·光属性·7星怪兽
function c44818.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(7)
end
-- 效果发动条件函数，判断是否有满足条件的怪兽回到手卡
function c44818.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44818.cfilter,1,nil,tp)
end
-- 特殊召唤效果的发动时点处理函数，用于判断是否满足发动条件
function c44818.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，执行将此卡特殊召唤的操作
function c44818.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
