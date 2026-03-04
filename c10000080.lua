--ラーの翼神竜－球体形
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤或者把对方场上3只怪兽解放在对方场上召唤，召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
-- ①：这张卡不能攻击，不会成为对方的攻击·效果的对象。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
function c10000080.initial_effect(c)
	-- 为卡片注册关联卡片代码10000010，用于后续效果判断
	aux.AddCodeList(c,10000010)
	-- 启用全局洗脑解除标记，使卡片在被洗脑后能正常解除
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- ①：这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000080,0))  --"在自己场上召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000080.ttcon1)
	e1:SetOperation(c10000080.ttop1)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ①：这张卡通常召唤的场合，必须把对方场上3只怪兽解放在对方场上召唤
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
	-- ①：这张卡不能特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LIMIT_SET_PROC)
	e3:SetCondition(c10000080.setcon)
	c:RegisterEffect(e3)
	-- ①：这张卡不能特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e4)
	-- ①：召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者
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
	-- ①：不会成为对方的攻击·效果的对象
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.imval1，用于判断是否不会成为攻击对象
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为aux.tgoval，用于判断是否不会成为对方效果的对象
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤
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
-- 通常召唤条件函数ttcon1：检查是否满足3个祭品条件
function c10000080.ttcon1(e,c,minc)
	if c==nil then return true end
	-- 返回是否满足3个祭品条件
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 通常召唤操作函数ttop1：选择并解放3个祭品
function c10000080.ttop1(e,tp,eg,ep,ev,re,r,rp,c)
	-- 选择3个祭品
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 解放祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 通常召唤条件函数ttcon2：检查是否满足对方场上的3个祭品条件
function c10000080.ttcon2(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取对方场上的怪兽组
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 返回是否满足对方场上的3个祭品条件
	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp)
end
-- 通常召唤操作函数ttop2：选择并解放对方场上的3个祭品
function c10000080.ttop2(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取对方场上的怪兽组
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 选择对方场上的3个祭品
	local g=Duel.SelectTribute(tp,c,3,3,mg,1-tp)
	c:SetMaterial(g)
	-- 解放祭品
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 放置召唤条件函数setcon：返回false，表示不能放置召唤
function c10000080.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 召唤成功后注册控制权回归效果
function c10000080.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(10000080,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)
	-- 控制权回归效果注册函数retreg：注册一个在回合结束时触发的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置效果标签为下个回合的回合数
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetCountLimit(1)
	e1:SetCondition(c10000080.retcon)
	e1:SetOperation(c10000080.retop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将效果注册到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 控制权回归条件函数retcon：检查是否到达指定回合
function c10000080.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否到达指定回合且卡片有标记
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(10000080)~=0
end
-- 控制权回归操作函数retop：执行控制权回归
function c10000080.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	-- 创建移除洗脑效果的函数rettg：判断是否为该卡片
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(c)
	e1:SetTarget(c10000080.rettg)
	-- 将移除洗脑效果注册到玩家
	Duel.RegisterEffect(e1,tp)
	-- 注册调整阶段的重置效果
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(c10000080.reset)
	-- 将重置效果注册到玩家
	Duel.RegisterEffect(e2,tp)
end
-- 控制权回归目标函数rettg：判断是否为该卡片
function c10000080.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(10000080)~=0
end
-- 重置效果函数reset：重置效果
function c10000080.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
-- 特殊召唤成本函数spcost：检查是否可以解放自身
function c10000080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为特殊召唤成本
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤过滤函数filter：检查是否为太阳神之翼神龙
function c10000080.filter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤目标函数sptg：检查是否有满足条件的卡片
function c10000080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手牌或卡组中是否存在太阳神之翼神龙
		and Duel.IsExistingMatchingCard(c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤操作函数spop：执行特殊召唤
function c10000080.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择特殊召唤目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 设置攻击力为4000
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
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
