--セリオンズ“エンプレス”アラシア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者爬虫类族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：丢弃1张手卡，以自己的魔法与陷阱区域1张「兽带斗神」怪兽卡为对象才能发动。那张卡特殊召唤。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
function c48806195.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者爬虫类族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48806195,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,48806195)
	e1:SetTarget(c48806195.sptg1)
	e1:SetOperation(c48806195.spop1)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡，以自己的魔法与陷阱区域1张「兽带斗神」怪兽卡为对象才能发动。那张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(48806195,1))  --"魔陷区怪兽卡特殊召唤（兽带斗神“女帝”阿拉西亚星）"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,48806196)
	e2:SetCost(c48806195.spcost2)
	e2:SetTarget(c48806195.sptg2)
	e2:SetOperation(c48806195.spop2)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c48806195.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 以自己墓地1只「兽带斗神」怪兽或者爬虫类族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c48806195.atkcon)
	c:RegisterEffect(e4)
end
-- 检索满足条件的墓地怪兽（爬虫类或兽带斗神）
function c48806195.eqfilter(c,tp)
	return (c:IsRace(RACE_REPTILE) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- 判断是否满足①效果的发动条件（包括手牌特殊召唤、目标怪兽存在、场地空间等）
function c48806195.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c48806195.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 判断手牌是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c48806195.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地怪兽作为装备对象
	local sg=Duel.SelectTarget(tp,c48806195.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：将目标怪兽从墓地移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果的处理流程（特殊召唤自身并装备目标怪兽）
function c48806195.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 执行特殊召唤操作
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前连锁的目标卡
		local tc=Duel.GetFirstTarget()
		-- 判断目标卡是否有效且场上是否有装备区域
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 将目标怪兽装备给自身
			Duel.Equip(tp,tc,c,false)
			-- 设置装备限制效果，防止被其他装备卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c48806195.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制效果的判定函数
function c48806195.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动费用：丢弃一张手卡
function c48806195.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以丢弃手卡作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选满足条件的魔陷区怪兽（兽带斗神）
function c48806195.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x179) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足②效果的发动条件（包括目标魔陷区怪兽存在、场地空间等）
function c48806195.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c48806195.spfilter(chkc,e,tp) end
	-- 判断手牌是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断魔陷区是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(c48806195.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的魔陷区怪兽作为目标
	local g=Duel.SelectTarget(tp,c48806195.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：将目标怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行②效果的处理流程（丢弃手卡并特殊召唤目标怪兽）
function c48806195.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断目标怪兽是否为装备怪兽且属于兽带斗神
function c48806195.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 判断装备目标是否为兽带斗神
function c48806195.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
