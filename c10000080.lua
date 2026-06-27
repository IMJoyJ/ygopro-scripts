--ラーの翼神竜－球体形
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤或者把对方场上3只怪兽解放在对方场上召唤，召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
-- ①：这张卡不能攻击，不会成为对方的攻击·效果的对象。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
function c10000080.initial_effect(c)
	-- 声明关联的太阳神之翼神龙卡片
	aux.AddCodeList(c,10000010)
	-- 启用全局洗脑/控制权状态检查
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- 把自己场上3只怪兽解放在自己场上召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000080,0))  --"在自己场上召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000080.ttcon1)
	e1:SetOperation(c10000080.ttop1)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 把对方场上3只怪兽解放在对方场上召唤
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
	-- 限制这张卡不能里侧表示盖放
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LIMIT_SET_PROC)
	e3:SetCondition(c10000080.setcon)
	c:RegisterEffect(e3)
	-- 不能特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e4)
	-- 召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetOperation(c10000080.retreg)
	c:RegisterEffect(e5)
	-- ①：这张卡不能攻击
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e6)
	-- 不会成为对方的攻击对象
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetRange(LOCATION_MZONE)
	-- 不会成为对方的攻击对象
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 不会成为对方的效果对象
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
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
-- 在自己场上进行召唤的条件：必须解放自己场上的3只怪兽
function c10000080.ttcon1(e,c,minc)
	if c==nil then return true end
	-- 检查自己场上是否存在3只可解放的怪兽
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 在自己场上召唤的实际解放操作
function c10000080.ttop1(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择自己场上作为祭品解放的3只怪兽
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放自己场上选中的3只怪兽进行召唤
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 在对方场上进行召唤的条件：必须解放对方场上的3只怪兽
function c10000080.ttcon2(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上的全部怪兽
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 检查对方场上是否存在3只可解放的怪兽
	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp)
end
-- 在对方场上召唤的实际解放操作
function c10000080.ttop2(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方场上的全部怪兽
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 选择对方场上作为祭品解放的3只怪兽
	local g=Duel.SelectTribute(tp,c,3,3,mg,1-tp)
	c:SetMaterial(g)
	-- 解放对方场上选中的3只怪兽进行召唤
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 限制盖放的条件（禁止盖放）
function c10000080.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 召唤成功时触发，注册控制权回归的定时效果
function c10000080.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(10000080,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)
	-- 注册在下个回合的结束阶段使控制权回归的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置控制权在下个回合的结束阶段回归的效果参数
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetCountLimit(1)
	e1:SetCondition(c10000080.retcon)
	e1:SetOperation(c10000080.retop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册全局控制权回归检测效果
	Duel.RegisterEffect(e1,tp)
end
-- 控制权回归的触发条件：判定是否到达设定的回合
function c10000080.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足延迟回归的回合数以及标记是否存在
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(10000080)~=0
end
-- 控制权回归的处理：移除控制权改变状态并归还给原本持有者
function c10000080.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	-- 创建重置控制权转移状态的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(c)
	e1:SetTarget(c10000080.rettg)
	-- 注册重置控制权状态的效果
	Duel.RegisterEffect(e1,tp)
	-- 创建自动重置本回归效果的调整监听器
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(c10000080.reset)
	-- 注册重置效果的监听器
	Duel.RegisterEffect(e2,tp)
end
-- 控制权回归的目标选择：锁定本卡
function c10000080.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(10000080)~=0
end
-- 控制权回归完成后，重置并清理相关延迟效果
function c10000080.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
-- 特召太阳神效果的Cost：解放此卡本身
function c10000080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤可以特殊召唤的太阳神之翼神龙
function c10000080.filter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特召太阳神效果的目标选择
function c10000080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上区域是否有空间且手卡卡组有太阳神
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡或卡组中是否存在太阳神之翼神龙
		and Duel.IsExistingMatchingCard(c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 声明特殊召唤太阳神之翼神龙的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特召太阳神效果的实际操作
function c10000080.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特召时自己场上是否存在空余位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡或卡组中的1只「太阳神之翼神龙」进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将太阳神之翼神龙无视召唤条件在自己场上特殊召唤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 将特殊召唤出的太阳神之翼神龙攻击力·守备力上升并固定为4000
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
	-- 完成特殊召唤流程的所有结算
	Duel.SpecialSummonComplete()
end
