--ジャンク・ドラゴンセント
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己的同调怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只自己怪兽的攻击力直到回合结束时上升800。
local s,id,o=GetID()
-- 注册两个效果：①特殊召唤效果和②攻击时提升攻击力效果
function s.initial_effect(c)
	-- ①：自己场上有同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：自己的同调怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只自己怪兽的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 将此卡从墓地除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤条件：手卡此卡的控制者场上存在空位且己方场上存在同调怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查己方场上是否存在空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方场上是否存在至少1只同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断是否为正面表示的同调怪兽
function s.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 判断是否满足攻击时效果发动条件：攻击怪兽为同调怪兽且为己方控制
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次攻击的怪兽
	local ac=Duel.GetAttacker()
	return ac:IsType(TYPE_SYNCHRO) and ac:IsControler(tp)
end
-- 设置攻击时效果的目标：记录攻击怪兽
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取此次攻击的怪兽
	local ac=Duel.GetAttacker()
	e:SetLabelObject(ac)
end
-- 执行攻击时效果：使攻击怪兽攻击力上升800点
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	if ac:IsFaceup() and ac:IsControler(tp) and ac:IsRelateToBattle() then
		-- 使攻击怪兽的攻击力上升800点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		ac:RegisterEffect(e1)
	end
end
