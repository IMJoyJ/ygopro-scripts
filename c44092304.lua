--夢迷枕パラソムニア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的结束阶段才能发动。装备怪兽破坏。
-- ②：装备怪兽被破坏送去墓地让这张卡被送去墓地的场合才能发动。把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。那之后，这张卡给那衍生物装备。
local s,id,o=GetID()
-- 初始化效果函数，注册4个效果：装备、装备限制、结束阶段破坏、墓地触发特殊召唤衍生物
function s.initial_effect(c)
	-- ①：自己·对方的结束阶段才能发动。装备怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽不能被其他卡装备
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：装备怪兽被破坏送去墓地让这张卡被送去墓地的场合才能发动。把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。那之后，这张卡给那衍生物装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.tkcon)
	e4:SetTarget(s.tktg)
	e4:SetOperation(s.tkop)
	c:RegisterEffect(e4)
end
-- 设置装备效果的目标选择函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备目标条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个场上正面表示的怪兽作为装备目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
		e:GetHandler():SetTurnCounter(0)
	end
end
-- 设置破坏效果的目标选择函数
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec end
	ec:CreateEffectRelation(e)
	-- 设置破坏效果的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 破坏效果的处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsRelateToEffect(e) then
		-- 将装备怪兽破坏
		Duel.Destroy(ec,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤衍生物的条件
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY) and ec:IsLocation(LOCATION_GRAVE)
end
-- 设置特殊召唤衍生物的目标选择函数
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	local race=ec:GetOriginalRace()
	local attr=ec:GetOriginalAttribute()
	local atk=ec:GetBaseAttack()
	-- 判断场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否可以特殊召唤该衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,atk,0,1,race,attr) end
	e:SetLabel(race,attr,atk)
	-- 设置衍生物的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 设置离开墓地的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 特殊召唤衍生物并装备的处理函数
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,attr,atk=e:GetLabel()
	-- 判断场上是否有足够的特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤该衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,atk,0,1,race,attr) then
		-- 创建异睡衍生物
		local token=Duel.CreateToken(tp,id+o)
		-- 设置衍生物的种族
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(race)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetValue(attr)
		token:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_SET_BASE_ATTACK)
		e3:SetValue(atk)
		token:RegisterEffect(e3)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 将装备卡装备给衍生物
			Duel.Equip(tp,c,token)
		end
	end
end
