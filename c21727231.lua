--セリオンズ“リーパー”ファム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「兽带斗神」怪兽或者水族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
-- ②：对方回合，以自己的魔法与陷阱区域1张「兽带斗神」卡和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
local s,id,o=GetID()
-- 创建①效果，允许从手卡特殊召唤并装备墓地的水族或兽带斗神怪兽
function c21727231.initial_effect(c)
	-- ①：以自己墓地1只「兽带斗神」怪兽或者水族怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21727231,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,21727231)
	e1:SetTarget(c21727231.sptg)
	e1:SetOperation(c21727231.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以自己的魔法与陷阱区域1张「兽带斗神」卡和对方场上1张卡为对象才能发动。那些卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21727231,1))  --"双方卡回到手卡（兽带斗神“跃鱼”霹雳一）"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,21727231+o)
	e2:SetCondition(c21727231.thcon)
	e2:SetTarget(c21727231.thtg)
	e2:SetOperation(c21727231.thop)
	c:RegisterEffect(e2)
	-- ③：有这张卡装备的「兽带斗神」怪兽攻击力上升700，得到这个卡名的②的效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c21727231.eftg)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 装备效果，使装备怪兽攻击力上升700点
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetValue(700)
	e4:SetCondition(c21727231.atkcon)
	c:RegisterEffect(e4)
end
-- 筛选满足条件的墓地怪兽（水族或兽带斗神怪兽）
function c21727231.eqfilter(c,tp)
	return (c:IsRace(RACE_AQUA) or c:IsSetCard(0x179)) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件判断
function c21727231.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c21727231.eqfilter(chkc,tp) and chkc:IsControler(tp) end
	-- 判断是否有足够的怪兽区域和魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c21727231.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	local sg=Duel.SelectTarget(tp,c21727231.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息，标记将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,sg,1,0,0)
	-- 设置操作信息，标记将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数，执行特殊召唤和装备
function c21727231.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否有足够的怪兽区域且自身在连锁中
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 执行特殊召唤操作
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取目标怪兽
		local tc=Duel.GetFirstTarget()
		-- 判断目标怪兽是否在连锁中且有足够魔法陷阱区域
		if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
			-- 执行装备操作
			Duel.Equip(tp,tc,c,false)
			-- 设置装备限制效果，防止被其他卡装备
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c21727231.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
-- 装备限制效果的判断函数
function c21727231.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②效果的发动条件，判断是否为对方回合
function c21727231.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 筛选魔法陷阱区的兽带斗神卡
function c21727231.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x179) and c:GetSequence()<5 and c:IsAbleToHand()
end
-- ②效果的发动条件判断
function c21727231.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己魔法陷阱区是否存在兽带斗神卡
	if chk==0 then return Duel.IsExistingTarget(c21727231.filter,tp,LOCATION_SZONE,0,1,nil)
		-- 判断对方场上是否存在可返回手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示对方选择了此效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己魔法陷阱区的兽带斗神卡
	local g1=Duel.SelectTarget(tp,c21727231.filter,tp,LOCATION_SZONE,0,1,1,nil)
	-- 提示选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上的卡
	local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，标记将要返回手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- ②效果的处理函数，将卡返回手牌
function c21727231.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将符合条件的卡返回手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 判断目标怪兽是否装备此卡
function c21727231.eftg(e,c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x179) and c:GetEquipGroup():IsContains(e:GetHandler())
end
-- 判断装备怪兽是否为兽带斗神族
function c21727231.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsSetCard(0x179)
end
