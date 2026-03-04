--ワーム・キング
-- 效果：
-- 这张卡可以用1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，对方场上1张卡破坏。
function c10026986.initial_effect(c)
	-- 这张卡可以用1只名字带有「异虫」的爬虫类族怪兽解放表侧攻击表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10026986,0))  --"用1只怪兽解放上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c10026986.otcon)
	e1:SetOperation(c10026986.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	-- 可以把自己场上存在的1只名字带有「异虫」的爬虫类族怪兽解放，对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10026986,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c10026986.descost)
	e2:SetTarget(c10026986.destg)
	e2:SetOperation(c10026986.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（异虫+爬虫类族）
function c10026986.cfilter(c,tp)
	return c:IsSetCard(0x3e) and c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
end
-- 上级召唤的条件判断函数
function c10026986.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上满足条件的怪兽组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断是否满足上级召唤条件（等级≥7，祭品数量为1）
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤的执行函数
function c10026986.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上满足条件的怪兽组
	local mg=Duel.GetMatchingGroup(c10026986.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 选择用于上级召唤的祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选择的祭品怪兽
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 破坏效果的费用支付函数
function c10026986.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以支付破坏效果的费用
	if chk==0 then return Duel.CheckReleaseGroup(tp,c10026986.cfilter,1,nil,tp) end
	-- 选择用于支付费用的怪兽
	local sg=Duel.SelectReleaseGroup(tp,c10026986.cfilter,1,1,nil,tp)
	-- 解放选择的怪兽作为费用
	Duel.Release(sg,REASON_COST)
end
-- 破坏效果的目标选择函数
function c10026986.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查是否存在可破坏的目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择破坏目标
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行函数
function c10026986.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
