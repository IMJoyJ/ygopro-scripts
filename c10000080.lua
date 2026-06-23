--ラーの翼神竜－球体形
-- 效果：
-- 这张卡不能特殊召唤。这张卡通常召唤的场合，必须把自己场上3只怪兽解放在自己场上召唤或者把对方场上3只怪兽解放在对方场上召唤，召唤的这张卡的控制权在下个回合的结束阶段回归原本持有者。
-- ①：这张卡不能攻击，不会成为对方的攻击·效果的对象。
-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
function c10000080.initial_effect(c)
	-- 将卡片10000010的代码添加到当前卡片的代码列表中。
	aux.AddCodeList(c,10000010)
	-- 启用洗脑解除标记，用于处理一些特殊情况下的效果。
	Duel.EnableGlobalFlag(GLOBALFLAG_BRAINWASHING_CHECK)
	-- ①：这张卡不能攻击，不会成为对方的攻击·效果的对象。
-- 注册一个限制通常召唤的效果，并设置描述信息、属性和条件。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10000080,0))  --"在自己场上召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e1:SetCondition(c10000080.ttcon1)
	e1:SetOperation(c10000080.ttop1)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放才能发动。从手卡·卡组把1只「太阳神之翼神龙」无视召唤条件并攻击力·守备力变成4000特殊召唤。
-- 注册一个限制通常召唤的效果，并设置描述信息、属性和目标范围。
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
	-- 注册一个效果，限制这张卡的放置（通常召唤）规则。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LIMIT_SET_PROC)
	e3:SetCondition(c10000080.setcon)
	c:RegisterEffect(e3)
	-- 注册一个效果，设定特殊召唤条件。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_SPSUMMON_CONDITION)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e4)
	-- 注册一个持续效果，在通常召唤成功时触发，用于处理控制权转移的逻辑。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetOperation(c10000080.retreg)
	c:RegisterEffect(e5)
	-- 注册一个单次效果，禁止这张卡攻击。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e6)
	-- 注册一个单次效果，使这张卡不会成为对方怪兽战斗的目标。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e7:SetRange(LOCATION_MZONE)
	-- 设置过滤函数aux.imval1，用于判断是否可以作为攻击目标。
	e7:SetValue(aux.imval1)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置过滤函数aux.tgoval，用于判断是否可以作为效果对象。
	e8:SetValue(aux.tgoval)
	c:RegisterEffect(e8)
	-- 注册一个点火效果，允许解放这张卡来特殊召唤另一张「太阳神之翼神龙」。
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
-- 定义条件函数c10000080.ttcon1，检查是否满足通常召唤的祭品数量要求。
function c10000080.ttcon1(e,c,minc)
	if c==nil then return true end
	-- 判断祭品数量是否小于等于3并且存在可用于祭品的怪兽。
	return minc<=3 and Duel.CheckTribute(c,3)
end
-- 定义操作函数c10000080.ttop1，选择祭品并释放它们。
function c10000080.ttop1(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从场上选择3只怪兽作为祭品。
	local g=Duel.SelectTribute(tp,c,3,3)
	c:SetMaterial(g)
	-- 释放选定的祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义条件函数c10000080.ttcon2，检查是否满足在对方场上召唤的祭品数量要求。
function c10000080.ttcon2(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家的怪兽区域。
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 判断祭品数量是否小于等于3并且存在可用于祭品的怪兽。
	return minc<=3 and Duel.CheckTribute(c,3,3,mg,1-tp)
end
-- 定义操作函数c10000080.ttop2，选择对方场上的祭品并释放它们。
function c10000080.ttop2(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取玩家的怪兽区域。
	local mg=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	-- 从对方场上选择3只怪兽作为祭品。
	local g=Duel.SelectTribute(tp,c,3,3,mg,1-tp)
	c:SetMaterial(g)
	-- 释放选定的祭品。
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end
-- 定义条件函数c10000080.setcon，用于限制这张卡的放置（通常召唤）。
function c10000080.setcon(e,c,minc)
	if not c then return true end
	return false
end
-- 定义操作函数c10000080.retreg，注册一个持续效果来处理控制权转移。
function c10000080.retreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(10000080,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,2)
	-- 在通常召唤成功时触发，注册一个标记效果和一个字段效果，用于追踪和移除洗脑状态。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置标签值为当前回合数+1。
	e1:SetLabel(Duel.GetTurnCount()+1)
	e1:SetCountLimit(1)
	e1:SetCondition(c10000080.retcon)
	e1:SetOperation(c10000080.retop)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册字段效果。
	Duel.RegisterEffect(e1,tp)
end
-- 定义条件函数c10000080.retcon，检查是否满足触发控制权转移的效果。
function c10000080.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合数是否等于标签值并且拥有者仍然具有标记。
	return Duel.GetTurnCount()==e:GetLabel() and e:GetOwner():GetFlagEffect(10000080)~=0
end
-- 定义操作函数c10000080.retop，移除洗脑状态并注册一个调整事件处理程序。
function c10000080.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	-- 创建字段效果，用于移除洗脑状态。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REMOVE_BRAINWASHING)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetLabelObject(c)
	e1:SetTarget(c10000080.rettg)
	-- 注册字段效果。
	Duel.RegisterEffect(e1,tp)
	-- 定义过滤函数c10000080.rettg，判断是否可以作为目标。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetLabelObject(e1)
	e2:SetOperation(c10000080.reset)
	-- 定义操作函数c10000080.reset，重置相关效果。
	Duel.RegisterEffect(e2,tp)
end
-- 定义特殊召唤的费用函数c10000080.spcost，检查并释放当前卡片。
function c10000080.rettg(e,c)
	return c==e:GetLabelObject() and c:GetFlagEffect(10000080)~=0
end
-- 定义过滤函数c10000080.filter，用于筛选可以特殊召唤的「太阳神之翼神龙」。
function c10000080.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end
-- 定义目标选择函数c10000080.sptg，检查是否满足特殊召唤条件并设置操作信息。
function c10000080.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 检查场上是否有空位以及是否存在符合条件的卡片。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义操作函数c10000080.spop，执行特殊召唤逻辑。
function c10000080.filter(c,e,tp)
	return c:IsCode(10000010) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 检查场上是否还有可用的怪兽区域。
function c10000080.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 提示玩家选择要特殊召唤的卡片。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 从手牌或卡组中选择符合条件的卡片。
		and Duel.IsExistingMatchingCard(c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 执行特殊召唤步骤，并设置攻击力和防御力。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 完成特殊召唤。
function c10000080.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有可用的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或卡组中选择符合条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c10000080.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，并设置攻击力和防御力。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,true,false,POS_FACEUP) then
		-- 创建单次效果，设置攻击力。
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
	-- 完成特殊召唤。
	Duel.SpecialSummonComplete()
end
