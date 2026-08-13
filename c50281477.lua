--ティスティナの瘴神
-- 效果：
-- 这张卡可以把对方场上1只里侧表示怪兽解放表侧表示上级召唤。
-- ①：通常召唤的这张卡的等级变成10星。
-- ②：这张卡从场上以外送去墓地的场合，以自己场上1只「提斯蒂娜」怪兽为对象才能发动。这个回合，自己只能用1只怪兽攻击，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
local s,id,o=GetID()
-- 为卡片注册三个效果：①表侧上级召唤规则（解放对方里侧怪兽）；②通常召唤时等级变成10星；③从场上以外送入墓地时，以自己场上1只「提斯蒂娜」怪兽为对象，赋予其额外攻击次数并限制本回合只能有1只怪兽攻击。
function s.initial_effect(c)
	-- 这张卡可以把对方场上1只里侧表示怪兽解放表侧表示上级召唤。
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
	-- ①：通常召唤的这张卡的等级变成10星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上以外送去墓地的场合，以自己场上1只「提斯蒂娜」怪兽为对象才能发动。这个回合，自己只能用1只怪兽攻击，作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
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
-- 过滤条件：怪兽为里侧表示且是对方的怪兽，用于选出可解放的对方里侧怪兽。
function s.tfilter(c,tp)
	return c:IsFacedown() and c:IsControler(1-tp)
end
-- 召唤规则效果的条件：手牌中的这张卡进行上级召唤时，所需解放数不超过1，对方场上有符合tfilter的里侧怪兽，且自己场上有可用怪兽区。
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上所有可解放的怪兽集合。
	local g=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	-- 判断解放数≤1、存在符合条件的对方里侧怪兽、自己场上有空位，三者同时满足。
	return minc<=1 and g:IsExists(s.tfilter,1,nil,tp) and Duel.GetMZoneCount(tp)>0
end
-- 召唤规则效果处理：从符合条件的对方里侧怪兽中选择1只，将其解放，并作为上级召唤的素材进行表侧表示上级召唤。
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方场上可解放的怪兽集合。
	local g1=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil)
	local g2=g1:Filter(s.tfilter,nil,tp)
	local sg=g2:Select(tp,1,1,nil)
	c:SetMaterial(sg)
	-- 解放所选怪兽，作为召唤素材和上级召唤的代价。
	Duel.Release(sg,REASON_MATERIAL+REASON_SUMMON)
end
-- 为这张卡生成一个等级变为10的效果：在其于场上表侧表示期间，等级视为10，离场或重置时失效。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：通常召唤的这张卡的等级变成10星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LEVEL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(10)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end
-- 效果②的发动条件：这张卡从场上以外（手牌/卡组/墓地等）被送去墓地的场合，即离开之前不在场上。
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 对象筛选：自己场上表侧表示的「提斯蒂娜」怪兽，能成为效果对象，且没有已适用的额外攻击次数效果。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1a4) and c:IsCanBeEffectTarget() and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 目标选择处理：处理连锁对象时校验对象合法性；发动时检查条件和可选对象，然后选择自己场上1只符合的「提斯蒂娜」怪兽。
function s.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.filter(chkc) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 发动时点条件：玩家可进入或正处于战斗阶段，并且自己场上有1只符合条件的对象。
	if chk==0 then return aux.bpcon(e,tp,eg,ep,ev,re,r,rp) and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择自己场上1只表侧表示「提斯蒂娜」怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：给对象怪兽增加1次可攻击次数，并设置“本回合自己只能用1只怪兽攻击”的限制——记录首次攻击宣言的怪兽，禁止其他怪兽攻击。
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽在同1次的战斗阶段中可以作2次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 这个回合，自己只能用1只怪兽攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(s.checkop)
		-- 注册一个全场持续效果，监听每次攻击宣言，用于记录第一只攻击的怪兽。
		Duel.RegisterEffect(e2,tp)
		-- 这个回合，自己只能用1只怪兽攻击
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetTargetRange(LOCATION_MZONE,0)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetReset(RESET_PHASE+PHASE_END)
		e3:SetCondition(s.atkcon)
		e3:SetTarget(s.atktg)
		e2:SetLabelObject(e3)
		-- 注册一个全场永续效果，禁止非指定怪兽发动攻击宣言。
		Duel.RegisterEffect(e3,tp)
	end
end
-- 攻击宣言发生时，将该怪兽的FieldID保存到效果标签中，作为本回合唯一允许攻击的怪兽标识。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end
-- 限制效果的发动/适用条件：已经有记录的攻击怪兽ID（发生过攻击宣言）。
function s.atkcon(e)
	return e:GetLabel()~=0
end
-- 禁止攻击的目标判定：若攻击怪兽不是记录的那只，则不能攻击宣言。
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
