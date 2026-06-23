--The grand JUPITER
-- 效果：
-- ①：1回合1次，丢弃2张手卡，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的原本攻击力数值。
-- ③：自己·对方的结束阶段，以这张卡的效果装备的1张怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
function c16255173.initial_effect(c)
	-- ①：1回合1次，丢弃2张手卡，以对方场上1只表侧表示怪兽为对象才能发动。那只表侧表示怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16255173,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c16255173.eqcost)
	e1:SetTarget(c16255173.eqtg)
	e1:SetOperation(c16255173.eqop)
	c:RegisterEffect(e1)
	-- ③：自己·对方的结束阶段，以这张卡的效果装备的1张怪兽卡为对象才能发动。那张卡在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16255173,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetTarget(c16255173.sptg)
	e2:SetOperation(c16255173.spop)
	c:RegisterEffect(e2)
end
-- 丢弃2张手卡作为cost
function c16255173.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃2张手卡的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	-- 执行丢弃2张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 装备怪兽的过滤条件：表侧表示且可以改变控制权
function c16255173.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 设置效果目标：选择对方场上的1只表侧表示怪兽
function c16255173.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c16255173.eqfilter(chkc) end
	-- 检查装备区域是否空余
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c16255173.eqfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c16255173.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备怪兽并设置攻击力提升效果
function c16255173.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER)) then return end
	local atk=tc:GetTextAttack()
	if tc:IsFacedown() or atk<0 then atk=0 end
	-- 尝试将目标怪兽装备给自身
	if not Duel.Equip(tp,tc,c) then return end
	-- 给装备怪兽添加攻击力提升效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	-- 设置装备限制效果，防止被其他装备卡装备
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c16255173.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
	tc:RegisterFlagEffect(16255173,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 装备限制效果的判断函数
function c16255173.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 特殊召唤目标怪兽的过滤条件
function c16255173.spfilter(c,e,tp,ec)
	return c:GetFlagEffect(16255173)~=0 and c:GetEquipTarget()==ec and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标：选择自己场上装备的怪兽
function c16255173.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c16255173.spfilter(chkc,e,tp,c) end
	-- 检查是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的装备怪兽
		and Duel.IsExistingTarget(c16255173.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp,c) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c16255173.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp,c)
	-- 设置操作信息，告知连锁将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c16255173.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
