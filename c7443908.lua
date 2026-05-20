--地翔星ハヤテ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：在只有对方场上才有怪兽存在的场合或者在自己场上有光属性怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只战士族·光属性·5星怪兽特殊召唤。
-- ③：1回合1次，自己的战士族怪兽被选择作为攻击对象时才能发动。这张卡的攻击力下降500，那次攻击无效。
function c7443908.initial_effect(c)
	-- ①：在只有对方场上才有怪兽存在的场合或者在自己场上有光属性怪兽存在的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7443908,0))  --"不用解放作召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c7443908.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从手卡把1只战士族·光属性·5星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7443908,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,7443908)
	e2:SetTarget(c7443908.sptg)
	e2:SetOperation(c7443908.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己的战士族怪兽被选择作为攻击对象时才能发动。这张卡的攻击力下降500，那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(7443908,2))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c7443908.condition)
	e4:SetOperation(c7443908.operation)
	c:RegisterEffect(e4)
end
-- 过滤条件：场上表侧表示的光属性怪兽
function c7443908.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 不用解放作召唤的条件判定函数
function c7443908.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定是不需解放的召唤、怪兽等级在5星以上且怪兽区域有空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定只有对方场上才有怪兽存在
		and ((Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0)
		-- 或者自己场上有光属性怪兽存在
		or Duel.IsExistingMatchingCard(c7443908.cfilter,tp,LOCATION_MZONE,0,1,nil))
end
-- 过滤条件：手卡中可以特殊召唤的战士族·光属性·5星怪兽
function c7443908.filter1(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsLevel(5) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动准备（Target阶段）
function c7443908.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c7443908.filter1,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理（Operation阶段）
function c7443908.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择手卡中1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c7443908.filter1,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 攻击无效效果的发动条件判定函数
function c7443908.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsRace(RACE_WARRIOR)
end
-- 攻击无效效果的处理（Operation阶段）
function c7443908.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() and c:IsAttackAbove(500) then
		-- 这张卡的攻击力下降500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 无效该次攻击
			Duel.NegateAttack()
		end
	end
end
