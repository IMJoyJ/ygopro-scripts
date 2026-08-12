--命の奇跡
-- 效果：
-- 地属性同调怪兽才能装备。
-- ①：只在装备怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1500。
-- ②：1回合1次，怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，把自己场上1只「动力工具」同调怪兽解放才能发动。从额外卡组把1只「生命激流龙」当作同调召唤作特殊召唤。
local s,id=GetID()
-- 初始化效果函数，创建并注册5个效果
function s.initial_effect(c)
	-- ①：只在装备怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 地属性同调怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	c:RegisterEffect(e2)
	-- ①：只在装备怪兽和对方怪兽进行战斗的伤害计算时，那只对方怪兽的攻击力下降1500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(s.atktg)
	e3:SetValue(-1500)
	c:RegisterEffect(e3)
	-- ②：1回合1次，怪兽的表示形式变更的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"场上1张卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合，把自己场上1只「动力工具」同调怪兽解放才能发动。从额外卡组把1只「生命激流龙」当作同调召唤作特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetLabel(0)
	e5:SetCondition(s.spcon)
	e5:SetCost(s.spcost)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
-- 过滤函数，用于判断是否为地属性且为同调怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 设置装备目标，选择一个地属性同调怪兽作为装备对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查是否存在满足条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个地属性同调怪兽作为装备对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备操作函数，将装备卡装备给目标怪兽
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备对象限制函数，仅允许地属性同调怪兽装备
function s.eqlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsType(TYPE_SYNCHRO)
end
-- 攻击力下降条件函数，判断是否处于伤害计算阶段且有战斗目标
function s.atkcon(e)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断是否处于伤害计算阶段且有战斗目标
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL and ec and ec:GetBattleTarget() and ec:IsRelateToBattle()
end
-- 攻击力下降目标函数，设定只对战斗中的对方怪兽生效
function s.atktg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return c==ec:GetBattleTarget()
end
-- 破坏效果的目标设定函数，选择场上一张卡作为破坏对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在满足条件的破坏目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的处理函数，将目标卡破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏目标
	local tc=Duel.GetFirstTarget()
	-- 执行破坏操作
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 特殊召唤条件函数，判断装备卡是否从魔法陷阱区送入墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousSequence()<5
end
-- 解放卡筛选函数，判断是否为动力工具同调怪兽且能特殊召唤生命激流龙
function s.cfilter(c,e,tp)
	return c:IsSetCard(0xc2) and c:IsType(TYPE_SYNCHRO)
		-- 检查是否存在可特殊召唤的生命激流龙
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤卡筛选函数，判断是否为生命激流龙且满足召唤条件
function s.spfilter(c,e,tp,sc)
	return c:IsCode(25165047) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
		-- 检查额外卡组是否有足够的召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,sc,c)>0
end
-- 特殊召唤的费用函数，选择并解放一只动力工具同调怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,e,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择一只动力工具同调怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,e,tp)
	-- 执行解放操作
	Duel.Release(g,REASON_COST)
end
-- 特殊召唤的目标设定函数，检查是否满足召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足必须成为素材的条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查是否存在可特殊召唤的卡
		and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 特殊召唤的处理函数，从额外卡组特殊召唤生命激流龙
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足必须成为素材的条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一只生命激流龙进行特殊召唤
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	-- 执行特殊召唤操作
	if tc and Duel.SpecialSummon(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
		tc:CompleteProcedure()
	end
end
