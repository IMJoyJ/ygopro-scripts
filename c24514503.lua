--心を凍らせるスノークリスタル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，自己场上的怪兽数量比对方场上的怪兽少2只以上的场合才能发动。这张卡特殊召唤。
-- ②：场上的这张卡不会被效果破坏。
-- ③：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
local s,id,o=GetID()
-- 创建三个效果，分别对应卡片的①②③效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，自己场上的怪兽数量比对方场上的怪兽少2只以上的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：以对方场上1只效果怪兽为对象才能发动。那只怪兽的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 判断是否满足①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上的怪兽数量比对方少2只以上
	return Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2
end
-- 设置①效果的发动目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行①效果的处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置③效果的发动目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 筛选对方场上的效果怪兽作为目标
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 判断对方场上是否存在效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上的1只效果怪兽作为目标
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果无效的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行③效果的处理
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsCanBeDisabledByEffect(e) then
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
