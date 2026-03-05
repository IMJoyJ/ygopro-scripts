--ワーム・イーロキン
-- 效果：
-- 这张卡不能特殊召唤。选择场上表侧表示存在的1只名字带有「异虫」的爬虫类族怪兽变成里侧守备表示。这个效果1回合只能使用1次。
function c14936691.initial_effect(c)
	-- 效果原文内容：这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文内容：选择场上表侧表示存在的1只名字带有「异虫」的爬虫类族怪兽变成里侧守备表示。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14936691,0))  --"变更表示形式"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c14936691.postg)
	e2:SetOperation(c14936691.posop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的怪兽（表侧表示、异虫族、爬虫类族、可以变里侧守备表示）
function c14936691.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsCanTurnSet()
end
-- 设置效果的目标选择函数，用于选择符合条件的怪兽
function c14936691.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14936691.filter(chkc) end
	-- 判断是否满足选择目标的条件（场上存在符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c14936691.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择怪兽的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	-- 选择符合条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c14936691.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，指定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 设置效果的处理函数，用于执行怪兽表示形式的改变
function c14936691.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
	end
end
