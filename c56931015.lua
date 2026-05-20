--グラヴィティ・ベヒモス
-- 效果：
-- 场上没有卡存在的场合，这张卡可以不用解放作召唤。这个效果在先攻第1回合不能使用。这张卡可以作为攻击的代替把场上存在的场地魔法卡破坏。
function c56931015.initial_effect(c)
	-- 场上没有卡存在的场合，这张卡可以不用解放作召唤。这个效果在先攻第1回合不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56931015,0))  --"不用解放召唤"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c56931015.ntcon)
	c:RegisterEffect(e1)
	-- 这张卡可以作为攻击的代替把场上存在的场地魔法卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56931015,1))  --"破坏场地魔法"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c56931015.descost)
	e2:SetTarget(c56931015.destg)
	e2:SetOperation(c56931015.desop)
	c:RegisterEffect(e2)
end
-- 妥协召唤效果的允许条件判定
function c56931015.ntcon(e,c,minc)
	-- 判定当前回合数是否不为第1回合（即不能在先攻第1回合使用）
	if c==nil then return Duel.GetTurnCount()~=1 end
	-- 判定是否不需要解放、怪兽等级是否在5星以上，且控制者场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判定双方场上是否存在卡片（必须为0张，即场上没有卡存在）
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_ONFIELD,LOCATION_ONFIELD)==0
end
-- 破坏场地魔法效果的发动代价判定与执行（作为攻击的代替）
function c56931015.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 作为攻击的代替
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 破坏场地魔法效果的发动目标判定与操作信息设置
function c56931015.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场地区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if chk==0 then return g:GetCount()>0 end
	-- 设置效果处理信息为破坏场地区域的所有卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏场地魔法效果的执行
function c56931015.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场地区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if g:GetCount()>0 then
		-- 因效果破坏获取到的场地区域卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
