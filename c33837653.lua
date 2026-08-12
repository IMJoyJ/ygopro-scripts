--天昇星テンマ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：在只有对方场上才有怪兽存在的场合或者在自己场上有地属性怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只战士族·地属性·5星怪兽特殊召唤。
-- ③：1回合1次，自己场上的战士族怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效并破坏。
function c33837653.initial_effect(c)
	-- ①：在只有对方场上才有怪兽存在的场合或者在自己场上有地属性怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33837653,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c33837653.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只战士族·地属性·5星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33837653,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,33837653)
	e2:SetTarget(c33837653.sptg)
	e2:SetOperation(c33837653.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己场上的战士族怪兽为对象的对方的效果发动时才能发动。这张卡的攻击力下降500，那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(33837653,2))
	e4:SetCategory(CATEGORY_NEGATE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c33837653.discon)
	e4:SetTarget(c33837653.distg)
	e4:SetOperation(c33837653.disop)
	c:RegisterEffect(e4)
end
-- 用于判断场上是否存在地属性怪兽的过滤函数
function c33837653.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 判断是否满足不用解放作召唤条件的函数
function c33837653.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断是否满足等级5以上且场上存在召唤区域的条件
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足只有对方场上才有怪兽存在的条件
		and ((Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0)
		-- 判断是否满足自己场上有地属性怪兽存在的条件
		or Duel.IsExistingMatchingCard(c33837653.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 用于筛选手牌中满足战士族、地属性、5星且可特殊召唤的怪兽的过滤函数
function c33837653.filter1(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件
function c33837653.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c33837653.filter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作的函数
function c33837653.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c33837653.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 用于判断场上是否存在己方战士族怪兽的过滤函数
function c33837653.filter2(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_WARRIOR)
end
-- 判断是否满足效果发动条件的函数
function c33837653.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断是否满足效果发动条件
	return rp==1-tp and g and g:IsExists(c33837653.filter2,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 设置无效效果的发动条件
function c33837653.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackAbove(500) end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行无效效果和破坏效果的函数
function c33837653.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackAbove(500) then
		-- 使自身攻击力下降500的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 使连锁发动无效并破坏目标卡片
			if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
				-- 破坏目标卡片
				Duel.Destroy(eg,REASON_EFFECT)
			end
		end
	end
end
