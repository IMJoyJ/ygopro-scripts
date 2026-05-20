--セリオンズ“デューク”ユール
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者念动力族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：只要自己场上有装备卡存在，自己场上的「兽带斗神」怪兽不会被对方的效果破坏。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
function c57111330.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者念动力族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57111330,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,57111330)
	e1:SetTarget(c57111330.sptg)
	e1:SetOperation(c57111330.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有装备卡存在，自己场上的「兽带斗神」怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c57111330.indcon)
	e2:SetTarget(c57111330.indtg)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c57111330.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c57111330.atkcon)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地中可以作为装备卡的「兽带斗神」怪兽或念动力族怪兽
function c57111330.eqfilter(c,tp)
	return (c:IsRace(RACE_PSYCHO) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①的效果的发动准备与合法性检测
function c57111330.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c57111330.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 判定自己场上是否有可用的怪兽区域和魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己墓地是否存在可以作为装备卡的对象怪兽
		and Duel.IsExistingTarget(c57111330.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只「兽带斗神」怪兽或念动力族怪兽作为效果的对象
	local sg=Duel.SelectTarget(tp,c57111330.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置效果处理信息为有卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置效果处理信息为特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果的处理（特殊召唤自身并装备对象怪兽）
function c57111330.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定自己场上是否有可用怪兽区域且自身是否仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将自身从手牌表侧表示特殊召唤，并判定是否特殊召唤成功
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取发动的对象怪兽
		local tc=Duel.GetFirstTarget()
		-- 判定对象怪兽是否仍与效果相关联且自己场上是否有可用魔法与陷阱区域
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将对象怪兽作为装备卡装备给这张卡
			Duel.Equip(tp,tc,c,false)
			-- ①：以自己墓地1只「兽带斗神」怪兽或者念动力族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c57111330.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 限制装备卡只能装备给这张卡
function c57111330.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤场上存在的装备卡
function c57111330.indcfilter(c)
	return c:GetEquipTarget() or c:IsFaceup() and c:IsType(TYPE_EQUIP)
end
-- 判定自己场上是否存在装备卡
function c57111330.indcon(e)
	-- 检查自己场上是否存在至少1张装备卡
	return Duel.IsExistingMatchingCard(c57111330.indcfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 过滤自己场上的「兽带斗神」怪兽
function c57111330.indtg(e,c)
	return c:IsSetCard(0x179)
end
-- 过滤装备了这张卡的「兽带斗神」怪兽
function c57111330.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 判定这张卡是否装备在「兽带斗神」怪兽上
function c57111330.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
