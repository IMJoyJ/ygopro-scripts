--ティスティナの瘴神
-- 效果：
-- 这张卡可以把对方场上1只里侧表示怪兽解放表侧表示上级召唤。
-- ①：通常召唤的这张卡的等级变成10星。
-- ②：这张卡从场上以外送去墓地的场合，以自己场上1只「提斯蒂娜」怪兽为对象才能发动。这个回合，自己只能用1只怪兽攻击，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 初始化卡片效果，创建3个效果：上级召唤效果、等级变更效果和墓地触发效果
function s.initial_effect(c)
	-- 把对方场上1只里侧表示怪兽解放作上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"把对方场上1只里侧表示怪兽解放作上级召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 通常召唤的这张卡的等级变成10星
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- 这张卡从场上以外送去墓地的场合，以自己场上1只「提斯蒂娜」怪兽为对象才能发动。这个回合，自己只能用1只怪兽攻击，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"2次攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(s.dacon)
	e3:SetTarget(s.datg)
	e3:SetOperation(s.daop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断目标是否为里侧表示且控制者为对方的怪兽
function s.tfilter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp)
end
-- 上级召唤条件函数：检查是否有可解放的对方怪兽且场上还有空位
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取己方场上所有可解放的怪兽数组
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	-- 返回值：满足召唤条件（最少需要1个解放对象，存在可解放的对方怪兽，且场上空位大于0）
	return minc<=1 and g:IsExists(s.tfilter,1,nil,tp) and Duel.GetMZoneCount(tp)>0
end
-- 上级召唤操作函数：选择并解放对方怪兽进行上级召唤
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取己方场上所有可解放的怪兽数组
	local g1=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	local g2=g1:Filter(s.tfilter,nil,tp)
	local sg=g2:Select(tp,1,1,nil)
	c:SetMaterial(sg)
	-- 将选中的怪兽以素材和召唤原因进行解放
	Duel.Release(sg,REASON_MATERIAL+REASON_SUMMON)
end
-- 等级变更效果函数：将此卡等级设为10星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将此卡等级设为10星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(10)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 墓地触发条件函数：判断此卡不是从场上送去墓地的
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：筛选己方场上满足条件的提斯蒂娜怪兽（表侧表示、可成为效果对象、未拥有额外攻击次数）
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a4) and c:IsCanBeEffectTarget() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 选择目标函数：在己方场上选择符合条件的提斯蒂娜怪兽作为对象
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 判断是否满足发动条件：当前处于战斗阶段且存在符合条件的目标怪兽
	if chk==0 then return aux.bpcon(e,tp,eg,ep,ev,re,r,rp) and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择符合条件的目标怪兽
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 墓地触发效果操作函数：为指定目标怪兽增加一次攻击次数并限制其他怪兽攻击
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 为指定目标怪兽增加一次攻击次数
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 创建持续到结束阶段的攻击宣告监听效果，用于记录攻击怪兽的FieldID
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(s.checkop)
		-- 注册攻击宣告监听效果
		Duel.RegisterEffect(e2,tp)
		-- 创建限制其他怪兽攻击的效果，并与攻击宣告监听效果关联
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetCondition(s.atkcon)
		e3:SetTarget(s.atktg)
		e2:SetLabelObject(e3)
		-- 注册限制其他怪兽攻击的效果
		Duel.RegisterEffect(e3,tp)
	end
end
-- 攻击宣告监听操作函数：记录当前攻击怪兽的FieldID
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end
-- 限制攻击条件函数：判断是否已记录攻击怪兽的FieldID
function s.atkcon(e)
	return e:GetLabel()~=0
end
-- 限制攻击目标函数：排除记录中的FieldID对应的怪兽
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
