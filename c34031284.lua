--おジャマ・エンペラー
-- 效果：
-- 包含「扰乱」怪兽的兽族怪兽3只
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：场地区域有「扰乱之乡」存在的场合，这张卡攻击力上升3000，不会被效果破坏。
-- ②：向这张卡的攻击发生的对自己的战斗伤害由对方代受。
-- ③：以连接怪兽以外的自己墓地1只「扰乱」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
function c34031284.initial_effect(c)
	-- 记录该卡具有「扰乱之乡」这张场地卡的卡名
	aux.AddCodeList(c,90011152)
	-- 设置连接召唤条件为使用3只包含「扰乱」的兽族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST),3,3,c34031284.lcheck)
	c:EnableReviveLimit()
	-- 场地区域有「扰乱之乡」存在的场合，这张卡攻击力上升3000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c34031284.condition)
	e1:SetValue(3000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 向这张卡的攻击发生的对自己的战斗伤害由对方代受
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetCondition(c34031284.refcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 以连接怪兽以外的自己墓地1只「扰乱」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34031284,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,34031284)
	e4:SetTarget(c34031284.target)
	e4:SetOperation(c34031284.operation)
	c:RegisterEffect(e4)
end
-- 连接素材中必须包含至少1张「扰乱」卡
function c34031284.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0xf)
end
-- 判断场地区域是否存在「扰乱之乡」
function c34031284.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地区域是否存在「扰乱之乡」
	return Duel.IsEnvironment(90011152,PLAYER_ALL,LOCATION_FZONE)
end
-- 判断当前是否为攻击阶段且该卡为攻击对象
function c34031284.refcon(e)
	-- 判断当前是否为攻击阶段且该卡为攻击对象
	return Duel.GetAttackTarget()==e:GetHandler()
end
-- 过滤满足「扰乱」种族、怪兽类型、非连接怪兽、可特殊召唤条件的墓地怪兽
function c34031284.filter(c,e,tp)
	return c:IsSetCard(0xf) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时选择目标的条件
function c34031284.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c34031284.filter(chkc,e,tp) end
	-- 判断是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c34031284.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为特殊召唤目标
	local g=Duel.SelectTarget(tp,c34031284.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作并设置后续限制效果
function c34031284.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 创建并注册一个限制自己不能从额外卡组特殊召唤非融合怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c34031284.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标为额外卡组中非融合怪兽
function c34031284.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
