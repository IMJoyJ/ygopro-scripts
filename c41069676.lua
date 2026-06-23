--キラーチューン・ラウドネスウォー
-- 效果：
-- 调整＋调整1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的其他调整不会被效果破坏，对方不能把那些作为效果的对象。
-- ②：对方把效果发动时，从自己墓地把1只「杀手级调整曲」怪兽除外才能发动。除外的怪兽的自身作为同调素材送去墓地的场合发动的效果适用。
local s,id,o=GetID()
-- 卡片效果初始化注册流程
function s.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整1只以上
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己场上的其他调整不会被效果破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不能成为对方的效果对象效果的阻抗过滤，保护除自身外的己方怪兽不被对方卡片效果指定
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：对方把效果发动时，从自己墓地把1只「杀手级调整曲」怪兽除外才能发动。除外的怪兽的自身作为同调素材送去墓地的场合发动的效果适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"复制效果"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.cpcon)
	e3:SetTarget(s.cptg)
	e3:SetOperation(s.cpop)
	c:RegisterEffect(e3)
	-- 注册本卡作为“杀手级调整曲”怪兽的专属辅助标示效果
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 抗性效果的目标判定函数，过滤得到场上除本卡以外的其他调整怪兽
function s.target(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_TUNER)
end
-- ②号效果的发动条件判定函数，检查是否为对方发动的效果连锁
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤满足除外代价条件，且拥有能够被复制的作为同调素材时触发效果的「杀手级调整曲」怪兽
function s.pfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x1d5) and c:IsAbleToRemoveAsCost()) then return false end
	local te=c.killer_tune_be_material_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- ②号效果的发动靶指向（Target）函数，检查并执行墓地卡片除外的发动代价，并复制其效果Target流程
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查墓地是否存在能够作为发动代价除外，且其送入墓地效果可成功发动的「杀手级调整曲」怪兽
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 向玩家提示信息：“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让我方玩家从墓地中选择1只符合条件的「杀手级调整曲」怪兽
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local te=tc.killer_tune_be_material_effect
	-- 将选择的怪兽卡片正面表示除外作为效果的发动代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetProperty(te:GetProperty()&EFFECT_FLAG_CARD_TARGET)
	-- 清空当前连锁的所有对象卡片信息
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then
		local cchk=e:IsCostChecked()
		e:SetCostCheck(false)
		tg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCostCheck(cchk)
	end
	-- 清除当前连锁的操作信息，以兼容复制的效果中不产生对应操作提示的逻辑
	Duel.ClearOperationInfo(0)
end
-- ②号效果的执行逻辑（Operation）函数，获取并执行除外怪兽对应的同调素材效果
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
