--シンクロ・チェイス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己把「战士」、「同调士」、「星尘」同调怪兽同调召唤的场合，以作为那次同调召唤的素材的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在，对方不能对应原本卡名包含「战士」、「同调士」、「星尘」之内任意种的自己的同调怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c23442438.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己把「战士」、「同调士」、「星尘」同调怪兽同调召唤的场合，以作为那次同调召唤的素材的自己墓地1只怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23442438,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,23442438)
	e2:SetCondition(c23442438.spcon)
	e2:SetTarget(c23442438.sptg)
	e2:SetOperation(c23442438.spop)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，对方不能对应原本卡名包含「战士」、「同调士」、「星尘」之内任意种的自己的同调怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(c23442438.ccop)
	c:RegisterEffect(e3)
end
-- 筛选满足条件的同调召唤怪兽，即为同调召唤且种族为战士、同调士或星尘的怪兽
function c23442438.cfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:IsType(TYPE_SYNCHRO) and c:IsSetCard(0x66,0x1017,0xa3)
end
-- 筛选满足条件的墓地怪兽，即为墓地且控制者为玩家tp且能成为效果对象且能守备表示特殊召唤的怪兽
function c23442438.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:IsCanBeEffectTarget(e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断是否满足发动条件，即为存在满足条件的同调召唤怪兽且为玩家tp发动
function c23442438.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23442438.cfilter,1,nil) and rp==tp
end
-- 设置效果目标，即为选择满足条件的墓地怪兽作为特殊召唤对象
function c23442438.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c23442438.cfilter,nil):GetFirst():GetMaterial()
	if chkc then return mg:IsContains(chkc) and c23442438.spfilter(chkc,e,tp) end
	-- 判断是否满足发动条件，即为玩家tp场上存在空位且满足条件的墓地怪兽存在
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and mg:IsExists(c23442438.spfilter,1,nil,e,tp) end
	-- 向玩家tp发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=mg:FilterSelect(tp,c23442438.spfilter,1,1,nil,e,tp)
	-- 设置当前处理的连锁的对象为g
	Duel.SetTargetCard(g)
	-- 设置当前处理的连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果操作，即为将目标怪兽特殊召唤
function c23442438.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁的对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到玩家tp场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 处理连锁限制效果，即为设置连锁限制函数
function c23442438.ccop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if ep==tp and re:IsActiveType(TYPE_MONSTER) and tc:IsType(TYPE_SYNCHRO) and tc:IsOriginalSetCard(0x66,0x1017,0xa3) then
		-- 设置连锁限制，使对方不能对应特定同调怪兽的效果发动魔法·陷阱·怪兽效果
		Duel.SetChainLimit(c23442438.chainlm)
	end
end
-- 连锁限制函数，返回值为true表示允许连锁，false表示禁止连锁
function c23442438.chainlm(e,rp,tp)
	return tp==rp
end
