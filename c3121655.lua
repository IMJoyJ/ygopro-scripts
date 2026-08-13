--ジャンク・ドラゴンセント
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己的同调怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只自己怪兽的攻击力直到回合结束时上升800。
local s,id,o=GetID()
-- 注册两个效果：e1为手卡规则特殊召唤（①效果），设置SPSUMMON_PROC、手牌范围、1回合1次限制和条件；e2为墓地诱发效果（②效果），设置攻击力变化分类、攻击宣言时点、墓地范围、1回合1次限制、除外代价、目标记录与处理函数。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有同调怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的同调怪兽的攻击宣言时，把墓地的这张卡除外才能发动。那只自己怪兽的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.atkcon)
	-- 设置②效果发动时的COST：把墓地中的这张卡除外（不能除外则无法发动）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- ①特殊召唤的规则条件：自己场上存在表侧表示同调怪兽且主要怪兽区有空位时，这张卡才能从手卡特殊召唤；c为nil时按规则默认允许。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在可用的主要怪兽区域，用于放置从手卡特殊召唤的这张卡。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足s.spfilter过滤条件的卡，即表侧表示的同调怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断卡片是否为表侧表示且为同调怪兽类型。
function s.spfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- ②效果的发动条件：当前攻击宣言的怪兽是同调怪兽且控制者为这张卡的所有者（发动者）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local ac=Duel.GetAttacker()
	return ac:IsType(TYPE_SYNCHRO) and ac:IsControler(tp)
end
-- ②效果发动时的目标处理：无选择目标，仅将当前攻击宣言的同调怪兽记录为标签对象，供效果处理时确认攻击力上升的对象；chk==0时仅判断能否发动。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取攻击宣言的怪兽，并准备将其存入效果的标签对象中。
	local ac=Duel.GetAttacker()
	e:SetLabelObject(ac)
end
-- ②效果处理：若记录的攻击怪兽仍然表侧表示、控制者为自己且与本次战斗相关联，则对其赋予攻击力上升800的效果，持续到回合结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=e:GetLabelObject()
	if ac:IsFaceup() and ac:IsControler(tp) and ac:IsRelateToBattle() then
		-- 那只自己怪兽的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(800)
		ac:RegisterEffect(e1)
	end
end
