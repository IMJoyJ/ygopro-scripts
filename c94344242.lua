--電子光虫－ウェブソルダー
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
-- ①：1回合1次，以自己场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成守备表示，从手卡把1只昆虫族·3星怪兽守备表示特殊召唤。
-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
-- ●这次超量召唤成功的场合发动。对方场上的全部表侧表示怪兽守备力变成0，变成守备表示。
function c94344242.initial_effect(c)
	-- 把这张卡作为超量召唤的素材的场合，不是昆虫族怪兽的超量召唤不能使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(c94344242.xyzlimit)
	c:RegisterEffect(e0)
	-- ①：1回合1次，以自己场上1只表侧攻击表示怪兽为对象才能发动。那只怪兽变成守备表示，从手卡把1只昆虫族·3星怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94344242,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(c94344242.sptg)
	e1:SetOperation(c94344242.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCondition(c94344242.efcon)
	e2:SetOperation(c94344242.efop)
	c:RegisterEffect(e2)
end
-- 限制该卡只能作为昆虫族怪兽的超量召唤素材
function c94344242.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
-- 过滤手牌中满足等级为3、昆虫族且可以表侧守备表示特殊召唤的怪兽
function c94344242.spfilter(c,e,tp)
	return c:IsLevel(3) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤场上表侧攻击表示且可以改变表示形式的怪兽
function c94344242.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- ①号效果的发动准备与对象选择
function c94344242.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c94344242.filter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在可以改变表示形式的表侧攻击表示怪兽
		and Duel.IsExistingTarget(c94344242.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查手牌中是否存在可以特殊召唤的3星昆虫族怪兽
		and Duel.IsExistingMatchingCard(c94344242.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择一只表侧攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUPATTACK)  --"请选择表侧攻击表示的怪兽"
	-- 选择自己场上一只表侧攻击表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c94344242.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息：包含改变表示形式的操作，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
	-- 设置连锁信息：包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①号效果的实际处理：将对象怪兽变为守备表示，并从手牌特殊召唤怪兽
function c94344242.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果且处于表侧攻击表示，则将其变为表侧守备表示
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 then
		-- 若此时自己场上没有可用的怪兽区域，则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌选择一只满足条件的3星昆虫族怪兽
		local g=Duel.SelectMatchingCard(tp,c94344242.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()==0 then return end
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 检查该卡是否作为超量召唤的素材
function c94344242.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 为超量召唤出的怪兽赋予诱发效果，并在其不是效果怪兽时添加效果怪兽类型
function c94344242.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这次超量召唤成功的场合发动。对方场上的全部表侧表示怪兽守备力变成0，变成守备表示。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(94344242,1))  --"全部变成守备表示（电子光虫-焊料织网蛛）"
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c94344242.defcon)
	e1:SetTarget(c94344242.deftg)
	e1:SetOperation(c94344242.defop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ②：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 检查赋予效果的怪兽是否成功进行超量召唤
function c94344242.defcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 赋予效果的发动准备，并向对方玩家提示效果发动
function c94344242.deftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示该效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 赋予效果的实际处理：将对方场上所有表侧表示怪兽变为守备表示，且守备力变为0
function c94344242.defop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变为表侧守备表示
	Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部表侧表示怪兽守备力变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
