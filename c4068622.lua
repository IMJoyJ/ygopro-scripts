--BF－極光のアウロラ
-- 效果：
-- 这张卡不能通常召唤。把自己场上表侧表示存在的1只名字带有「黑羽」的调整和1只调整以外的怪兽从游戏中除外的场合才能特殊召唤。1回合1次，可以从自己的额外卡组把1只名字带有「黑羽」的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同的攻击力和效果。
function c4068622.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤条件效果，要求自己场上存在1只名字带有「黑羽」的调整和1只调整以外的怪兽从游戏中除外才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4068622.spcon)
	e1:SetTarget(c4068622.sptg)
	e1:SetOperation(c4068622.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以从自己的额外卡组把1只名字带有「黑羽」的同调怪兽从游戏中除外，直到结束阶段时当作和那只怪兽同名卡使用，得到相同的攻击力和效果
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4068622,0))  --"获得怪物效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c4068622.target)
	e2:SetOperation(c4068622.operation)
	c:RegisterEffect(e2)
	-- 禁止通常召唤效果，必须通过特殊召唤条件才能召唤
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为假值，使该卡无法通过通常方式召唤
	e3:SetValue(aux.FALSE)
	c:RegisterEffect(e3)
end
-- 筛选场上正面表示存在的可除外怪兽
function c4068622.spfilter(c)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost()
end
-- 筛选名字带有「黑羽」且为调整的怪兽
function c4068622.spfilter1(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_TUNER)
end
-- 筛选名字不带有「黑羽」或非调整的怪兽
function c4068622.spfilter2(c)
	return not c:IsType(TYPE_TUNER)
end
-- 组合筛选函数，检查是否满足调整和非调整怪兽的组合条件
function c4068622.fselect(g,tp)
	-- 检查组合是否满足调整和非调整怪兽的组合条件
	return aux.mzctcheck(g,tp) and aux.gffcheck(g,c4068622.spfilter1,nil,c4068622.spfilter2,nil)
end
-- 判断是否满足特殊召唤条件，即场上存在符合条件的2张怪兽卡
function c4068622.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上正面表示存在的所有可除外怪兽
	local g=Duel.GetMatchingGroup(c4068622.spfilter,tp,LOCATION_MZONE,0,nil)
	return g:CheckSubGroup(c4068622.fselect,2,2,tp)
end
-- 设置特殊召唤目标，选择符合条件的2张怪兽卡
function c4068622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上正面表示存在的所有可除外怪兽
	local g=Duel.GetMatchingGroup(c4068622.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,c4068622.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的怪兽除外
function c4068622.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 筛选名字带有「黑羽」且可除外的额外卡组怪兽
function c4068622.filter(c)
	return c:IsSetCard(0x33) and c:IsAbleToRemove()
end
-- 设置效果目标，检查是否有名字带有「黑羽」的同调怪兽可除外
function c4068622.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有名字带有「黑羽」的同调怪兽可除外
	if chk==0 then return Duel.IsExistingMatchingCard(c4068622.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息，表示将要除外名字带有「黑羽」的同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_EXTRA)
end
-- 执行效果操作，选择并除外名字带有「黑羽」的同调怪兽
function c4068622.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从额外卡组选择1只名字带有「黑羽」的同调怪兽
	local g=Duel.SelectMatchingCard(tp,c4068622.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	-- 判断是否满足效果发动条件，即选中的怪兽可除外且自身状态有效
	if tc and c:IsFaceup() and c:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local code=tc:GetOriginalCode()
		local ba=tc:GetBaseAttack()
		-- 复制选中怪兽的卡号，使自身获得其效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		-- 设置自身攻击力为选中怪兽的攻击力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabelObject(e1)
		e2:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e2:SetValue(ba)
		c:RegisterEffect(e2)
		local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
		-- 设置结束阶段时自动恢复原效果的持续效果
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(1162)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCountLimit(1)
		e3:SetRange(LOCATION_MZONE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetLabel(cid)
		e3:SetLabelObject(e2)
		e3:SetOperation(c4068622.rstop)
		c:RegisterEffect(e3)
	end
end
-- 结束阶段时恢复原效果的处理函数
function c4068622.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	c:ResetEffect(cid,RESET_COPY)
	c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	local e2=e:GetLabelObject()
	local e1=e2:GetLabelObject()
	e1:Reset()
	e2:Reset()
	-- 显示被选为对象的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
