--キラーチューン・ラウドネスウォー
-- 效果：
-- 调整＋调整1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的其他调整不会被效果破坏，对方不能把那些作为效果的对象。
-- ②：对方把效果发动时，从自己墓地把1只「杀手级调整曲」怪兽除外才能发动。除外的怪兽的自身作为同调素材送去墓地的场合发动的效果适用。
local s,id,o=GetID()
-- 初始化效果，添加同调召唤手续并设置苏生限制，注册多个效果用于提升调整怪兽的抗性及复制对方效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求至少1只调整怪兽参与同调召唤，最多99只
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.Tuner(nil),1,99)
	c:EnableReviveLimit()
	-- 只要这张卡在怪兽区域存在，自己场上的其他调整不会被效果破坏
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
	-- 对方不能把那些作为效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 对方把效果发动时，从自己墓地把1只「杀手级调整曲」怪兽除外才能发动。除外的怪兽的自身作为同调素材送去墓地的场合发动的效果适用
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
	-- 此卡不能被无效或复制
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(21142671)
	c:RegisterEffect(e4)
end
-- 目标为除自身外的场上调整怪兽
function s.target(e,c)
	return c~=e:GetHandler() and c:IsType(TYPE_TUNER)
end
-- 对方发动效果时触发
function s.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 过滤满足条件的墓地「杀手级调整曲」怪兽，确保其能作为同调素材并具备可复制效果
function s.pfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not (c:IsSetCard(0x1d5) and c:IsAbleToRemoveAsCost()) then return false end
	local te=c.killer_tune_be_material_effect
	if not te then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,nil,c)
end
-- 检查是否满足发动条件，即是否有满足条件的墓地怪兽可除外
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在满足条件的墓地怪兽
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只墓地怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local te=tc.killer_tune_be_material_effect
	-- 将选中的怪兽除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 清除当前连锁中的目标卡片
	Duel.ClearTargetCard()
	e:SetLabelObject(te)
	local tg=te:GetTarget()
	if tg then
		local cchk=e:IsCostChecked()
		e:SetCostCheck(false)
		tg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCostCheck(cchk)
	end
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 执行复制的效果操作
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
