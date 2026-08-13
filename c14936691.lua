--ワーム・イーロキン
-- 效果：
-- 这张卡不能特殊召唤。选择场上表侧表示存在的1只名字带有「异虫」的爬虫类族怪兽变成里侧守备表示。这个效果1回合只能使用1次。
function c14936691.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 选择场上表侧表示存在的1只名字带有「异虫」的爬虫类族怪兽变成里侧守备表示。这个效果1回合只能使用1次。
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
-- 过滤选择对象：必须是表侧表示、名字带有「异虫」的爬虫类族怪兽，且能够变成里侧表示。
function c14936691.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and c:IsCanTurnSet()
end
-- 效果的目标选择函数：验证对象合法性，在发动时检查是否存在符合条件的目标，让玩家选择1只怪兽，并设置改变表示形式的操作信息。
function c14936691.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14936691.filter(chkc) end
	-- 发动条件判定：自己的主要怪兽区是否存在至少1只满足过滤条件的表侧表示「异虫」爬虫类族怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c14936691.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示信息，提示其选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从自己场上的主要怪兽区选择1只满足过滤条件的表侧表示「异虫」爬虫类族怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c14936691.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置本次连锁的操作信息：将改变对象卡片的表示形式（CATEGORY_POSITION），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时的操作：获取效果对象，若其仍在场上且与效果关联，则将其变为里侧守备表示。
function c14936691.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得通过效果对象选择所确定的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为里侧守备表示（表侧攻击/守备表示均变为里侧守备）。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
	end
end
