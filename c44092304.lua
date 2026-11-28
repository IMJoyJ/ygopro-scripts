--夢迷枕パラソムニア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的结束阶段才能发动。装备怪兽破坏。
-- ②：装备怪兽被破坏送去墓地让这张卡被送去墓地的场合才能发动。把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。那之后，这张卡给那衍生物装备。
local s,id,o=GetID()
-- 初始化装备魔法卡效果：注册装备发动、装备对象限制，以及同名卡1回合各1次的①②效果
function s.initial_effect(c)
	-- （装备魔法卡的通常装备发动效果）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- （装备对象限制：可装备给场上任意表侧表示怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。①：自己·对方的结束阶段才能发动。装备怪兽破坏。
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
	-- ②：装备怪兽被破坏送去墓地让这张卡被送去墓地的场合才能发动。把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。那之后，这张卡给那衍生物装备。
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
-- 装备魔法发动目标设定：取场上1只表侧表示怪兽为装备对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查双方场上是否存在至少1只表侧表示怪兽可作为装备对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要装备的目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方场上选择1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 声明本次效果会将这张卡进行装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备发动处理：将这张卡装备给仍表侧在场的对象怪兽并重置回合计数器
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选定的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备到目标怪兽上
		Duel.Equip(tp,e:GetHandler(),tc)
		e:GetHandler():SetTurnCounter(0)
	end
end
-- ①效果目标设定：确认存在装备怪兽，建立效果联系并登记破坏操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec end
	ec:CreateEffectRelation(e)
	-- 声明本次效果将破坏当前的装备怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- ①效果处理：若装备怪兽仍存在且与效果有联系，则将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	if ec and ec:IsRelateToEffect(e) then
		-- 以效果原因破坏装备怪兽
		Duel.Destroy(ec,REASON_EFFECT)
	end
end
-- ②效果发动条件：检查这张卡是因失去装备对象而送墓，且原装备怪兽是被破坏送去墓地
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return ec and c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_DESTROY) and ec:IsLocation(LOCATION_GRAVE)
end
-- ②效果目标设定：读取原装备怪兽的原本种族、属性与攻击力，检查格子与衍生物特召合法性并记录数值
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	local race=ec:GetOriginalRace()
	local attr=ec:GetOriginalAttribute()
	local atk=ec:GetBaseAttack()
	if chk==0 then return ec:IsType(TYPE_MONSTER)
		-- 检查自己怪兽区与魔陷区各至少有1个可用空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家能否特殊召唤持有指定种族、属性、攻击力的1星「异睡衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,atk,0,1,race,attr) end
	e:SetLabel(race,attr,atk)
	-- 声明本次效果会产生1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 声明本次效果会特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
	-- 声明本次效果会将墓地中的这张卡移出墓地用于装备
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：创建并赋予原装备怪兽原本种族、属性、攻击力的「异睡衍生物」特殊召唤到自己场上，随后将墓地的这张卡装备给它
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race,attr,atk=e:GetLabel()
	-- 再次确认自己主要怪兽区有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认当前仍可以特殊召唤满足参数的「异睡衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,atk,0,1,race,attr) then
		-- 创建1只「异睡衍生物」卡片实例
		local token=Duel.CreateToken(tp,id+o)
		-- 把持有这张卡装备过的怪兽的原本的种族·属性·攻击力的1只「异睡衍生物」（1星·攻?/守0）在自己场上特殊召唤。
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
		-- 将生成的「异睡衍生物」表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
		if c:IsRelateToEffect(e) then
			-- 中断效果处理以体现“那之后”的先后顺序
			Duel.BreakEffect()
			-- 将墓地中的这张卡装备到特殊召唤的衍生物上
			Duel.Equip(tp,c,token)
		end
	end
end
