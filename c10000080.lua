--ラーの翼神竜－球体形
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤或者把对方场上3只怪兽解放在对方场上召唤，召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
-- ①：这张卡不能攻击，不会成为对方的攻击·效果的对象。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
function c10000080.initial_effect(c)
	-- 将「太阳神之翼神龙」的卡片密码写入此卡的关联卡片列表
	aux.AddCodeList(c,10000010)
	-- 开启控制权转移检测的全局标记
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- 在自己场上解放自己场上3只怪兽进行上级召唤的规则/手续
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000080,0))  --"在自己场上召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000080.ttcon1)
	e1:SetOperation(c10000080.ttop1)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 在对方场上解放对方场上3只怪兽进行上级召唤的规则/手续
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10000080,1))  --"在对方场上召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e2:SetTargetRange(POS_FACEUP_ATTACK,1)
	e2:SetCondition(c10000080.ttcon2)
	e2:SetOperation(c10000080.ttop2)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 此卡不能盖放（里侧表示召唤）的限制
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LIMIT_SET_PROC)
	e3:SetCondition(c10000080.setcon)
	c:RegisterEffect(e3)
	-- 此卡不能特殊召唤的限制
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e4)
	-- 召唤成功时，注册下个回合结束阶段控制权回归原本持有者效果的触发器
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetOperation(c10000080.retreg)
	c:RegisterEffect(e5)
	-- 此卡不能攻击的限制
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e6)
	-- 此卡不会成为对方的攻击对象的效果
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetRange(LOCATION_MZONE)
	-- 设定不会成为对方怪兽的攻击对象限制
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设定不会成为对方的效果对象限制
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- 把此卡解放，从手卡·卡组将1只「太阳神之翼神龙」无视召唤条件且攻守设定为4000特殊召唤的效果
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(10000080,2))
	e9:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_MZONE)
	e9:SetCost(c10000080.spcost)
	e9:SetTarget(c10000080.sptg)
	e9:SetOperation(c10000080.spop)
	c:RegisterEffect(e9)
end
-- 在自己场上召唤的条件判定函数
function c10000080.ttcon1(e,c,minc)
	if c==nil then return true end
	-- 检查自己场上是否有3只怪兽可用于解放
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 在自己场上召唤的解放操作函数
function c10000080.ttop1(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择自己场上3只用于解放的怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放选中的怪兽以进行召唤
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 在对方场上召唤的条件判定函数
function c10000080.ttcon2(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上的怪兽群
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 检查对方场上是否有3只怪兽可用于解放
	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp)
end
-- 在对方场上召唤的解放操作函数
function c10000080.ttop2(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方场上的怪兽群
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 选择对方场上3只用于解放的怪兽
	local g=Duel.SelectTribute(tp,c,3,3,mg,1-tp)
	c:SetMaterial(g)
	-- 解放选中的怪兽以进行召唤
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 盖放条件判定函数（直接返回false表示不能盖放）
function c10000080.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 控制权回归事件的注册函数
function c10000080.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(10000080,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)
	-- 注册在下个回合结束阶段发动控制权回归的全局效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置回归的目标回合为当前回合的下一回合
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetCountLimit(1)
	e1:SetCondition(c10000080.retcon)
	e1:SetOperation(c10000080.retop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册控制权回归效果
	Duel.RegisterEffect(e1,tp)
end
-- 控制权回归条件的判定函数
function c10000080.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否为目标回合，且此卡在场上仍有对应的标记
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(10000080)~=0
end
-- 控制权回归的操作执行函数
function c10000080.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	-- 注册移除洗脑效果（控制权还给原本持有者）的全局效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(c)
	e1:SetTarget(c10000080.rettg)
	-- 注册移除洗脑效果
	Duel.RegisterEffect(e1,tp)
	-- 注册在系统调整时重置移除洗脑效果的全局效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(c10000080.reset)
	-- 注册重置调整效果
	Duel.RegisterEffect(e2,tp)
end
-- 控制权交还的目标过滤函数（仅针对被召唤的此卡）
function c10000080.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(10000080)~=0
end
-- 重置控制权还给持有者效果的清理函数
function c10000080.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
-- 特殊召唤「太阳神之翼神龙」的Cost函数
function c10000080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放此卡以发动效果
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤目标的过滤函数（「太阳神之翼神龙」）
function c10000080.filter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤目标的判定函数
function c10000080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上的怪兽区域空位是否满足要求
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡·卡组是否存在可以特殊召唤的「太阳神之翼神龙」
		and Duel.IsExistingMatchingCard(c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果分类为特殊召唤，并指定特殊召唤来源为手卡·卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤「太阳神之翼神龙」的执行操作函数
function c10000080.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上的怪兽区域空位是否足够
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只「太阳神之翼神龙」
	local g=Duel.SelectMatchingCard(tp,c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 特殊召唤成功时执行后续攻击力/守备力设定
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 将特殊召唤的怪兽原本攻击力固定设定为4000
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(4000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程的结算
	Duel.SpecialSummonComplete()
end
